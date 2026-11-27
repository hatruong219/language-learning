import 'data_cache.dart';

/// 448 từ vựng của PDF "TỔNG HỢP KANJI N5 N4" (MINATO DORIMU).
///
/// Đây là nguồn CHÍNH cho phần học chữ Hán — tài liệu người học đang dùng trên
/// lớp để đi thi. Tách hẳn với `vocabulary.json` (2090 từ Minna no Nihongo,
/// phần lớn viết bằng kana, phục vụ học theo giáo trình): hai mục đích khác
/// nhau nên không trộn.
///
/// KHÔNG chia cấp N5/N4. Đã thử ba cách, cả ba đều cho kết quả bịa hoặc vô
/// dụng — PDF bỏ hẳn 45 chữ N5 cơ bản vì coi như người học đã biết, nên nó là
/// tài liệu bổ sung cho người đã qua N5 dù tên ghi "N5 N4". Giữ nguyên thứ tự
/// PDF, vốn xếp theo chủ đề: gia đình, công việc, địa danh…

/// Một từ trong danh sách.
class KanjiWord {
  const KanjiWord({
    required this.n,
    required this.word,
    required this.hanViet,
    required this.kana,
    required this.meaning,
    required this.chars,
    required this.unknownChars,
    required this.level,
  });

  /// Số thứ tự trong PDF. Cũng là định danh — tiến độ lưu theo khoá này.
  final int n;

  /// Dạng viết như PDF ghi, GIỮ NGUYÊN.
  ///
  /// Có chỗ PDF cố ý viết chữ ngoài phạm vi bằng kana: 家ちん thay cho 家賃,
  /// 道ろ thay cho 道路. Đó là quy ước dạy học — chỉ để lộ chữ cần học — nên
  /// sửa lại là lệch với tài liệu trên lớp.
  final String word;

  /// Âm Hán-Việt, viết hoa như trong PDF. `GIA TỘC`, `HUYNH ĐỆ`.
  final String hanViet;

  /// Cách đọc, toàn kana.
  final String kana;

  final String meaning;

  /// Cấp độ JLPT, lấy THẲNG từ dữ liệu.
  ///
  /// App không hard-code danh sách cấp và cũng không tự suy ra. Hiện database
  /// ghi hết là N4 vì không có cách chia N5/N4 tự động cho đúng — sửa cấp trên
  /// database rồi bấm đồng bộ là app có ngay, không phải sửa mã, không phải
  /// build lại. Xem [KanjiWordSet.levels].
  final String level;

  /// Các chữ Hán có trong từ, theo thứ tự xuất hiện, đã bỏ trùng.
  final List<String> chars;

  /// Chữ mà app chưa có dữ liệu chi tiết — giao diện đừng vẽ liên kết bấm vào
  /// rồi rỗng. Hiện chỉ có 葉.
  final List<String> unknownChars;

  /// Khoá lưu tiến độ. Có tiền tố để không đụng id của 2090 từ Minna.
  String get id => 'kw$n';

  /// Từ ghép từ hai chữ Hán trở lên — phần đáng học nhất, vì đề thi hỏi trong
  /// từ chứ không hỏi chữ đơn.
  bool get isCompound => chars.length >= 2;

  bool get hasKanji => chars.isNotEmpty;

  factory KanjiWord.fromJson(Map<String, dynamic> j) => KanjiWord(
    n: j['n'] as int,
    word: j['word'] as String,
    hanViet: j['hv'] as String? ?? '',
    kana: j['kana'] as String,
    meaning: j['meaning'] as String? ?? '',
    chars: [for (final c in (j['chars'] as List? ?? const [])) c as String],
    unknownChars: [
      for (final c in (j['unknown'] as List? ?? const [])) c as String,
    ],
    level: (j['level'] as String?)?.trim() ?? '',
  );
}

/// Toàn bộ danh sách, kèm bảng tra.
class KanjiWordSet {
  KanjiWordSet._(this.words) : _byChar = _groupByChar(words);

  /// Theo đúng thứ tự PDF.
  final List<KanjiWord> words;

  final Map<String, List<KanjiWord>> _byChar;

  static Map<String, List<KanjiWord>> _groupByChar(List<KanjiWord> words) {
    final out = <String, List<KanjiWord>>{};
    for (final w in words) {
      for (final c in w.chars) {
        (out[c] ??= []).add(w);
      }
    }
    return out;
  }

  /// Mọi chữ Hán xuất hiện trong danh sách.
  late final List<String> chars = _byChar.keys.toList()..sort();

  /// Các cấp độ CÓ THẬT trong dữ liệu, xếp từ dễ tới khó.
  ///
  /// Gom từ dữ liệu chứ không viết cứng ['N5','N4']: hiện tất cả là N4 nên bộ
  /// lọc chỉ có một mục, nhưng hôm nào database phân lại cấp thì app tự có
  /// thêm nút — không phải sửa mã hai bên rồi build lại.
  ///
  /// Cấp lạ (không nằm trong thang JLPT) vẫn hiện, xếp xuống cuối: thà thấy
  /// một nhãn khó hiểu còn hơn im lặng giấu mất cả nhóm từ.
  late final List<String> levels = () {
    final found = {
      for (final w in words)
        if (w.level.isNotEmpty) w.level,
    };
    const order = ['N5', 'N4', 'N3', 'N2', 'N1'];
    final known = [
      for (final l in order)
        if (found.contains(l)) l,
    ];
    final rest = (found.toList()..sort()).where((l) => !order.contains(l));
    return [...known, ...rest];
  }();

  /// Các từ thuộc cấp này.
  List<KanjiWord> byLevel(String level) => [
    for (final w in words)
      if (w.level == level) w,
  ];

  /// Các từ chứa chữ này.
  List<KanjiWord> wordsWith(String char) => _byChar[char] ?? const [];

  KanjiWord? byId(String id) {
    for (final w in words) {
      if (w.id == id) return w;
    }
    return null;
  }

  /// Tìm theo chữ Hán, kana, âm Hán-Việt, hoặc nghĩa tiếng Việt.
  ///
  /// Không phân biệt hoa thường và bỏ dấu tiếng Việt ở phần nghĩa: gõ "gia
  /// dinh" phải ra 家族. Người dùng gõ trên bàn phím tiếng Nhật thì không bỏ
  /// dấu được, mà bắt gõ đúng dấu là gần như không tìm nổi.
  List<KanjiWord> search(String query) {
    final q = _fold(query);
    if (q.isEmpty) return words;
    return [
      for (final w in words)
        if (w.word.contains(query) ||
            w.kana.contains(query) ||
            _fold(w.hanViet).contains(q) ||
            _fold(w.meaning).contains(q))
          w,
    ];
  }

  static const _marks =
      'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩị'
      'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ';
  static const _plain =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiii'
      'ooooooooooooooooouuuuuuuuuuuyyyyyd';

  static String _fold(String s) {
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = _marks.indexOf(ch);
      buf.write(i < 0 ? ch : _plain[i]);
    }
    return buf.toString();
  }

  factory KanjiWordSet.fromJson(Map<String, dynamic> json) => KanjiWordSet._([
    for (final j in (json['words'] as List? ?? const []))
      KanjiWord.fromJson(j as Map<String, dynamic>),
  ]);

  static Future<KanjiWordSet> load() async =>
      KanjiWordSet.fromJson(await kanjiWordsCache.read());
}
