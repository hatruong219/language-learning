import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/grammar.dart';
import 'package:mnn_flashcard/quiz/answer_tally.dart';
import 'package:mnn_flashcard/quiz/grammar_quiz.dart';

import 'support/asset_fixtures.dart';

/// Bộ dựng đề ngữ pháp.
///
/// Phần đáng ngờ nhất là luật khoét trợ từ: nó nhận trợ từ bằng cách nhìn ký tự
/// đứng trước, KHÔNG tách từ. Nên ở đây quét cả 1247 câu chứ không kiểm vài câu
/// mẫu — khoét nhầm vào giữa một từ thì đề không còn đáp án đúng nào, mà lỗi đó
/// chỉ lộ ra ở đúng câu bị nhầm.
void main() {
  late GrammarSet grammar;

  setUpAll(() => grammar = loadGrammarFixture());

  test('bản đóng gói đủ 50 bài, đúng số mẫu và số câu', () {
    expect(grammar.lessons.length, 50);
    expect(grammar.patterns.length, 252);
    expect(grammar.sentences.length, 1247);
    // Bài nào cũng phải có mẫu; bài rỗng thì màn danh sách hiện một dòng bấm
    // vào chẳng có gì.
    for (final n in grammar.lessons) {
      expect(grammar.byLesson(n), isNotEmpty, reason: 'bài $n rỗng');
    }
  });

  test('bản đóng gói dùng ĐÚNG tên trường mà API trả về', () {
    // Bản đóng gói và bản tải về đi qua CÙNG một bộ đọc. Đổi tên trường ở
    // tools/build-grammar-asset.py mà quên đổi ở app/api/kotoba/grammar/route.ts
    // (hoặc ngược lại) thì đường này vẫn chạy, đường kia im lặng trả về rỗng —
    // và chỉ lộ ra khi người dùng bấm đồng bộ.
    //
    // Sửa danh sách dưới đây thì PHẢI sửa cả route.ts bên web-mgmt-platform.
    final doc =
        jsonDecode(File('assets/grammar.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(doc.keys.toSet(), {
      'source',
      'counts',
      'lessons',
      'grammar',
      'sentences',
    });
    expect((doc['counts'] as Map).keys.toSet(), {
      'lessons',
      'grammar',
      'sentences',
    });
    expect(((doc['lessons'] as List).first as Map).keys.toSet(), {
      'n',
      'title',
      'situation',
    });
    expect(((doc['grammar'] as List).first as Map).keys.toSet(), {
      'lesson',
      'ord',
      'pattern',
      'explain',
      'example_ja',
      'example_vi',
    });
    expect(((doc['sentences'] as List).first as Map).keys.toSet(), {
      'lesson',
      'grammar',
      'ja_kanji',
      'ja_kana',
      'vi',
      'has_furigana',
      'ord',
    });
  });

  test('câu ví dụ trỏ đúng về mẫu ngữ pháp của nó', () {
    final linked = grammar.sentences.where((s) => s.grammarKey != null);
    expect(linked.length, grammar.sentences.length);

    var withExamples = 0;
    for (final p in grammar.patterns) {
      final examples = grammar.sentencesOf(p);
      if (examples.isEmpty) continue;
      withExamples++;
      for (final s in examples) {
        expect(s.lesson, p.lesson, reason: 'câu lạc sang bài khác');
      }
    }
    expect(withExamples, greaterThan(200));
  });

  test('has_furigana nói đúng sự thật, không phải cờ trang trí', () {
    for (final s in grammar.sentences) {
      expect(
        s.hasFurigana,
        s.jaKanji != s.jaKana,
        reason: 'cờ lệch với dữ liệu: ${s.jaKanji}',
      );
    }
  });

  group('điền trợ từ', () {
    /// Mọi câu hỏi điền trợ từ dựng được từ toàn bộ kho.
    List<GrammarQuestion> allParticleQuestions() => GrammarQuizBuilder(
      grammar,
      seed: 1,
    ).build(count: 100000, kinds: const {GrammarQuizKind.particle});

    test('lắp đáp án vào chỗ trống thì ra ĐÚNG câu gốc', () {
      // Đây là bài kiểm quan trọng nhất của cả bộ dựng đề. Nếu chỗ trống khoét
      // lệch một ký tự, hoặc đáp án không phải ký tự đã bị lấy đi, thì câu hỏi
      // không có đáp án đúng — mà nhìn vào đề vẫn thấy bình thường.
      final questions = allParticleQuestions();
      expect(questions.length, greaterThan(150));

      for (final q in questions) {
        final filled = q.prompt.replaceFirst('◯', q.answer);
        expect(filled, q.sentence.jaKanji, reason: 'lắp lại không khớp gốc');
        expect('◯'.allMatches(q.prompt).length, 1, reason: 'phải đúng 1 lỗ');
      }
    });

    test('KHÔNG khoét vào で của です／でした／では', () {
      // で ở đây là hệ từ, không phải trợ từ. Khoét vào là đề vô nghĩa: câu
      // 便利◯す。 không có phương án nào đúng cả.
      for (final q in allParticleQuestions()) {
        final at = q.prompt.indexOf('◯');
        final after = at + 1 < q.prompt.length ? q.prompt[at + 1] : '';
        expect(
          q.answer == 'で' && 'すしは'.contains(after),
          isFalse,
          reason: 'khoét vào です: ${q.sentence.jaKanji}',
        );
      }
    });

    test('luôn 4 phương án, khác nhau, và chứa đáp án', () {
      for (final q in allParticleQuestions()) {
        expect(q.options.length, GrammarQuizBuilder.optionCount);
        expect(q.options.toSet().length, q.options.length);
        expect(q.options, contains(q.answer));
        for (final o in q.options) {
          expect(GrammarQuizBuilder.particles, contains(o));
        }
      }
    });

    test('có bản dịch làm gợi ý — không có thì chọn trợ từ là đoán mò', () {
      for (final q in allParticleQuestions()) {
        expect(q.hint, isNotEmpty);
      }
    });
  });

  group('chọn nghĩa', () {
    test('4 phương án khác nhau, chứa đáp án, không lẫn câu gần giống', () {
      final questions = GrammarQuizBuilder(
        grammar,
        seed: 2,
      ).build(count: 300, kinds: const {GrammarQuizKind.meaning});
      expect(questions.length, greaterThan(100));

      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4);
        expect(q.options, contains(q.answer));
        // Phương án nhiễu không được chứa hoặc bị chứa trong đáp án: 「Anh Hải
        // là bác sĩ.」 với 「Anh Hải là bác sĩ phải không.」 đặt cạnh nhau thì
        // câu hỏi mất đáp án đúng duy nhất.
        for (final o in q.options.where((o) => o != q.answer)) {
          expect(q.answer.contains(o), isFalse, reason: '$o ⊂ ${q.answer}');
          expect(o.contains(q.answer), isFalse, reason: '${q.answer} ⊂ $o');
        }
      }
    });
  });

  test('loại câu còn dính rác của nguồn', () {
    // Nguồn trộn số thứ tự bài tập và nhãn hội thoại vào cùng ô với câu.
    final questions = GrammarQuizBuilder(grammar, seed: 3).build(count: 500);
    for (final q in questions) {
      for (final ch in ['例', '：', '[', ']', '（', '(']) {
        expect(q.sentence.jaKanji.contains(ch), isFalse, reason: 'rác: $ch');
      }
    }
  });

  test('lọc theo bài thì chỉ ra câu của bài đó', () {
    final questions = GrammarQuizBuilder(
      grammar,
      seed: 4,
    ).build(count: 40, lessons: const {3, 4});
    expect(questions, isNotEmpty);
    for (final q in questions) {
      expect(q.sentence.lesson, anyOf(3, 4));
    }
  });

  test('không hỏi lại cùng một câu trong một phiên', () {
    // Nguồn có câu lặp nguyên văn giữa các mẫu.
    final questions = GrammarQuizBuilder(grammar, seed: 5).build(count: 40);
    final seen = questions.map((q) => q.sentence.jaKanji).toSet();
    expect(seen.length, questions.length);
  });

  test('bài không có câu nào thì trả rỗng, không nổ', () {
    final questions = GrammarQuizBuilder(
      grammar,
      seed: 6,
    ).build(lessons: const {999});
    expect(questions, isEmpty);
  });

  group('phiên', () {
    test('đếm đủ bốn loại, tổng luôn bằng số câu', () {
      final s = GrammarQuizSession(
        GrammarQuizBuilder(grammar, seed: 7).build(count: 6),
      );
      expect(s.total, 6);
      expect(s.pendingCount, 6);

      s.answer(s.current!.answer);
      s.advance();
      s.answer('${s.current!.answer}x');
      s.advance();
      s.skip();

      expect(s.correctCount, 1);
      expect(s.wrongCount, 1);
      expect(s.skippedCount, 1);
      expect(s.pendingCount, 3);
      expect(
        s.correctCount + s.wrongCount + s.skippedCount + s.pendingCount,
        s.total,
      );
    });

    test('advance trả false khi hết câu và KHÔNG bỏ trống câu hiện tại', () {
      final s = GrammarQuizSession(
        GrammarQuizBuilder(grammar, seed: 8).build(count: 2),
      );
      s.answer(s.current!.answer);
      expect(s.advance(), isTrue);
      s.answer(s.current!.answer);
      expect(s.advance(), isFalse);
      // Con trỏ vẫn trỏ vào câu cuối — màn hình dựa vào giá trị trả về để rời
      // màn, không chờ current thành null.
      expect(s.current, isNotNull);
      expect(s.isFinished, isTrue);
    });

    test('bỏ qua hết thì phiên vẫn kết thúc được', () {
      final s = GrammarQuizSession(
        GrammarQuizBuilder(grammar, seed: 9).build(count: 3),
      );
      for (var i = 0; i < 3; i++) {
        s.skip();
        s.advance();
      }
      expect(s.isFinished, isTrue);
      expect(s.skippedCount, 3);
      expect(s.questions.every((q) => q.state == AnswerState.skipped), isTrue);
    });
  });
}
