import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/sync_service.dart' show apiBase;

/// Lỗi nhận diện đã đổi sang câu hiển thị thẳng được lên màn hình.
class SttException implements Exception {
  const SttException(this.message);
  final String message;

  @override
  String toString() => 'SttException: $message';
}

/// Gửi âm thanh lên `/kotoba-app/api/stt` rồi lấy chữ về. Thuần Dart để test
/// bằng `MockClient`.
///
/// Tuyệt đối không gửi đáp án kèm theo: server chỉ nhận âm thanh thô, để
/// Whisper không bị "mớm" từ cần nghe ra.
class SttClient {
  SttClient({http.Client? client, String? url})
    // Dùng chung `apiBase` với đồng bộ (mặc định `/kotoba-app`, cùng nguồn);
    // ghi đè bằng KOTOBA_API_BASE khi dev.
    : _client = client ?? http.Client(),
      _url = Uri.parse(url ?? '$apiBase/api/stt');

  final http.Client _client;
  final Uri _url;

  static const _timeout = Duration(seconds: 20);

  Future<String> transcribe(Uint8List bytes, {String mime = 'audio/wav'}) async {
    final http.Response res;
    try {
      res = await _client
          .post(_url, headers: {'Content-Type': mime}, body: bytes)
          .timeout(_timeout);
    } on TimeoutException {
      throw const SttException('Mạng phản hồi quá chậm. Thử lại.');
    } on http.ClientException catch (e) {
      debugPrint('stt mạng lỗi: $e');
      throw const SttException('Cần kết nối mạng để nhận diện giọng nói.');
    }

    if (res.statusCode != 200) {
      debugPrint('stt trả ${res.statusCode}');
      throw SttException(_messageFor(res.statusCode));
    }
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final text = body is Map ? body['text'] : null;
      if (text is String) return text;
    } on FormatException catch (e) {
      debugPrint('stt trả JSON hỏng: $e');
    }
    throw const SttException('Máy chủ trả kết quả không đọc được. Thử lại.');
  }

  static String _messageFor(int status) => switch (status) {
    400 => 'Không thu được âm thanh. Kiểm tra micro.',
    403 => 'Máy chủ từ chối yêu cầu nhận diện.',
    413 => 'Đoạn ghi âm quá dài. Nói ngắn hơn rồi thử lại.',
    415 => 'Trình duyệt này ghi âm ở định dạng chưa hỗ trợ.',
    429 => 'Quá nhiều lượt nhận diện. Thử lại sau ít phút.',
    _ => 'Máy chủ nhận diện giọng nói không phản hồi. Thử lại.',
  };

  void close() => _client.close();
}

/// Câu Whisper hay "bịa" ra khi gặp tiếng ồn hoặc im lặng (học từ dữ liệu phụ
/// đề video). Sau khi bỏ dấu câu mà trùng thì coi như không nghe được gì.
const _hallucinations = <String>{
  'ご視聴ありがとうございました',
  'ご視聴ありがとうございます',
  'ご清聴ありがとうございました',
  'チャンネル登録お願いします',
};

/// Dấu câu và khoảng trắng Whisper chèn thêm (Nhật, Latin, toàn rộng). Không
/// đụng tới `ー`: nó nằm giữa từ katakana (テープ) là chữ thật.
final _noise = RegExp(r'[\s。、，．,.！!？?「」『』（）()・…～~]+');

/// Bỏ dấu câu/khoảng trắng để so với từ điển và đáp án: Whisper trả "先生。"
/// trong khi từ điển chỉ có "先生".
String cleanTranscript(String raw) {
  final text = raw.replaceAll(_noise, '');
  return _hallucinations.contains(text) ? '' : text;
}
