import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnn_flashcard/speech/mic_recorder.dart';
import 'package:mnn_flashcard/speech/speech_service.dart';
import 'package:mnn_flashcard/speech/stt_client.dart';

/// Mic giả: test đẩy mức âm thanh vào tay, không có micro thật.
class FakeMic implements MicRecorder {
  final ctrl = StreamController<double>.broadcast();
  Object? startError;
  int starts = 0, stops = 0, cancels = 0;

  @override
  Future<void> start() async {
    starts++;
    if (startError != null) throw startError!;
  }

  @override
  Stream<double> levels(Duration every) => ctrl.stream;

  @override
  Future<Uint8List?> stop() async {
    stops++;
    return Uint8List.fromList(List.filled(4096, 1));
  }

  @override
  Future<void> cancel() async => cancels++;

  @override
  Future<void> dispose() async {}
}

/// Giống route thật: JSON UTF-8 (Response thường mã hoá latin1, lỗi với tiếng Nhật).
http.Response json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMic mic;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) reply;
  late SpeechService svc;

  // Kết quả một lần nghe: ('text', x) hoặc ('error', msg).
  late List<(String, String)> events;
  late int processing;
  late List<double> levels;

  setUp(() {
    mic = FakeMic();
    requests = [];
    reply = (_) async => json({'text': '先生。'});
    svc = SpeechService(
      recorder: mic,
      stt: SttClient(
        client: MockClient((r) {
          requests.add(r);
          return reply(r);
        }),
        url: 'https://x.test/kotoba-app/api/stt',
      ),
      silenceFor: const Duration(milliseconds: 40),
      maxRecording: const Duration(milliseconds: 400),
    );
    events = [];
    processing = 0;
    levels = [];
  });

  Future<bool> listen() => svc.listen(
    onResult: (t, final_) {
      expect(final_, isTrue);
      events.add(('text', t));
    },
    onError: (m) => events.add(('error', m)),
    onLevel: levels.add,
    onProcessing: () => processing++,
  );

  Future<void> wait([int ms = 120]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('nói rồi im: tự dừng, gửi một lần, trả chữ đã bỏ dấu câu', () async {
    expect(await listen(), isTrue);
    expect(svc.isListening, isTrue);
    mic.ctrl.add(-12);
    await wait(10);
    mic.ctrl.add(-50);
    await wait(60);
    mic.ctrl.add(-50); // đủ im lặng
    await wait();

    expect(events, [('text', '先生')]);
    expect(requests, hasLength(1));
    expect(requests.single.headers['Content-Type'], startsWith('audio/wav'));
    expect(processing, 1);
    expect(levels, [-12, -50, -50]);
    expect(svc.isListening, isFalse);
  });

  test('im lặng suốt phiên (hết trần): KHÔNG gửi gì lên server', () async {
    await listen();
    for (var i = 0; i < 5; i++) {
      mic.ctrl.add(-55);
      await wait(30);
    }
    await wait(400);
    expect(requests, isEmpty);
    expect(processing, 0);
    expect(events, [('error', 'Không nghe thấy giọng nói.')]);
    expect(mic.stops, 1);
  });

  test('dừng tay khi chưa nói gì: không gửi, báo lỗi', () async {
    await listen();
    mic.ctrl.add(-58);
    await svc.stopListening();
    expect(requests, isEmpty);
    expect(events.single.$1, 'error');
  });

  test('dừng tay sau khi nói: nhận diện xong rồi mới trả về', () async {
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    await svc.stopListening();
    expect(events, [('text', '先生')]);
  });

  test('Whisper bịa câu cuối video: báo không nhận ra, không đổ chữ', () async {
    reply = (_) async =>
        json({'text': 'ご視聴ありがとうございました。'});
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    await svc.stopListening();
    expect(events.single.$1, 'error');
    expect(events.single.$2, contains('Không nhận ra'));
  });

  test('quyền mic bị từ chối: báo lỗi, trả false, không kẹt', () async {
    mic.startError = Exception('NotAllowedError: Permission denied');
    expect(await listen(), isFalse);
    expect(events.single.$2, contains('Chưa có quyền dùng micro'));
    expect(svc.isListening, isFalse);
    expect(svc.lastError, contains('micro'));
  });

  test('server 429 và mất mạng đều ra câu tiếng Việt', () async {
    reply = (_) async => http.Response('{}', 429);
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    await svc.stopListening();
    expect(events.single.$2, contains('Quá nhiều'));

    events.clear();
    reply = (_) async => throw http.ClientException('offline');
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    await svc.stopListening();
    expect(events.single.$2, contains('kết nối mạng'));
  });

  test('huỷ giữa lúc chờ server: không callback nào nữa', () async {
    final gate = Completer<http.Response>();
    reply = (_) => gate.future;
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    final stopping = svc.stopListening();
    await wait(10);
    expect(processing, 1);
    await svc.cancelListening();
    gate.complete(json({'text': '先生'}));
    await stopping;
    expect(events, isEmpty);
  });

  test('luồng âm thanh báo lỗi giữa chừng: phiên kết thúc bằng lỗi', () async {
    await listen();
    mic.ctrl.addError(Exception('NotReadableError'));
    await wait(20);
    expect(events.single.$1, 'error');
    expect(svc.isListening, isFalse);
    expect(mic.cancels, greaterThan(0));
  });

  test('không gửi đáp án: body chỉ là âm thanh', () async {
    await listen();
    mic.ctrl.add(-10);
    await wait(10);
    await svc.stopListening();
    expect(requests.single.bodyBytes.length, 4096);
  });

  test('không có phiên cũ: mic.start chạy ĐỒNG BỘ trong lời gọi listen', () async {
    final f = listen();
    expect(mic.starts, 1, reason: 'không được await gì trước start()');
    expect(await f, isTrue);
    await svc.cancelListening();
  });

  test('có phiên cũ: huỷ phiên cũ rồi mới ghi phiên mới', () async {
    await listen();
    expect(await listen(), isTrue);
    expect(mic.starts, 2);
    expect(mic.cancels, 1);
    expect(svc.isListening, isTrue);
    await svc.cancelListening();
  });
}
