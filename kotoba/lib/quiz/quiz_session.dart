import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/vocabulary.dart';
import 'answer_tally.dart';

// AnswerState dời sang answer_tally.dart để dùng chung với phiên kanji.
// Xuất lại ở đây để chỗ nào đang import quiz_session vẫn thấy nó.
export 'answer_tally.dart' show AnswerState;

enum QuizMode { write, speak }

class QuizItem {
  QuizItem(this.word);

  final Word word;
  AnswerState state = AnswerState.pending;

  /// Chuỗi anh đã gửi đi — hiện lại cạnh đáp án đúng để thấy mình lệch ở đâu.
  String submitted = '';

  bool get answered => state != AnswerState.pending;
}

/// Một phiên học: danh sách từ, vị trí đang làm, và kết quả.
///
/// Tách khỏi widget để logic phiên học kiểm được bằng unit test, không phải
/// dựng cả màn hình lên mới thử được.
class QuizSession extends ChangeNotifier with AnswerTally {
  QuizSession({
    required List<Word> words,
    required this.lessons,
    required bool shuffle,
    QuizMode mode = QuizMode.write,
    this.title,
    int? seed,
  }) : _mode = mode,
       items = _prepare(words, shuffle, seed);

  final Set<int> lessons;

  /// Tên phiên, khi nó KHÔNG dựng từ một bộ bài.
  ///
  /// Trước đây `lessons` rỗng bị dùng ngầm để nghĩa là "Từ sai". Giờ có thêm
  /// phiên ôn từ đã đánh dấu, mà nó cũng không thuộc bài nào — chồng nghĩa thứ
  /// ba lên một tập rỗng thì không ai đọc ra được. Đặt tên tường minh.
  final String? title;
  final List<QuizItem> items;

  QuizMode _mode;
  QuizMode get mode => _mode;
  set mode(QuizMode m) {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
  }

  int _cursor = 0;
  int get cursor => _cursor;

  static List<QuizItem> _prepare(List<Word> words, bool shuffle, int? seed) {
    final list = words.map(QuizItem.new).toList();
    if (shuffle) {
      // Xáo trộn để tránh nhớ vẹt theo vị trí — "từ thứ 5 là がくせい" không
      // phải là nhớ từ.
      list.shuffle(seed == null ? Random() : Random(seed));
    }
    return list;
  }

  QuizItem? get current => _cursor < items.length ? items[_cursor] : null;

  @override
  Iterable<AnswerState> get answerStates => items.map((i) => i.state);

  List<Word> get wrongWords => items
      .where((i) => i.state == AnswerState.wrong)
      .map((i) => i.word)
      .toList(growable: false);

  void jumpTo(int index) {
    if (index < 0 || index >= items.length) return;
    _cursor = index;
    notifyListeners();
  }

  void submit({required bool correct, required String submitted}) {
    final item = current;
    if (item == null) return;
    item
      ..state = correct ? AnswerState.correct : AnswerState.wrong
      ..submitted = submitted;
    notifyListeners();
  }

  void skip() {
    final item = current;
    if (item == null) return;
    item.state = AnswerState.skipped;
    notifyListeners();
  }

  /// Nhảy tới từ chưa làm gần nhất phía sau con trỏ, vòng lại đầu nếu cần.
  /// Trả về false khi không còn từ nào — lúc đó màn hình chuyển sang tổng kết.
  bool advance() {
    for (var step = 1; step <= items.length; step++) {
      final i = (_cursor + step) % items.length;
      if (!items[i].answered) {
        _cursor = i;
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }
}
