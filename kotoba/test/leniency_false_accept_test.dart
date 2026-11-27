import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/answer_matcher.dart';

/// Đào sâu lớp nới lỏng (Leniency) — phần KHÔNG có trong bản JS gốc, nên
/// golden-file test (đối chiếu answer-matcher.js) không phủ được chỗ này.
///
/// Hai nhóm lỗi đi tìm:
///   1. `ignoreLongVowel=true, mixKana=false` có vô tình bật luôn mixKana không?
///      (Leniency.apply có nhánh gọi lại _toHiragana bất kể mixKana — xem
///      lib/data/answer_matcher.dart dòng 124-129.)
///   2. `_foldLongVowel` gộp おう→お, えい→え và nguyên âm đôi — có từ THẬT nào
///      trong assets/vocabulary.json bị gộp nhầm với từ khác nghĩa hẳn không?
void main() {
  group('BUG: ignoreLongVowel một mình vẫn kéo theo mixKana', () {
    // Cài đặt cho phép độc lập bật "Bỏ qua trường âm" mà KHÔNG bật "Chấp nhận
    // lẫn hiragana/katakana" (xem lib/ui/settings_screen.dart dòng 118-129,
    // hai SettingsSwitch tách biệt). Theo đúng tài liệu ở
    // lib/data/settings_store.dart dòng 56-57: "Tắt sẵn: テープ ≠ てーぷ".
    const onlyLongVowel = Leniency(ignoreLongVowel: true); // mixKana: false

    test('テープ (katakana, băng cát-xét) không được lẫn với てーぷ hiragana '
        'dù chỉ bật "bỏ qua trường âm"', () {
      // Kỳ vọng: false — mixKana=false nghĩa là katakana vẫn phải gõ katakana.
      // Thực tế (lỗi): Leniency.apply gọi _toHiragana(out) vô điều kiện ở
      // nhánh ignoreLongVowel khi mixKana=false, nên vẫn khớp.
      final r = checkAnswer('てーぷ', answers: ['テープ'], leniency: onlyLongVowel);
      expect(
        r.correct,
        isFalse,
        reason:
            'lib/data/answer_matcher.dart:127 — '
            '`_foldLongVowel(mixKana ? out : _toHiragana(out))` luôn gọi '
            '_toHiragana kể cả khi mixKana=false, vô tình bật lẫn kana '
            'dù người dùng không bật switch đó.',
      );
    });

    test('so sánh: cùng input, cùng answer, chỉ bật mixKana đơn thuần (không '
        'ignoreLongVowel) thì ĐÚNG là phải khớp — chứng minh gốc lỗi nằm ở '
        'nhánh ignoreLongVowel, không phải bản thân _toHiragana', () {
      const onlyMixKana = Leniency(mixKana: true); // ignoreLongVowel: false
      final r = checkAnswer('てーぷ', answers: ['テープ'], leniency: onlyMixKana);
      expect(
        r.correct,
        isTrue,
      ); // hành vi này đúng như tài liệu, không phải bug
    });
  });

  group('BUG: _foldLongVowel gộp nhầm các cặp từ thật khác nghĩa hẳn nhau '
      '(kiểm trên assets/vocabulary.json)', () {
    const foldLenient = Leniency(ignoreLongVowel: true);

    test('うん (ừ/có) và ううん (không) — HAI NGHĨA TRÁI NGƯỢC NHAU — '
        'bị gộp làm một sau khi fold nguyên âm đôi', () {
      // Từ thật: bài 20 うん = "ừ, có" (đồng ý); ううん = "không" (từ chối).
      // Gõ うん khi đề đúng là ううん vẫn được chấm ĐÚNG — sai lệch nghĩa
      // nghiêm trọng nhất tìm được trong bộ dữ liệu 2090 từ.
      final r = checkAnswer('うん', answers: ['ううん'], leniency: foldLenient);
      expect(
        r.correct,
        isTrue,
        reason:
            'BUG xác nhận: gõ "ừ, có" khi đáp án đúng là "không" vẫn '
            'được tính đúng — _foldLongVowel gộp cả hai về "うん".',
      );
    });

    test('いいえ (Không) và いえ (nhà) bị gộp làm một', () {
      // bài 1: いいえ = "Không". bài 27: いえ = "nhà".
      final r = checkAnswer('いえ', answers: ['いいえ'], leniency: foldLenient);
      expect(
        r.correct,
        isTrue,
        reason:
            'BUG: gõ "nhà" (いえ) khi đề hỏi "Không" (いいえ) vẫn đúng, '
            'vì fold coi いいえ→いえ.',
      );
    });

    test('ビール (bia) và ビル (tòa nhà) bị gộp làm một', () {
      // bài 6: ビール = "bia". bài 10: ビル = "tòa nhà".
      final r = checkAnswer('ビル', answers: ['ビール'], leniency: foldLenient);
      expect(
        r.correct,
        isTrue,
        reason: 'BUG: gõ "tòa nhà" (ビル) khi đề hỏi "bia" (ビール) vẫn đúng.',
      );
    });

    test('ええ (vâng) và え (tranh, hội họa) bị gộp làm một', () {
      // bài 6: ええ = "vâng". bài 9: え = "tranh, hội họa".
      final r = checkAnswer('え', answers: ['ええ'], leniency: foldLenient);
      expect(
        r.correct,
        isTrue,
        reason: 'BUG: gõ "tranh" (え) khi đề hỏi "vâng" (ええ) vẫn đúng.',
      );
    });

    test('います (có/ở — tồn tại) và いいます (nói) bị gộp làm một', () {
      // bài 11: います = "có (con)"/"ở". bài 21: いいます = "nói".
      final r = checkAnswer('います', answers: ['いいます'], leniency: foldLenient);
      expect(
        r.correct,
        isTrue,
        reason: 'BUG: gõ "có/ở" (います) khi đề hỏi "nói" (いいます) vẫn đúng.',
      );
    });
  });
}
