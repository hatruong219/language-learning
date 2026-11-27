import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/progress_store.dart';
import 'package:mnn_flashcard/data/study_stats.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';

/// Thống kê học tập.
///
/// Số liệu ở đây quyết định người học ôn lại từ nào, nên sai một phép đếm là
/// dẫn họ đi ôn nhầm chỗ — mà con số nào cũng trông hợp lý nên không ai nghi.
void main() {
  late Vocabulary vocab;
  late List<Word> words;

  setUpAll(() {
    vocab = Vocabulary.fromJson(
      jsonDecode(File('assets/vocabulary.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    words = vocab.byLessons({1}).take(6).toList();
  });

  ProgressStore withRecords(Map<int, (int correct, int wrong)> spec) {
    final p = ProgressStore.inMemory();
    for (final e in spec.entries) {
      final id = words[e.key].id;
      for (var i = 0; i < e.value.$1; i++) {
        p.record(id, correct: true);
      }
      for (var i = 0; i < e.value.$2; i++) {
        p.record(id, correct: false);
      }
    }
    return p;
  }

  test('chưa kiểm từ nào thì rỗng, mọi con số bằng 0', () {
    final s = StudyStats.of(ProgressStore.inMemory(), vocab);
    expect(s.isEmpty, isTrue);
    expect(s.testedCount, 0);
    expect(s.totalAttempts, 0);
    expect(s.accuracy, 0, reason: 'không được chia cho 0');
  });

  test('từ mới ĐÁNH DẤU mà chưa kiểm lần nào thì không vào thống kê', () {
    // Đánh dấu là ý định, không phải kết quả. Đếm nó vào đây thì một người
    // đánh dấu 50 từ để học sau sẽ thấy "50 từ đã kiểm" — sai sự thật.
    final p = ProgressStore.inMemory()..setStarred(words[0].id, true);
    expect(StudyStats.of(p, vocab).isEmpty, isTrue);
  });

  test('đếm đúng lượt và số sai của từng từ', () {
    final s = StudyStats.of(withRecords({0: (3, 2), 1: (5, 0)}), vocab);
    expect(s.testedCount, 2);

    final a = s.words.firstWhere((w) => w.word.id == words[0].id);
    expect(a.correct, 3);
    expect(a.wrong, 2);
    expect(a.attempts, 5);
    expect(a.accuracy, closeTo(0.6, 0.001));

    final b = s.words.firstWhere((w) => w.word.id == words[1].id);
    expect(b.wrong, 0);
    expect(b.accuracy, 1);
  });

  test('tổng cộng khớp với tổng từng từ', () {
    final s = StudyStats.of(
      withRecords({0: (3, 2), 1: (5, 0), 2: (0, 4)}),
      vocab,
    );
    expect(s.totalAttempts, 14);
    expect(s.totalWrong, 6);
    expect(s.totalCorrect, 8);
    expect(s.accuracy, closeTo(8 / 14, 0.001));
    expect(s.needWork.length, 2, reason: 'chỉ từ 0 và 2 còn sai');
    expect(s.cleanCount, 1);
    expect(
      s.totalCorrect + s.totalWrong,
      s.totalAttempts,
      reason: 'đúng + sai phải bằng tổng lượt',
    );
  });

  test('tỉ lệ chung tính trên TỔNG LƯỢT, không phải trung bình từng từ', () {
    // Từ A: 1 lượt, sai. Từ B: 19 lượt, đúng hết.
    // Trung bình tỉ lệ từng từ = (0 + 1) / 2 = 50% — sai lệch hẳn.
    // Trên tổng lượt = 19/20 = 95% — đúng với thực tế học.
    final s = StudyStats.of(withRecords({0: (0, 1), 1: (19, 0)}), vocab);
    expect(s.accuracy, closeTo(0.95, 0.001));
  });

  group('thứ tự đáng lo', () {
    test('sai nhiều nhất lên đầu', () {
      final s = StudyStats.of(
        withRecords({0: (10, 1), 1: (0, 5), 2: (3, 3)}),
        vocab,
      );
      expect(s.words.map((w) => w.wrong).toList(), [5, 3, 1]);
    });

    test('sai bằng nhau thì tỉ lệ đúng thấp hơn lên trước', () {
      // Sai 3/4 lượt đáng lo hơn sai 3/20 lượt, dù cùng sai 3.
      final s = StudyStats.of(withRecords({0: (17, 3), 1: (1, 3)}), vocab);
      expect(s.words.first.word.id, words[1].id);
      expect(s.words.first.attempts, 4);
    });
  });

  test('id không còn từ tương ứng thì bỏ qua, không nổ', () {
    // Nhập file sao lưu cũ, hoặc giáo trình đổi id.
    final p = ProgressStore.inMemory()
      ..record('khong-ton-tai-dau-ca', correct: false)
      ..record(words[0].id, correct: true);
    final s = StudyStats.of(p, vocab);
    expect(s.testedCount, 1);
    expect(s.words.single.word.id, words[0].id);
  });

  test('duyệt thống kê trong lúc ghi thêm tiến độ thì không nổ', () {
    // entries trả bản chụp chứ không phải khung nhìn sống. Trả khung nhìn sống
    // thì vòng lặp này ném ConcurrentModificationError.
    final p = withRecords({0: (1, 1), 1: (1, 1)});
    expect(() {
      for (final e in p.entries) {
        p.record(e.key, correct: true);
      }
    }, returnsNormally);
  });
}
