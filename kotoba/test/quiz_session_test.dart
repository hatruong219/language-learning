import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';
import 'package:mnn_flashcard/quiz/quiz_session.dart';

Word _w(String reading, String meaning, {int lesson = 1}) => Word(
  id: '$lesson:$reading',
  lesson: lesson,
  word: reading,
  reading: reading,
  romaji: '',
  meaning: meaning,
  posVi: 'danh từ',
);

QuizSession _session(int n, {bool shuffle = false}) => QuizSession(
  words: [for (var i = 0; i < n; i++) _w('から$i', 'nghĩa $i')],
  lessons: {1},
  shuffle: shuffle,
  seed: 42,
);

void main() {
  test('phiên mới thì chưa từ nào được trả lời', () {
    final s = _session(5);
    expect(s.total, 5);
    expect(s.answeredCount, 0);
    expect(s.isFinished, isFalse);
    expect(s.current, isNotNull);
  });

  test('trả lời đúng và sai được đếm riêng', () {
    final s = _session(3);
    s.submit(correct: true, submitted: 'から0');
    s.advance();
    s.submit(correct: false, submitted: 'sai');
    expect(s.correctCount, 1);
    expect(s.wrongCount, 1);
    expect(s.answeredCount, 2);
  });

  test('bỏ qua tính riêng, không tính là sai', () {
    final s = _session(3);
    s.skip();
    expect(s.skippedCount, 1);
    expect(s.wrongCount, 0);
    expect(s.answeredCount, 1);
  });

  test('advance nhảy qua từ đã trả lời và vòng lại đầu', () {
    final s = _session(3);
    s.jumpTo(2);
    s.submit(correct: true, submitted: 'x');
    expect(s.advance(), isTrue);
    expect(s.cursor, 0, reason: 'phải vòng về đầu vì cuối đã xong');
  });

  test('advance trả về false khi hết từ, và phiên báo đã xong', () {
    final s = _session(2);
    s.submit(correct: true, submitted: 'a');
    s.advance();
    s.submit(correct: false, submitted: 'b');
    expect(s.advance(), isFalse);
    expect(s.isFinished, isTrue);
  });

  test('wrongWords chỉ gồm từ sai, không gồm từ bỏ qua', () {
    final s = _session(3);
    s.submit(correct: false, submitted: 'x');
    s.advance();
    s.skip();
    s.advance();
    s.submit(correct: true, submitted: 'z');
    expect(s.wrongWords.length, 1);
  });

  test('xáo trộn cùng seed cho cùng thứ tự — phiên học lặp lại được', () {
    final a = _session(20, shuffle: true).items.map((i) => i.word.id).toList();
    final b = _session(20, shuffle: true).items.map((i) => i.word.id).toList();
    expect(a, b);
  });

  test('đổi chế độ viết/đọc giữa chừng không mất tiến độ', () {
    final s = _session(3);
    s.submit(correct: true, submitted: 'a');
    s.mode = QuizMode.speak;
    expect(s.correctCount, 1);
    expect(s.mode, QuizMode.speak);
  });

  // Bug thật gặp trên máy: làm 3 từ trong phiên 50 rồi thoát, màn tổng kết hiện
  // "3 đúng · 0 sai · 0 bỏ qua" — 47 từ còn lại không nằm ở đâu cả. Nguyên nhân
  // là chỉ đếm correct/wrong/skipped, không đếm `pending`. Bốn số phải luôn
  // cộng đúng bằng total, ở MỌI trạng thái của phiên.
  test('bốn con số luôn cộng đúng bằng tổng', () {
    final s = _session(50);
    int sum() =>
        s.correctCount + s.wrongCount + s.skippedCount + s.pendingCount;

    expect(s.pendingCount, 50, reason: 'phiên mới thì chưa làm gì');
    expect(sum(), s.total);

    s.submit(correct: true, submitted: 'x');
    s.advance();
    s.submit(correct: false, submitted: 'y');
    s.advance();
    s.skip();
    s.advance();

    expect(s.correctCount, 1);
    expect(s.wrongCount, 1);
    expect(s.skippedCount, 1);
    expect(s.pendingCount, 47, reason: 'thoát giữa chừng: 47 từ chưa tới lượt');
    expect(sum(), s.total);
  });

  test('làm hết phiên thì không còn từ nào chưa làm', () {
    final s = _session(4);
    for (var i = 0; i < 4; i++) {
      s.submit(correct: i.isEven, submitted: 'x');
      s.advance();
    }
    expect(s.isFinished, isTrue);
    expect(s.pendingCount, 0);
    expect(s.correctCount + s.wrongCount, 4);
  });
}
