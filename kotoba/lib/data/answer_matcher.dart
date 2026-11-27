/// So đáp án quiz theo hướng "bỏ qua tiểu tiết".
///
/// Bản port trung thành từ `kana-quiz-popup/src/answer-matcher.js` — logic đó đã
/// chạy thật trên app desktop nên giữ nguyên hành vi, không tự chế luật thứ hai.
/// Có bài kiểm đối chiếu từng từ một trên cả 2090 từ, xem `test/answer_matcher_test.dart`.
///
/// Quy ước dữ liệu:
///   - bỏ mọi ký hiệu trang trí (～ 。 、 ？ / khoảng trắng…), chỉ giữ kana + kanji
///   - KHÔNG quy đổi katakana ↔ hiragana: từ gốc katakana phải gõ katakana (てーぷ ≠ テープ)
///   - `A / B`      → chấp nhận A hoặc B
///   - `（B）`       → cách gọi khác, chấp nhận dạng không ngoặc hoặc riêng B
///   - `[B]`        → phần tùy chọn, chấp nhận cả dạng có và không có B
///   - `[…～…]`     → chú thích ngữ cảnh, ～ đánh dấu vị trí từ chính:
///                    とります [しゃしんを～] → とります hoặc しゃしんをとります
///
/// Phần thêm so với bản desktop: nhánh romaji, để anh gõ được cả khi đang ở bàn
/// phím tiếng Anh. Nhánh này tách riêng, không đụng vào logic gốc.
library;

/// Giữ lại kana và kanji, vứt hết phần còn lại. Dùng danh sách trắng chứ không
/// phải danh sách đen — ký tự lạ nào chưa lường trước cũng bị loại đúng cách.
final _nonKanaKanji = RegExp(r'[^ぁ-ゖァ-ヺー一-鿿㐀-䶿]');

final _hasLatinOrDigit = RegExp(r'[0-9０-９a-zA-ZＡ-Ｚａ-ｚ]');
final _fullWidth = RegExp(r'[Ａ-Ｚａ-ｚ０-９]');
final _notAsciiAlnum = RegExp(r'[^a-z0-9]');
final _square = RegExp(r'[\[［]([^\]］]*)[\]］]');
final _round = RegExp(r'[(（]([^)）]*)[)）]');
final _tildeFirst = RegExp(r'[～〜]');

String normalize(String? str) => (str ?? '').replaceAll(_nonKanaKanji, '');

/// Dự phòng cho đáp án lẫn chữ latin hoặc số (ví dụ ＣＤ): full-width → ASCII rồi thường hoá.
String normalizeLatin(String? str) => (str ?? '')
    .replaceAllMapped(
      _fullWidth,
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0xfee0),
    )
    .toLowerCase()
    .replaceAll(_notAsciiAlnum, '');

/// Sinh mọi dạng chấp nhận được từ một chuỗi đáp án gốc.
///
/// `[カセット]テープ` → `カセットテープ`, `テープ`
/// `だれ（どなた）`   → `だれ`, `どなた`
/// `～ふん / ～ぷん`  → `ふん`, `ぷん`
List<String> expandVariants(String? raw) {
  final source = raw ?? '';
  // Chuỗi lẫn số hoặc chữ latin (２、３にち, ＩＰＳさいぼう…) không kana-hoá trung thực
  // được — bỏ qua, để nhánh reading kana sạch quyết định.
  if (_hasLatinOrDigit.hasMatch(source)) return const [];

  List<String> expand(String v) {
    final sq = _square.firstMatch(v);
    if (sq != null) {
      final inner = sq.group(1)!;
      if (_tildeFirst.hasMatch(inner)) {
        // Chú thích ngữ cảnh chứa ～, sinh 3 dạng:
        //   riêng từ chính      とります [しゃしんを～] → とります
        //   thế từ chính vào ～  とります [しゃしんを～] → しゃしんをとります
        //   giữ vị trí, bỏ ～    [〜を]ください          → をください
        final base = v.replaceRange(sq.start, sq.end, '').trim();
        return [
          ...expand(base),
          ...expand(inner.replaceFirst(_tildeFirst, base)),
          ...expand(
            v.replaceRange(sq.start, sq.end, inner.replaceAll(_tildeFirst, '')),
          ),
        ];
      }
      return [
        ...expand(v.replaceRange(sq.start, sq.end, inner)),
        ...expand(v.replaceRange(sq.start, sq.end, '')),
      ];
    }
    final rd = _round.firstMatch(v);
    if (rd != null) {
      return [
        ...expand(v.replaceRange(rd.start, rd.end, '')),
        ...expand(rd.group(1)!),
      ];
    }
    return [v];
  }

  final seen = <String>{};
  for (final v in source.split(RegExp(r'[/／]'))) {
    for (final e in expand(v)) {
      final n = normalize(e);
      if (n.isNotEmpty) seen.add(n);
    }
  }
  return seen.toList();
}

// ── Lớp nới lỏng (tuỳ chọn) ──────────────────────────────────────────────
// Áp SAU logic gốc, lên cả câu trả lời lẫn đáp án. Lõi ported ở trên không đổi,
// nên tắt hết tuỳ chọn là hành vi y hệt bản desktop.

final _katakanaRange = RegExp(r'[ァ-ヶ]');
final _longMark = RegExp(r'ー');

/// Nguyên âm lặp — bắt cả hai bảng chữ, KHÔNG quy đổi bảng này sang bảng kia.
final _doubledVowel = RegExp(r'([あいうえおアイウエオ])\1');

/// Katakana → hiragana. Chỉ dùng khi anh bật "chấp nhận lẫn kana".
String _toHiragana(String s) => s.replaceAllMapped(
  _katakanaRange,
  (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60),
);

/// Gộp các cách viết trường âm về một dạng: bỏ ー, thu gọn nguyên âm lặp,
/// và quy おう→お, えい→え — ba lỗi hay gặp nhất khi mới học.
///
/// Xử lý katakana ngay tại chỗ thay vì đổi sang hiragana rồi mới gộp. Bản cũ
/// làm cách sau, và thế là bật "bỏ qua trường âm" thì âm thầm bật luôn cả
/// "lẫn kana" — テープ khớp てーぷ trong khi công tắc kia đang tắt. Hai tuỳ
/// chọn phải độc lập với nhau.
String _foldLongVowel(String s) {
  var out = s.replaceAll(_longMark, '');
  while (_doubledVowel.hasMatch(out)) {
    out = out.replaceAllMapped(_doubledVowel, (m) => m.group(1)!);
  }
  return out
      .replaceAll('おう', 'お')
      .replaceAll('えい', 'え')
      .replaceAll('オウ', 'オ')
      .replaceAll('エイ', 'エ');
}

class Leniency {
  const Leniency({
    this.mixKana = false,
    this.ignoreLongVowel = false,
    this.realWords = const {},
  });
  static const strict = Leniency();

  final bool mixKana;
  final bool ignoreLongVowel;

  /// Mọi chuỗi là đáp án ĐÚNG NGHIÊM của một từ nào đó trong từ điển.
  ///
  /// Đây là cái chốt an toàn cho việc nới lỏng. Gộp trường âm làm sáu cặp từ
  /// có thật dính vào nhau, tệ nhất là bài 20: うん ("ừ") và ううん ("không")
  /// đều gộp về "うん". Không có chốt này thì gõ "có" khi đáp án là "không"
  /// vẫn được chấm đúng — và thống kê ghi nhận là anh đã thuộc.
  ///
  /// Luật: nếu chuỗi anh gõ tự nó đã là một từ thật khác, thì KHÔNG nới lỏng.
  /// Anh gõ đúng một từ, chỉ là nhầm từ.
  final Set<String> realWords;

  bool get isStrict => !mixKana && !ignoreLongVowel;

  String apply(String s) {
    var out = s;
    if (mixKana) out = _toHiragana(out);
    // KHÔNG đổi bảng chữ ở nhánh này — hai công tắc phải độc lập.
    if (ignoreLongVowel) out = _foldLongVowel(out);
    return out;
  }
}

/// Kết quả chấm, kèm lý do — màn đáp án cần biết vì sao để hiển thị cho đúng.
enum MatchKind { kana, lenient, latin, romaji, none }

class MatchResult {
  const MatchResult(this.correct, this.kind);
  final bool correct;
  final MatchKind kind;
}

/// Chấm một câu trả lời.
///
/// [answers] là các dạng đáp án gốc của cùng một từ (thường là `word` và `reading`).
/// [romaji] là cột phiên âm; truyền vào thì gõ `gakusei` cũng được tính đúng.
MatchResult checkAnswer(
  String userInput, {
  required List<String?> answers,
  String? romaji,
  Leniency leniency = Leniency.strict,
}) {
  final input = normalize(userInput);
  if (input.isNotEmpty) {
    for (final ans in answers) {
      if (expandVariants(ans).contains(input)) {
        return const MatchResult(true, MatchKind.kana);
      }
    }
    // Chỉ khi so nghiêm đã trượt mới hạ chuẩn — để lý do trả về vẫn phân biệt
    // được "đúng hẳn" với "đúng nhờ nới lỏng".
    //
    // Nhưng từ chối nới lỏng khi chuỗi anh gõ TỰ NÓ đã là một từ thật khác:
    // lúc đó anh không gõ thiếu trường âm, anh nhầm sang từ khác. Đây là chỗ
    // chặn うん ("ừ") được chấm đúng cho đáp án ううん ("không").
    if (!leniency.isStrict && !leniency.realWords.contains(input)) {
      final relaxed = leniency.apply(input);
      for (final ans in answers) {
        if (expandVariants(ans).any((f) => leniency.apply(f) == relaxed)) {
          return const MatchResult(true, MatchKind.lenient);
        }
      }
    }
  }

  final latin = normalizeLatin(userInput);
  if (latin.isEmpty) return const MatchResult(false, MatchKind.none);

  // Đáp án kiểu ＣＤ → gõ "CD" hay "ｃｄ" vẫn đúng.
  for (final ans in answers) {
    if (normalizeLatin(ans) == latin) {
      return const MatchResult(true, MatchKind.latin);
    }
  }

  // Nhánh romaji — phần thêm so với bản desktop.
  if (romaji != null) {
    for (final v in romaji.split(RegExp(r'[/／]'))) {
      if (normalizeLatin(v) == latin) {
        return const MatchResult(true, MatchKind.romaji);
      }
    }
  }

  return const MatchResult(false, MatchKind.none);
}

bool isCorrectAnswer(
  String userInput,
  List<String?> answers, {
  String? romaji,
  Leniency leniency = Leniency.strict,
}) => checkAnswer(
  userInput,
  answers: answers,
  romaji: romaji,
  leniency: leniency,
).correct;
