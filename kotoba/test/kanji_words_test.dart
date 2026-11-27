import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/kanji_words.dart';

import 'support/asset_fixtures.dart';

/// 448 từ vựng chữ Hán rút từ PDF MINATO.
///
/// Dữ liệu này bê NGUYÊN VĂN từ tài liệu người học dùng trên lớp, nên test ở
/// đây canh đúng một chuyện: app không tự ý sửa nó. Sai một nghĩa dịch là người
/// học thấy app khác sách, và họ sẽ tin sách chứ không tin app.
void main() {
  late KanjiWordSet set;

  setUpAll(() => set = loadKanjiWordsFixture());

  test('đủ 448 từ, số thứ tự liền mạch 1→448', () {
    expect(set.words.length, 448);
    expect(set.words.first.n, 1);
    expect(set.words.last.n, 448);
    expect(set.words.map((w) => w.n).toSet().length, 448);
  });

  test('giữ ĐÚNG thứ tự PDF', () {
    // Thứ tự PDF là theo chủ đề, và đó là lý do bỏ chia cấp độ. Sắp lại là phá
    // mất cách nhóm duy nhất mà dữ liệu này có.
    final ns = set.words.map((w) => w.n).toList();
    expect(ns, orderedEquals([...ns]..sort()));
  });

  test('mọi từ đều có cách đọc và nghĩa', () {
    for (final w in set.words) {
      expect(w.kana, isNotEmpty, reason: 'từ ${w.n} thiếu cách đọc');
      expect(w.meaning, isNotEmpty, reason: 'từ ${w.n} thiếu nghĩa');
      expect(w.word, isNotEmpty);
    }
  });

  test('GIỮ NGUYÊN chỗ PDF viết chữ ngoài phạm vi bằng kana', () {
    // 家ちん = 家賃, 道ろ = 道路, ひ鳴 = 悲鳴. PDF cố ý viết vậy để chỉ lộ chữ
    // cần học. Ai đó "sửa cho đúng" là làm lệch với tài liệu trên lớp — khoá
    // lại bằng test để chuyện đó không lọt qua âm thầm.
    expect(set.words[1].word, '家ちん');
    expect(set.words[1].kana, 'やちん');
    expect(set.words.firstWhere((w) => w.n == 129).word, '道ろ');
    expect(set.words.firstWhere((w) => w.n == 446).word, 'ひ鳴');
  });

  group('cấp độ', () {
    test('mọi từ đều có cấp, bản đóng gói hiện là N4 hết', () {
      for (final w in set.words) {
        expect(w.level, isNotEmpty, reason: 'từ ${w.n} thiếu cấp');
      }
      expect(set.levels, ['N4']);
    });

    test('danh sách cấp GOM TỪ DỮ LIỆU, không viết cứng', () {
      // Đây là bài kiểm quan trọng nhất của phần cấp độ. Viết cứng ['N5','N4']
      // thì sửa cấp trên database rồi đồng bộ, app vẫn hiện nút cũ và giấu mất
      // cả nhóm từ — mà không báo gì.
      final json =
          jsonDecode(File('assets/kanji-words.json').readAsStringSync())
              as Map<String, dynamic>;
      final words = (json['words'] as List).cast<Map<String, dynamic>>();
      // Giả lập database đã phân lại cấp: vài từ thành N5, một từ thành N3.
      for (var i = 0; i < 5; i++) {
        words[i] = {...words[i], 'level': 'N5'};
      }
      words[9] = {...words[9], 'level': 'N3'};
      final resorted = KanjiWordSet.fromJson({...json, 'words': words});

      // Tự có thêm nút, xếp từ dễ tới khó, KHÔNG cần sửa mã.
      expect(resorted.levels, ['N5', 'N4', 'N3']);
      expect(resorted.byLevel('N5').length, 5);
      expect(resorted.byLevel('N3').length, 1);
      expect(resorted.byLevel('N4').length, 448 - 6);
    });

    test('cấp lạ ngoài thang JLPT vẫn hiện, xếp xuống cuối', () {
      // Thà thấy một nhãn khó hiểu còn hơn im lặng giấu mất cả nhóm từ.
      final json =
          jsonDecode(File('assets/kanji-words.json').readAsStringSync())
              as Map<String, dynamic>;
      final words = (json['words'] as List).cast<Map<String, dynamic>>();
      words[0] = {...words[0], 'level': 'chưa rõ'};
      final odd = KanjiWordSet.fromJson({...json, 'words': words});
      expect(odd.levels, ['N4', 'chưa rõ']);
    });
  });

  test('dùng ĐÚNG tên trường mà API trả về', () {
    // Bản đóng gói và bản tải về đi qua CÙNG một bộ đọc. Đổi tên trường ở
    // tools/build-kanji-words-asset.py mà quên đổi ở
    // app/api/kotoba/kanji-words/route.ts (hoặc ngược lại) thì đường này vẫn
    // chạy, đường kia im lặng trả rỗng — và chỉ lộ ra khi bấm đồng bộ.
    final raw =
        jsonDecode(File('assets/kanji-words.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(raw.keys.toSet(), {'source', 'note', 'count', 'words'});
    expect(((raw['words'] as List).first as Map).keys.toSet(), {
      'n',
      'word',
      'hv',
      'kana',
      'meaning',
      'level',
      'chars',
      'unknown',
    });
  });

  group('bảng tra', () {
    test('chars liệt kê đúng chữ Hán trong từ, bỏ trùng, giữ thứ tự', () {
      final kanji = RegExp(r'[一-鿿]');
      for (final w in set.words) {
        final expected = <String>[];
        for (final m in kanji.allMatches(w.word)) {
          if (!expected.contains(m.group(0))) expected.add(m.group(0)!);
        }
        expect(w.chars, expected, reason: w.word);
      }
    });

    test('tra ngược từ chữ ra các từ chứa nó', () {
      final withIe = set.wordsWith('家');
      expect(withIe, isNotEmpty);
      for (final w in withIe) {
        expect(w.word.contains('家'), isTrue);
      }
    });

    test('id có tiền tố riêng, không đụng id của 2090 từ Minna', () {
      // Tiến độ lưu chung một file. Trùng khoá là hai bộ dữ liệu ghi đè nhau.
      for (final w in set.words.take(20)) {
        expect(w.id, startsWith('kw'));
      }
      expect(set.byId('kw3')?.word, '家族');
      expect(set.byId('khong-co'), isNull);
    });
  });

  group('tìm kiếm', () {
    test('theo nghĩa tiếng Việt, KHÔNG cần bỏ dấu', () {
      expect(set.search('gia dinh').map((w) => w.word), contains('家族'));
      expect(set.search('Gia đình').map((w) => w.word), contains('家族'));
    });

    test('theo cách đọc kana và theo chữ Hán', () {
      expect(set.search('かぞく').map((w) => w.word), contains('家族'));
      expect(set.search('家族').map((w) => w.word), contains('家族'));
    });

    test('theo âm Hán-Việt, không phân biệt hoa thường', () {
      expect(set.search('gia toc').map((w) => w.word), contains('家族'));
    });

    test('rỗng thì trả về tất cả', () {
      expect(set.search('').length, set.words.length);
    });

    test('không khớp thì trả rỗng, không ném', () {
      expect(set.search('zzzkhongcogi'), isEmpty);
    });
  });

  test('chỉ 葉 là chữ app chưa có trang chi tiết', () {
    // Con số này ràng buộc bộ 364 chữ với 448 từ. Vỡ ra nghĩa là một trong hai
    // bộ đã đổi mà bộ kia chưa theo — lúc đó có chữ bấm vào rỗng.
    final missing = {for (final w in set.words) ...w.unknownChars};
    expect(missing, {'葉'});
  });
}
