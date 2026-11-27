import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/grammar.dart';
import 'package:mnn_flashcard/quiz/translation_check.dart';

/// Chấm bài dịch.
///
/// Chỗ dễ sai nhất không phải thuật toán đối chiếu mà là NHẬN ĐÚNG. Chấm sai
/// một câu người học gõ đúng thì họ mất niềm tin vào cả mục này, và sẽ không
/// quay lại — tệ hơn nhiều so với việc bỏ sót một lỗi.
void main() {
  Sentence s({
    String kanji = '私は学生です。',
    String kana = 'わたしはがくせいです。',
    String vi = 'Tôi là sinh viên.',
  }) => Sentence(
    lesson: 1,
    grammarKey: '1:1',
    jaKanji: kanji,
    jaKana: kana,
    vi: vi,
    hasFurigana: kanji != kana,
  );

  group('nhận đúng', () {
    test('gõ bản kanji thì đúng', () {
      expect(checkTranslation('私は学生です。', s()).correct, isTrue);
    });

    test('gõ bản toàn kana cũng đúng', () {
      // Người học đang bật bàn phím kana thì gõ ra kana — vẫn là câu đó.
      expect(checkTranslation('わたしはがくせいです。', s()).correct, isTrue);
    });

    test('thiếu dấu chấm câu vẫn đúng', () {
      // 。và 、là trang trí với việc học ngữ pháp; bắt gõ chúng chỉ tổ gây sai
      // vặt không liên quan tới điều đang kiểm.
      expect(checkTranslation('私は学生です', s()).correct, isTrue);
    });

    test('thừa khoảng trắng hai đầu vẫn đúng', () {
      expect(checkTranslation('  私は学生です。  ', s()).correct, isTrue);
    });

    test('câu không có furigana thì hai bản như một', () {
      final plain = s(kanji: 'はい、そうです。', kana: 'はい、そうです。');
      expect(checkTranslation('はい、そうです', plain).correct, isTrue);
    });
  });

  group('bắt sai', () {
    test('rỗng thì không đúng', () {
      expect(checkTranslation('', s()).correct, isFalse);
    });

    test('sai trợ từ thì báo sai, và chỉ ra đúng chỗ trợ từ', () {
      final r = checkTranslation('私が学生です。', s());
      expect(r.correct, isFalse);
      // Chỉ một ký tự lệch nên phải xếp vào "gần đúng", không phải "sai bét".
      expect(r.close, isTrue);

      final missing = r.parts
          .where((p) => p.kind == DiffKind.missing)
          .map((p) => p.text)
          .join();
      final extra = r.parts
          .where((p) => p.kind == DiffKind.extra)
          .map((p) => p.text)
          .join();
      expect(missing, 'は', reason: 'phải chỉ ra thiếu は');
      expect(extra, 'が', reason: 'phải chỉ ra thừa が');
    });

    test('thiếu hẳn một đoạn thì đánh dấu đoạn đó là thiếu', () {
      final r = checkTranslation('私です。', s());
      expect(r.correct, isFalse);
      final missing = r.parts
          .where((p) => p.kind == DiffKind.missing)
          .map((p) => p.text)
          .join();
      expect(missing, contains('学生'));
    });

    test('câu khác hẳn thì không được tính là gần đúng', () {
      final r = checkTranslation('あれは何ですか。', s());
      expect(r.correct, isFalse);
      expect(r.close, isFalse);
    });
  });

  group('đối chiếu', () {
    test('ghép các đoạn lại thì phủ hết cả câu gõ lẫn đáp án', () {
      // Bất biến của bản đối chiếu: bỏ phần "thừa" ra thì còn lại đúng đáp án;
      // bỏ phần "thiếu" ra thì còn lại đúng câu đã gõ. Sai bất biến này nghĩa
      // là bản đối chiếu đang bịa ra ký tự không có ở đâu cả.
      final r = checkTranslation('私が学生でした。', s());
      final asAnswer = r.parts
          .where((p) => p.kind != DiffKind.extra)
          .map((p) => p.text)
          .join();
      final asTyped = r.parts
          .where((p) => p.kind != DiffKind.missing)
          .map((p) => p.text)
          .join();
      expect(asAnswer, '私は学生です');
      expect(asTyped, '私が学生でした');
    });

    test(
      'chọn bản để soi theo bản GIỐNG HƠN, không theo có kanji hay không',
      () {
        // Gõ toàn kana mà đem soi bản kanji thì tô đỏ gần hết câu dù chỉ sai một
        // chữ — người học nhìn vào tưởng mình sai sạch.
        final r = checkTranslation('わたしはがくせいでした。', s());
        expect(r.target, 'わたしはがくせいです。');
        // Gõ でした thay vì です — sai thì, đúng 9/12 ký tự.
        expect(r.similarity, greaterThan(0.7));
      },
    );

    test('đúng thì đối chiếu chỉ có một đoạn, toàn bộ là đúng', () {
      final r = checkTranslation('私は学生です。', s());
      expect(r.parts.length, 1);
      expect(r.parts.single.kind, DiffKind.same);
      expect(r.similarity, 1);
    });
  });
}
