import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/kanji_words.dart';
import 'package:mnn_flashcard/quiz/answer_tally.dart';
import 'package:mnn_flashcard/quiz/kanji_quiz.dart';

import 'support/asset_fixtures.dart';

/// Đề kanji sai kiểu thì người học không phát hiện được — họ tưởng mình yếu.
/// Nên khoá lại bằng test: đáp án phải nằm trong phương án, phương án không
/// trùng nhau, và nhiễu phải khó thật chứ không loại được bằng độ dài.
void main() {
  late KanjiWordSet set;

  setUpAll(() => set = loadKanjiWordsFixture());

  KanjiQuizBuilder builder({int seed = 7}) => KanjiQuizBuilder(set, seed: seed);

  test('dựng đủ số câu yêu cầu, mặc định 10', () {
    expect(KanjiQuizBuilder.defaultLength, 10);
    expect(builder().build().length, 10);
    expect(builder().build(count: 25).length, 25);
    expect(builder().build(count: 1).length, 1);
  });

  test('mỗi câu có đúng 4 phương án, chứa đáp án, không trùng', () {
    for (final q in builder().build(count: 60)) {
      expect(q.options.length, KanjiQuizBuilder.optionCount);
      expect(q.options, contains(q.answer));
      expect(
        q.options.toSet().length,
        q.options.length,
        reason: 'trùng phương án',
      );
      expect(q.prompt, isNotEmpty);
      expect(q.answer, isNot(equals(q.prompt)));
    }
  });

  test('hai dạng đề đặt prompt và đáp án đúng chiều', () {
    for (final q in builder().build(count: 60)) {
      if (q.kind == KanjiQuizKind.reading) {
        // 漢字読み: đề là dạng kanji, đáp án là kana.
        expect(q.prompt, q.word.word);
        expect(q.answer, q.word.kana);
        expect(RegExp(r'[一-鿿]').hasMatch(q.prompt), isTrue);
      } else {
        // 表記: đề là kana, đáp án là dạng kanji.
        expect(q.prompt, q.word.kana);
        expect(q.answer, q.word.word);
        expect(RegExp(r'[一-鿿]').hasMatch(q.answer), isTrue);
      }
    }
  });

  test('nghĩa tiếng Việt hiện sẵn, không giấu sau nút', () {
    for (final q in builder().build(count: 40)) {
      expect(q.meaning, isNotEmpty);
    }
  });

  test('một từ chỉ hỏi một lần trong phiên', () {
    final qs = builder().build(count: 80);
    final ids = qs.map((q) => q.word.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('nhiễu KHÓ: phần lớn câu có nhiễu cùng chứa một chữ với đáp án', () {
    final kanjiOnly = RegExp(r'[一-鿿]');
    var hard = 0;
    final qs = builder().build(count: 80);
    for (final q in qs) {
      final chars = kanjiOnly
          .allMatches(q.word.word)
          .map((m) => m.group(0)!)
          .toSet();
      // Với dạng 表記 nhiễu là dạng kanji nên soi trực tiếp được; với 漢字読み
      // nhiễu là kana nên phải soi qua từ gốc, ở đây chỉ đếm dạng 表記.
      if (q.kind != KanjiQuizKind.writing) continue;
      final others = q.options.where((o) => o != q.answer);
      if (others.any(
        (o) => kanjiOnly.allMatches(o).any((m) => chars.contains(m.group(0))),
      )) {
        hard++;
      }
    }
    final writing = qs.where((q) => q.kind == KanjiQuizKind.writing).length;
    expect(writing, greaterThan(10), reason: 'phải có đủ câu 表記 để đo');
    expect(
      hard / writing,
      greaterThan(0.6),
      reason: 'nhiễu quá dễ: chỉ $hard/$writing câu có nhiễu cùng chữ',
    );
  });

  test('lọc từ ghép thì chỉ ra từ từ 2 chữ trở lên', () {
    final qs = builder().build(count: 40, onlyCompound: true);
    expect(qs, isNotEmpty);
    for (final q in qs) {
      expect(q.word.chars.length, greaterThanOrEqualTo(2), reason: q.word.word);
    }
  });

  test('mọi từ ra đề đều có ít nhất một chữ Hán', () {
    // PDF cố ý viết chữ ngoài phạm vi bằng kana (家ちん). Từ nào không còn chữ
    // Hán nào thì hỏi kanji vô nghĩa.
    for (final q in builder().build(count: 200)) {
      expect(q.word.hasKanji, isTrue, reason: q.word.word);
    }
  });

  test('lọc một dạng thì chỉ ra dạng đó', () {
    final only = builder().build(count: 30, kinds: {KanjiQuizKind.reading});
    expect(only.every((q) => q.kind == KanjiQuizKind.reading), isTrue);
  });

  test('cùng seed ra cùng đề — cần cho việc dựng lại khi debug', () {
    final a = builder(seed: 42).build(count: 12);
    final b = builder(seed: 42).build(count: 12);
    expect(
      a.map((q) => '${q.word.id}|${q.answer}|${q.options.join()}'),
      b.map((q) => '${q.word.id}|${q.answer}|${q.options.join()}'),
    );
  });

  group('phiên kiểm tra', () {
    test('bốn con số luôn cộng đúng bằng tổng', () {
      final s = KanjiQuizSession(builder().build(count: 10));
      int sum() =>
          s.correctCount + s.wrongCount + s.skippedCount + s.pendingCount;

      expect(s.pendingCount, 10);
      expect(sum(), s.total);

      s.answer(s.current!.answer);
      s.advance();
      s.answer(s.current!.options.firstWhere((o) => o != s.current!.answer));
      s.advance();
      s.skip();
      s.advance();

      expect(s.correctCount, 1);
      expect(s.wrongCount, 1);
      expect(s.skippedCount, 1);
      expect(s.pendingCount, 7);
      expect(sum(), s.total);
      expect(s.isFinished, isFalse);
    });

    test('sai thì ghi nợ CẢ TỪ, không tách ra chữ', () {
      final s = KanjiQuizSession(builder().build(count: 5));
      final asked = s.current!;
      s.answer(asked.options.firstWhere((o) => o != asked.answer));
      expect(s.wrongWords.map((w) => w.id), [asked.word.id]);
      expect(s.wrongWords.first.hasKanji, isTrue);
    });

    test('làm hết thì isFinished và không còn câu chưa làm', () {
      final s = KanjiQuizSession(builder().build(count: 6));
      var moved = true;
      for (var i = 0; i < 6; i++) {
        s.answer(s.current!.answer);
        moved = s.advance();
      }
      expect(s.isFinished, isTrue);
      expect(s.pendingCount, 0);
      expect(s.correctCount, 6);
      // Hợp đồng: hết câu thì advance trả false và GIỮ NGUYÊN con trỏ. Giao
      // diện rời màn theo giá trị này, không chờ current thành null — để null
      // thì màn hình dựng lại với câu rỗng một khung hình trước khi chuyển.
      expect(moved, isFalse);
      expect(s.current, isNotNull);
      expect(s.current!.answered, isTrue);
    });

    test('advance nhảy qua câu đã làm, vòng lại đầu', () {
      final s = KanjiQuizSession(builder().build(count: 3));
      s.answer(s.current!.answer); // câu 0
      expect(s.advance(), isTrue);
      expect(s.cursor, 1);
      s.skip(); // câu 1
      expect(s.advance(), isTrue);
      expect(s.cursor, 2);
      s.answer(s.current!.answer);
      expect(s.advance(), isFalse, reason: 'hết câu thì trả false');
    });

    test('trạng thái từng câu đúng sau khi chọn', () {
      final s = KanjiQuizSession(builder().build(count: 4));
      final q = s.current!;
      expect(s.answer(q.answer), isTrue);
      expect(q.state, AnswerState.correct);
      expect(q.chosen, q.answer);
    });
  });
}
