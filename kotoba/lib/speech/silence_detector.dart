/// Quyết định lúc nào ngừng ghi âm, thuần logic để test không cần mic.
///
/// Chỉ tính "im lặng" SAU KHI đã nghe thấy tiếng: im ngay từ đầu thì cứ chờ
/// (trần thời gian do người gọi giữ). Nhờ vậy người ngập ngừng lúc đầu không
/// bị cắt, còn người không nói gì thì không bao giờ bị gửi lên server.
class SilenceDetector {
  SilenceDetector({
    this.speechDb = -35,
    this.silenceFor = const Duration(milliseconds: 1500),
  });

  /// Ngưỡng dBFS coi là có tiếng nói (im lặng ~ -50..-60, nói bình thường
  /// ~ -25..-10).
  final double speechDb;

  /// Im lặng liên tục bao lâu thì chốt.
  final Duration silenceFor;

  bool _heardSpeech = false;
  Duration? _quietSince;

  /// Đã từng vượt ngưỡng chưa. False thì KHÔNG được gửi âm thanh lên server.
  bool get heardSpeech => _heardSpeech;

  /// Nạp một mẫu mức âm thanh tại thời điểm [at] kể từ lúc bắt đầu ghi.
  /// Trả true khi đã đến lúc dừng.
  bool add(double db, Duration at) {
    if (db > speechDb) {
      _heardSpeech = true;
      _quietSince = null;
      return false;
    }
    _quietSince ??= at;
    return _heardSpeech && at - _quietSince! >= silenceFor;
  }
}
