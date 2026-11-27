import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import 'blob_url.dart';

/// Mic gói sau một giao diện nhỏ để `SpeechService` test được bằng bản giả —
/// test VM không có micro thật.
abstract class MicRecorder {
  /// Bắt đầu ghi. Ném lỗi nếu không mở được mic (từ chối quyền, không có mic).
  /// Phải gọi thẳng từ cú chạm của người dùng: iOS Safari chỉ cho xin quyền mic
  /// trong cử chỉ, đừng chèn `await` nào khác phía trước.
  Future<void> start();

  /// Mức âm thanh (dBFS, âm; im lặng ~ -60, nói to ~ -10) theo từng khoảng.
  Stream<double> levels(Duration every);

  /// Dừng và lấy toàn bộ WAV. Null nếu chưa ghi được gì.
  Future<Uint8List?> stop();

  /// Dừng và bỏ âm thanh.
  Future<void> cancel();

  Future<void> dispose();
}

/// Bản thật, dùng package `record` (web: AudioWorklet, WAV PCM16 16 kHz mono).
/// Một định dạng cho mọi trình duyệt, né khác biệt webm (Chrome) / mp4 (Safari)
/// của MediaRecorder. 8 giây ≈ 256 KB, dưới trần 1 MB của server.
class RecordMicRecorder implements MicRecorder {
  RecordMicRecorder({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Dựng lười: constructor của AudioRecorder đụng vào plugin, mà test VM
  /// dựng `SpeechService()` mà không bao giờ ghi âm.
  AudioRecorder? _rec;
  AudioRecorder get _recorder => _rec ??= AudioRecorder();

  @override
  Future<void> start() => _recorder.start(
    const RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    ),
    path: '',
  );

  @override
  Stream<double> levels(Duration every) =>
      _recorder.onAmplitudeChanged(every).map((a) => a.current);

  @override
  Future<Uint8List?> stop() async {
    final url = await _recorder.stop();
    if (url == null) return null;
    // Trên web `stop()` trả blob URL; http (BrowserClient) đọc được `blob:`.
    try {
      final res = await _client.get(Uri.parse(url));
      return res.bodyBytes;
    } finally {
      revokeBlobUrl(url); // đọc xong (hay lỗi) đều phải trả bộ nhớ
    }
  }

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<void> dispose() async {
    await _rec?.dispose();
    _client.close();
  }
}
