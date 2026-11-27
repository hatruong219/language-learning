/// Trạng thái một câu trong phiên làm bài.
enum AnswerState {
  /// Chưa chạm tới. Khác `skipped`: skipped là đã xem rồi bấm bỏ, pending là
  /// phiên kết thúc trước khi tới lượt nó.
  pending,
  correct,
  wrong,
  skipped,
}

/// Bốn con số của một phiên, tính từ trạng thái từng câu.
///
/// Tách ra một chỗ vì bốn số này PHẢI cộng đúng bằng tổng, và đã từng sai:
/// màn tổng kết chỉ đếm correct + wrong + skipped nên làm 3 từ trong phiên 50
/// rồi thoát thì 47 từ còn lại mất hút. Mọi loại phiên — từ vựng, kanji, ngữ
/// pháp — dùng chung mixin này để không phải sửa cùng một lỗi nhiều lần.
mixin AnswerTally {
  /// Trạng thái của từng câu, theo đúng thứ tự trong phiên.
  Iterable<AnswerState> get answerStates;

  int _count(AnswerState s) => answerStates.where((x) => x == s).length;

  int get total => answerStates.length;
  int get correctCount => _count(AnswerState.correct);
  int get wrongCount => _count(AnswerState.wrong);
  int get skippedCount => _count(AnswerState.skipped);
  int get pendingCount => _count(AnswerState.pending);

  int get answeredCount =>
      answerStates.where((s) => s != AnswerState.pending).length;

  bool get isFinished => answerStates.every((s) => s != AnswerState.pending);
}
