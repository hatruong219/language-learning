import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/answer_matcher.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';

/// Chốt an toàn cho việc nới lỏng chấm điểm.
///
/// Gộp trường âm làm sáu cặp từ CÓ THẬT dính vào nhau. Nặng nhất là bài 20:
/// うん ("ừ, có") và ううng ("không") đều gộp về "うん". Không có chốt thì gõ
/// "có" khi đáp án là "không" vẫn được chấm đúng, và thống kê ghi nhận là
/// đã thuộc — sai kiểu này dạy hỏng người học.
void main() {
  late Vocabulary vocab;

  setUpAll(() {
    vocab = Vocabulary.fromJson(
      jsonDecode(File('assets/vocabulary.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  Leniency lenient() =>
      Leniency(ignoreLongVowel: true, realWords: vocab.strictForms);

  Word wordOf(String reading, {required int lesson}) => vocab.words.firstWhere(
    (w) => w.reading == reading && w.lesson == lesson,
    orElse: () => throw StateError('không thấy $reading ở bài $lesson'),
  );

  group('gõ trúng một từ thật khác thì KHÔNG được nới lỏng', () {
    final pairs = [
      ('うん', 20, 'ううん', 20, 'ừ/có  vs  không'),
      ('いえ', 27, 'いいえ', 1, 'nhà  vs  Không'),
      ('ビル', 10, 'ビール', 6, 'tòa nhà  vs  bia'),
      ('え', 9, 'ええ', 6, 'tranh  vs  vâng'),
      ('い', 32, 'いい', 8, 'dạ dày  vs  tốt'),
      ('います', 10, 'いいます', 21, 'có/ở  vs  nói'),
    ];

    for (final (typed, typedLesson, answer, answerLesson, desc) in pairs) {
      test('$desc — gõ "$typed" không được tính đúng cho "$answer"', () {
        wordOf(typed, lesson: typedLesson); // chắc chắn cả hai đều có thật
        final target = wordOf(answer, lesson: answerLesson);
        expect(
          target.check(typed, leniency: lenient()).correct,
          isFalse,
          reason: '"$typed" là một từ thật khác, không phải lỗi trường âm',
        );
      });
    }
  });

  test('nới lỏng vẫn hoạt động khi chuỗi gõ KHÔNG phải từ thật', () {
    // びよういん không nằm trong từ điển, chỉ là びょういん viết lệch.
    final w = vocab.words.firstWhere((x) => x.reading == 'びょういん');
    expect(w.check('びょういん', leniency: lenient()).correct, isTrue);
  });

  test('hai công tắc độc lập: bỏ qua trường âm không kéo theo lẫn kana', () {
    const kata = ['テープ'];
    expect(
      checkAnswer(
        'てーぷ',
        answers: kata,
        leniency: const Leniency(ignoreLongVowel: true),
      ).correct,
      isFalse,
      reason: 'công tắc lẫn kana đang TẮT',
    );
    expect(
      checkAnswer(
        'てーぷ',
        answers: kata,
        leniency: const Leniency(mixKana: true, ignoreLongVowel: true),
      ).correct,
      isTrue,
      reason: 'bật cả hai thì hiragana + bỏ trường âm mới khớp katakana',
    );
  });

  test('chốt an toàn không đụng tới chấm nghiêm', () {
    for (final w in vocab.words.take(300)) {
      final forms = expandVariants(w.reading);
      if (forms.isEmpty) continue;
      expect(
        w.check(forms.first, leniency: lenient()).correct,
        isTrue,
        reason: 'gõ đúng nguyên văn ${w.reading} phải luôn đúng',
      );
    }
  });
}
