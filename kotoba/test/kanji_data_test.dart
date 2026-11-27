import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/kanji.dart';
import 'package:mnn_flashcard/data/kanji_index.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';

/// Khoá lại hình dạng dữ liệu kanji và các con số dẫn xuất.
///
/// Ba lớp bảo vệ khác nhau:
///   1. Đọc được asset thật — bắt lỗi đổi tên trường, thiếu khai báo pubspec.
///   2. Các con số đã dùng để quyết định thiết kế không âm thầm đổi.
///   3. Những trạng thái đặc biệt (亠 có tên mà không nghĩa, ハマ là hình nét)
///      không bị coi là khuyết dữ liệu rồi bị "sửa" mất.
void main() {
  late KanjiSet set;
  late Vocabulary vocab;
  late KanjiIndex index;

  setUpAll(() {
    set = KanjiSet.fromJson(
      jsonDecode(File('assets/kanji.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    vocab = Vocabulary.fromJson(
      jsonDecode(File('assets/vocabulary.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    index = KanjiIndex.build(set, vocab);
  });

  test('asset đọc được và đủ chữ', () {
    expect(set.kanji.length, 364);
    expect(set.parts.length, 181);
    expect(set.byLevel('N5').length + set.byLevel('N4').length, 364);
  });

  test('mọi chữ đều có âm Hán-Việt — đây là móc nhớ chính', () {
    final missing = set.kanji.where((k) => k.hanViet.isEmpty).toList();
    expect(missing, isEmpty, reason: 'thiếu âm: ${missing.map((k) => k.char)}');
  });

  test('chữ 学 đọc đúng mọi trường', () {
    final k = set.byChar('学')!;
    expect(k.hanViet.first, 'học');
    expect(k.hanVietLabel, 'Học');
    expect(k.on, contains('ガク'));
    expect(k.parts, containsAll(['子', '冖']));
    // 学 gom đúng hai bẫy: chưa có nghĩa tiếng Việt, và nghĩa Hán cổ thì lệch
    // hẳn tiếng Nhật. Giao diện phải ghi "chưa có" ở ô nghĩa, và KHÔNG được lấy
    // meaningClassic lấp vào — cụ Thiều Chửu ghi "Bắt chước".
    expect(k.meaningVi, isNull);
    expect(k.meaningClassic, isNotNull);
    expect(k.meaningClassic, isNot(equals(k.meaningVi)));
  });

  test('tự dạng cựu đọc đúng', () {
    expect(set.byChar('気')!.kyujitai, '氣');
    expect(set.byChar('楽')!.kyujitai, '樂');
    expect(set.byChar('学')!.kyujitai, isNull, reason: '学 tra thẳng được');
  });

  test('mảnh cấu tạo có tên, và hai ngoại lệ là ĐÚNG chứ không phải thiếu', () {
    final named = set.parts.where((p) => p.hanViet.isNotEmpty).length;
    expect(named, 179, reason: '179/181 mảnh có tên bộ thủ');

    // 亠 có TÊN nhưng KHÔNG có nghĩa — nguồn 214 bộ thủ ghi thẳng như vậy.
    final tou = set.partByChar('亠')!;
    expect(tou.hanViet.first, 'đầu');
    expect(tou.meaningVi, isNull);
    expect(tou.isShape, isFalse, reason: '亠 là bộ thủ thật, không phải nét');

    // ハ và マ là hình nét KRADFILE mượn từ katakana, không phải chữ.
    final shapes = set.parts.where((p) => p.isShape).map((p) => p.char).toSet();
    expect(shapes, {'ハ', 'マ'});
  });

  test('biến thể bộ thủ trỏ về dạng gốc', () {
    final no = set.partByChar('ノ')!;
    expect(no.hanViet.first, 'phiệt');
    expect(
      no.radicalOf,
      '丿',
      reason: 'ノ là cùng hình với 丿, khác khối Unicode',
    );
  });

  test('số chữ chứa mảnh KHÁC số chữ mở trọn — đừng gọi nó là mở khoá', () {
    final one = set.partByChar('一')!;
    expect(one.containedIn, 66);
    // Học xong 一 chỉ mở được đúng chữ 一: 亜 còn cần ｜ và 口.
    final onlyOne = set.kanji
        .where((k) => k.parts.isNotEmpty && k.parts.every((p) => p == '一'))
        .length;
    expect(onlyOne, 1);
    expect(onlyOne, lessThan(one.containedIn));
  });

  test('chặng học: 9 chặng, số mở trọn tăng đều', () {
    expect(index.stages.length, 9);
    expect(index.stages.first.parts.length, KanjiIndex.stageSize);
    expect(
      index.stages.fold(0, (s, st) => s + st.parts.length),
      set.parts.length,
      reason: 'chia chặng không được làm rơi mảnh nào',
    );
    // Đơn điệu tăng: học thêm mảnh thì số chữ mở trọn không thể giảm.
    for (var i = 1; i < index.stages.length; i++) {
      expect(
        index.stages[i].fullyUnlocked,
        greaterThanOrEqualTo(index.stages[i - 1].fullyUnlocked),
      );
    }
    expect(index.stages.first.fullyUnlocked, greaterThan(0));
  });

  test('từ ra đề được: loại đúng ba loại không dùng được', () {
    final forms = index.questionWords.map((w) => w.kanji!).toSet();
    expect(
      forms.any((f) => f.contains('～')),
      isFalse,
      reason: '～円 phải bị loại',
    );
    expect(forms.any((f) => f.contains('[')), isFalse);
    expect(forms.any((f) => f.contains(' ')), isFalse);
    // 友達 có chữ 達 ngoài bộ 364 → không được ra đề.
    expect(forms.contains('友達'), isFalse);
    expect(index.questionWords.length, greaterThan(600));
  });

  test('bộ lọc "có từ để luyện" khớp với danh sách từ', () {
    for (final k in set.kanji) {
      expect(
        index.testable(k.char),
        index.wordsFor(k.char).isNotEmpty,
        reason: 'lệch ở chữ ${k.char}',
      );
    }
    // 円 chỉ xuất hiện ở ～円 nên không ra đề được, dù là chữ N5.
    expect(index.testable('円'), isFalse);
    expect(set.byChar('円')!.level, 'N5');
    // 学 thì có 学生, 大学, 学校 — ra đề được.
    expect(index.testable('学'), isTrue);
    expect(index.wordsFor('学').map((w) => w.kanji), containsAll(['学生', '大学']));
  });

  test('chữ không ra đề được vẫn nằm trong bộ, chỉ là loại khỏi Kiểm tra', () {
    final out = index.notTestable.map((k) => k.char).toSet();
    expect(out, containsAll(['円', '友', '岩', '林', '森', '田', '畑', '門']));
    // Ra đề được + không ra đề được phải cộng đúng bằng cả bộ, không hụt chữ nào.
    final testableCount = set.kanji.where((k) => index.testable(k.char)).length;
    expect(testableCount + out.length, set.kanji.length);
    // Chúng vẫn có âm Hán-Việt để học mặt chữ.
    for (final k in index.notTestable) {
      expect(k.hanViet, isNotEmpty);
    }
  });

  test('in_course và "có từ để luyện" là hai tập KHÁC NHAU', () {
    final course = set.kanji
        .where((k) => k.inCourse)
        .map((k) => k.char)
        .toSet();
    final testable = set.kanji
        .where((k) => index.testable(k.char))
        .map((k) => k.char)
        .toSet();
    expect(course.length, 287);
    // Lệch cả hai chiều — bình thường, vì giáo trình liệt kê mặt chữ còn từ
    // vựng là chuyện khác. Giao diện chỉ dùng "có từ để luyện".
    expect(course.difference(testable), isNotEmpty);
    expect(testable.difference(course), isNotEmpty);
  });

  test('mảnh tra ngược ra chữ chứa nó', () {
    final withSun = index.kanjiContaining('日').map((k) => k.char).toSet();
    expect(withSun, contains('日'));
    expect(withSun.length, set.partByChar('日')!.containedIn);
  });
}
