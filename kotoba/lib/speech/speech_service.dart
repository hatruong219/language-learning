import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'mic_recorder.dart';
import 'silence_detector.dart';
import 'stt_client.dart';

/// Mic (ghi âm → Groq Whisper qua `/kotoba-app/api/stt`) và giọng đọc
/// (speechSynthesis của trình duyệt) gom về một chỗ.
///
/// Constructor không đụng plugin nào, nên test VM dựng được `SpeechService()`.
class SpeechService {
  /// [silenceFor] và [maxRecording] chỉ để test rút ngắn thời gian chờ.
  SpeechService({
    MicRecorder? recorder,
    SttClient? stt,
    FlutterTts? tts,
    this.silenceFor = const Duration(milliseconds: 1500),
    this.maxRecording = const Duration(seconds: 8),
  }) : _recorder = recorder ?? RecordMicRecorder(),
       _stt = stt ?? SttClient(),
       _tts = tts ?? FlutterTts();

  static const localeJa = 'ja-JP';

  /// Im lặng liên tục bao lâu thì tự chốt, và trần thời gian một lần ghi.
  /// 8 giây ≈ 256 KB WAV, dưới trần 1 MB của server.
  final Duration silenceFor;
  final Duration maxRecording;
  static const _levelEvery = Duration(milliseconds: 100);

  final MicRecorder _recorder;
  final SttClient _stt;
  final FlutterTts _tts;

  bool _audioConfigured = false;
  String? _lastError;
  _Session? _session;

  bool get isListening => _session != null && !_session!.finishing;

  /// Lý do lần gọi gần nhất hỏng — hiện thẳng lên màn hình thay vì nuốt đi.
  String? get lastError => _lastError;

  /// Chuẩn bị giọng đọc. KHÔNG xin quyền mic ở đây: trình duyệt chỉ hiện hộp xin
  /// quyền khi bắt đầu ghi, và iOS Safari đòi việc đó nằm trong cú chạm.
  Future<bool> init() async {
    if (_audioConfigured) return true;
    try {
      await _tts.setLanguage(localeJa);
      await _tts.awaitSpeakCompletion(true);
      _audioConfigured = true;
    } on Object catch (e) {
      _lastError = 'Không dùng được giọng đọc trên thiết bị này.';
      debugPrint('tts khởi tạo lỗi: $e');
    }
    return true;
  }

  /// Bắt đầu nghe một lần. Kết quả đi về qua [onResult] đúng một lần
  /// (`isFinal` luôn true), hoặc [onError] — luôn đúng một trong hai, để giao
  /// diện không bao giờ kẹt ở "Đang nghe…".
  ///
  /// Không tự chấm điểm ở đây: chữ đi ra màn xem lại, người dùng sửa được.
  /// Trả `false` nếu không mở được mic (đã gọi [onError]).
  Future<bool> listen({
    required void Function(String text, bool isFinal) onResult,
    void Function(double level)? onLevel,
    void Function()? onProcessing,
    void Function(String message)? onError,
  }) async {
    // Chỉ chờ huỷ khi THỰC SỰ có phiên cũ: mỗi `await` là một lần nhả lại
    // event loop, mà start() phải chạy đồng bộ trong cú chạm (iOS).
    if (_session != null) await cancelListening();
    _lastError = null;
    final s = _Session(
      SilenceDetector(silenceFor: silenceFor),
      onResult,
      onLevel,
      onProcessing,
      onError,
    );
    _session = s;
    try {
      // Gọi start() ngay, không `await` gì trước đó: iOS Safari chỉ xin quyền
      // mic được trong cử chỉ người dùng.
      await _recorder.start();
    } on Object catch (e) {
      debugPrint('mic.start lỗi: $e');
      if (_session == s) _session = null;
      s.fail(_micError(e), this);
      return false;
    }
    if (_session != s) {
      // Bị huỷ trong lúc xin quyền: mic vừa mở xong, phải tắt đi.
      await _recorder.cancel();
      return true;
    }
    final clock = Stopwatch()..start();
    s.levels = _recorder.levels(_levelEvery).listen((db) {
      onLevel?.call(db);
      if (s.detector.add(db, clock.elapsed)) unawaited(_finish(s));
    }, onError: (Object e) => unawaited(_abort(s, _micError(e))));
    s.cap = Timer(maxRecording, () => unawaited(_finish(s)));
    return true;
  }

  /// Dừng ghi và nhận diện những gì đã ghi. Hoàn tất khi đã có kết quả/lỗi.
  Future<void> stopListening() async {
    final s = _session;
    if (s != null) await _finish(s);
  }

  /// Huỷ phiên, bỏ âm thanh, không gọi callback nào nữa.
  Future<void> cancelListening() async {
    final s = _session;
    if (s == null) return;
    _session = null;
    await s.teardown();
    try {
      await _recorder.cancel();
    } on Object catch (e) {
      debugPrint('mic.cancel lỗi: $e');
    }
  }

  Future<void> _abort(_Session s, String message) async {
    if (_session != s) return;
    _session = null;
    await s.teardown();
    try {
      await _recorder.cancel();
    } on Object catch (e) {
      debugPrint('mic.cancel lỗi: $e');
    }
    s.fail(message, this);
  }

  /// Giữ `_session == s` suốt lúc nhận diện để [cancelListening] huỷ được cả
  /// lượt đang chờ server: bị huỷ thì mọi `await` dưới đây kết thúc im lặng.
  Future<void> _finish(_Session s) async {
    if (_session != s || s.finishing) return;
    s.finishing = true;
    await s.teardown();
    Uint8List? wav;
    try {
      wav = await _recorder.stop();
    } on Object catch (e) {
      debugPrint('mic.stop lỗi: $e');
      return _end(s, 'Không thu được âm thanh. Kiểm tra micro.');
    }
    if (_session != s) return;
    // Chưa từng nghe thấy tiếng → không gửi: tiết kiệm lượt Groq và tránh việc
    // Whisper "bịa" câu chào cuối video ra từ tiếng ồn.
    if (!s.detector.heardSpeech || wav == null) {
      return _end(s, 'Không nghe thấy giọng nói.');
    }
    s.onProcessing?.call();
    try {
      final text = cleanTranscript(await _stt.transcribe(wav));
      if (_session != s) return;
      if (text.isEmpty) {
        return _end(s, 'Không nhận ra từ nào. Thử đọc lại rõ hơn.');
      }
      _session = null;
      s.onResult(text, true);
    } on SttException catch (e) {
      _end(s, e.message);
    } on Object catch (e) {
      debugPrint('stt lỗi bất ngờ: $e');
      _end(s, 'Không nhận diện được giọng nói. Thử lại.');
    }
  }

  /// Kết thúc phiên bằng lỗi (trừ khi đã bị huỷ).
  void _end(_Session s, String message) {
    if (_session != s) return;
    _session = null;
    s.fail(message, this);
  }

  /// Trình duyệt ném `NotAllowedError` / `PermissionDeniedError` khi từ chối.
  static String _micError(Object e) {
    final t = e.toString();
    if (t.contains('NotAllowed') || t.contains('PermissionDenied')) {
      return 'Chưa có quyền dùng micro. Bật lại trong cài đặt trang web của trình duyệt.';
    }
    if (t.contains('NotFound')) return 'Không tìm thấy micro trên thiết bị.';
    return 'Không mở được micro.';
  }

  /// Đọc một từ bằng giọng Nhật. [rate] theo thang cũ của app (0–1, 0.5 là
  /// bình thường); speechSynthesis của trình duyệt dùng thang 1 = bình thường
  /// và flutter_tts web chuyển nguyên giá trị, nên nhân đôi cho khớp.
  Future<void> speak(
    String text, {
    double rate = 0.45,
    double volume = 1.0,
  }) async {
    if (text.trim().isEmpty) return;
    if (!_audioConfigured) await init();
    try {
      await _tts.stop();
      await _tts.setLanguage(localeJa);
      await _tts.setSpeechRate(rate * 2);
      await _tts.setVolume(volume.clamp(0.0, 1.0));
      await _tts.speak(text);
    } on Object catch (e) {
      _lastError = 'Không đọc được từ này.';
      debugPrint('tts.speak lỗi: $e');
    }
  }

  Future<void> stopSpeaking() => _tts.stop();

  Future<void> dispose() async {
    await cancelListening();
    await _tts.stop();
    await _recorder.dispose();
    _stt.close();
  }
}

/// Trạng thái một lần nghe.
class _Session {
  _Session(
    this.detector,
    this.onResult,
    this.onLevel,
    this.onProcessing,
    this.onError,
  );

  final void Function(String text, bool isFinal) onResult;
  final void Function(double level)? onLevel;
  final void Function()? onProcessing;
  final void Function(String message)? onError;

  final SilenceDetector detector;
  StreamSubscription<double>? levels;
  Timer? cap;
  bool finishing = false;

  Future<void> teardown() async {
    cap?.cancel();
    await levels?.cancel();
  }

  void fail(String message, SpeechService svc) {
    svc._lastError = message;
    onError?.call(message);
  }
}
