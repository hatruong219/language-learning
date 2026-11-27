import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnn_flashcard/speech/stt_client.dart';

void main() {
  final wav = Uint8List.fromList(List.filled(2048, 1));

  SttClient clientFor(MockClientHandler h) =>
      SttClient(client: MockClient(h), url: 'https://x.test/kotoba-app/api/stt');

  Future<String> errorOf(SttClient c) async {
    try {
      await c.transcribe(wav);
    } on SttException catch (e) {
      return e.message;
    }
    fail('phải ném SttException');
  }

  test('gửi nguyên âm thanh với Content-Type audio/wav, đọc {text}', () async {
    late http.Request seen;
    final c = clientFor((req) async {
      seen = req;
      return http.Response.bytes(
        utf8.encode(jsonEncode({'text': '先生。'})),
        200,
      );
    });
    expect(await c.transcribe(wav), '先生。');
    expect(seen.method, 'POST');
    expect(seen.url.path, '/kotoba-app/api/stt');
    expect(seen.headers['Content-Type'], startsWith('audio/wav'));
    expect(seen.bodyBytes, wav);
  });

  test('URL mặc định cùng nguồn: /kotoba-app/api/stt', () async {
    late http.Request seen;
    final c = SttClient(
      client: MockClient((req) async {
        seen = req;
        return http.Response.bytes(utf8.encode(jsonEncode({'text': 'x'})), 200);
      }),
    );
    await c.transcribe(wav);
    expect(seen.url.toString(), '/kotoba-app/api/stt');
  });

  group('map lỗi sang câu tiếng Việt', () {
    for (final (status, expected) in [
      (413, 'quá dài'),
      (415, 'định dạng'),
      (429, 'Quá nhiều'),
      (502, 'Thử lại'),
      (500, 'Thử lại'),
    ]) {
      test('HTTP $status', () async {
        final c = clientFor(
          (_) async => http.Response(jsonEncode({'error': 'x'}), status),
        );
        expect(await errorOf(c), contains(expected));
      });
    }

    test('mất mạng', () async {
      final c = clientFor((_) async => throw http.ClientException('offline'));
      expect(await errorOf(c), contains('kết nối mạng'));
    });

    test('quá thời gian', () async {
      final c = clientFor((_) async => throw TimeoutException('slow'));
      expect(await errorOf(c), contains('quá chậm'));
    });

    test('200 nhưng JSON hỏng hoặc thiếu text', () async {
      expect(
        await errorOf(clientFor((_) async => http.Response('<html>', 200))),
        contains('không đọc được'),
      );
      expect(
        await errorOf(clientFor((_) async => http.Response('{}', 200))),
        contains('không đọc được'),
      );
    });
  });

  group('cleanTranscript', () {
    test('bỏ dấu câu và khoảng trắng', () {
      expect(cleanTranscript('先生。'), '先生');
      expect(cleanTranscript(' せんせい、 '), 'せんせい');
      expect(cleanTranscript('せ ん せ い！？'), 'せんせい');
      expect(cleanTranscript('hello.'), 'hello');
    });

    test('giữ dấu kéo dài trong katakana', () {
      expect(cleanTranscript('テープ。'), 'テープ');
    });

    test('câu Whisper hay bịa thì coi như rỗng', () {
      expect(cleanTranscript('ご視聴ありがとうございました。'), '');
      expect(cleanTranscript('。'), '');
    });
  });
}
