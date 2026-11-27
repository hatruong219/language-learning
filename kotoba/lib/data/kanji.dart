import 'data_cache.dart';

/// Một chữ Hán. Bất biến — nạp một lần từ asset rồi dùng chung cả app.
class Kanji {
  const Kanji({
    required this.char,
    required this.level,
    required this.levelRef,
    required this.inCourse,
    required this.on,
    required this.kun,
    required this.hanViet,
    required this.meaningEn,
    required this.parts,
    required this.strokes,
    required this.grade,
    required this.frequency,
    this.kyujitai,
    this.meaningVi,
    this.meaningClassic,
  });

  final String char;

  /// Thang HỌC — app lọc bài theo trường này. Chỉ có 'N5' hoặc 'N4'.
  ///
  /// Rộng hơn cấp thi: N5 lấy từ danh sách ôn thi tiếng Việt (103 chữ). Học sớm
  /// một chữ hoá ra thuộc N4 thì không mất gì; bỏ sót một chữ thật sự ra ở N5
  /// thì mất điểm.
  final String level;

  /// Cấp thi KIỂM CHỨNG ĐƯỢC, từ thang 5 mức sau kỳ đổi đề 2010. Có thể là
  /// 'N3'..'N1' — nghĩa là chữ đó thật ra nằm ngoài phạm vi thi N4, xuất hiện
  /// trong bộ vì giáo trình dạy sớm.
  final String levelRef;

  /// Có trong giáo trình kanji N5/N4 tiếng Việt.
  ///
  /// KHÔNG đồng nghĩa với "có từ vựng để luyện" — xem [KanjiIndex.testable].
  /// Hai tập lệch nhau ở 21 + 73 chữ, và đó là bình thường: giáo trình liệt kê
  /// mặt chữ, từ vựng là chuyện khác.
  final bool inCourse;

  final List<String> on;
  final List<String> kun;

  /// Âm Hán-Việt, ĐÃ LỌC BỎ ÂM NÔM. Âm chính đứng đầu.
  final List<String> hanViet;

  final List<String> meaningEn;

  /// Nghĩa tiếng Việt theo cách dùng trong tiếng NHẬT. Chỉ 130/364 chữ có;
  /// còn lại null và giao diện phải ghi rõ là chưa có, đừng để ô trống trơn.
  final String? meaningVi;

  /// Nghĩa HÁN CỔ (Thiều Chửu 1942) — dùng như TỪ NGUYÊN, không phải nghĩa.
  ///
  /// Cụ ghi 学 "Bắt chước", 時 "Mùa", 住 "Thôi" — đúng với chữ Hán cổ nhưng sai
  /// với tiếng Nhật. Đừng bao giờ hiển thị trường này ở ô "nghĩa".
  final String? meaningClassic;

  /// Tự dạng CỰU (旧字体) — 学→學, 気→氣. null nghĩa là không có dạng cũ khác.
  final String? kyujitai;

  final List<String> parts;
  final int strokes;
  final int grade;
  final int frequency;

  /// Âm Hán-Việt chính, hoa chữ đầu để hiển thị: 'học' → 'Học'.
  String get hanVietLabel {
    if (hanViet.isEmpty) return '';
    final s = hanViet.first;
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  /// Cấp thi có cao hơn phạm vi N4 không. Giao diện dùng để nói thật với người
  /// học rằng chữ này thực tế chưa ra ở N4.
  bool get beyondN4 => level != levelRef;

  factory Kanji.fromJson(Map<String, dynamic> j) => Kanji(
    char: j['c'] as String,
    level: (j['level'] ?? 'N4') as String,
    levelRef: (j['level_ref'] ?? j['level'] ?? 'N4') as String,
    inCourse: (j['in_course'] ?? false) as bool,
    on: _strings(j['on']),
    kun: _strings(j['kun']),
    hanViet: _strings(j['hv']),
    meaningEn: _strings(j['en']),
    meaningVi: _text(j['meaning_vi']),
    meaningClassic: _text(j['meaning_classic']),
    kyujitai: _text(j['kyujitai']),
    parts: _strings(j['parts']),
    strokes: (j['strokes'] ?? 0) as int,
    grade: (j['grade'] ?? 0) as int,
    frequency: (j['freq'] ?? 0) as int,
  );
}

/// Một mảnh cấu tạo — phần lớn là bộ thủ Kangxi, vài cái là hình nét.
class KanjiPart {
  const KanjiPart({
    required this.char,
    required this.containedIn,
    required this.inSet,
    required this.isShape,
    required this.hanViet,
    required this.meaningEn,
    this.meaningVi,
    this.meaningClassic,
    this.radicalOf,
    this.radicalStrokes,
  });

  final String char;

  /// Bao nhiêu chữ trong bộ CÓ CHỨA mảnh này.
  ///
  /// Đặt tên `containedIn` chứ không phải `unlocks`: 一 có 66 nhưng học xong 一
  /// chỉ đọc được đúng chữ 一, vì 亜 còn cần ｜ và 口. Nhãn "mở khoá 66 chữ" là
  /// nói quá — số "mở trọn" thật nằm ở [KanjiIndex.fullyUnlockedAfter].
  final int containedIn;

  /// Mảnh này bản thân cũng là một chữ trong bộ 364.
  final bool inSet;

  /// HÌNH NÉT, không phải chữ: KRADFILE mượn katakana làm ký hiệu (ハ, マ).
  /// Không có tên, không có nghĩa — và đó là đúng, không phải khuyết dữ liệu.
  final bool isShape;

  /// Tên bộ thủ theo cách người Việt gọi: 宀 là 'miên', 氵 là 'thuỷ'.
  final List<String> hanViet;

  final List<String> meaningEn;

  /// Nghĩa tiếng Việt. 146/181 mảnh có. Riêng 亠 có tên 'đầu' nhưng KHÔNG có
  /// nghĩa — nguồn gốc ghi thẳng "không có nghĩa", nên null ở đó là đúng.
  final String? meaningVi;

  final String? meaningClassic;

  /// Dạng GỐC khi mảnh này là biến thể: 氵 co lại từ 水, 忄 từ 心.
  final String? radicalOf;

  final int? radicalStrokes;

  String get hanVietLabel {
    if (hanViet.isEmpty) return '';
    final s = hanViet.first;
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  factory KanjiPart.fromJson(Map<String, dynamic> j) => KanjiPart(
    char: j['c'] as String,
    containedIn: (j['unlocks'] ?? 0) as int,
    inSet: (j['in_set'] ?? false) as bool,
    isShape: (j['is_shape'] ?? false) as bool,
    hanViet: _strings(j['hv']),
    meaningEn: _strings(j['en']),
    meaningVi: _text(j['meaning_vi']),
    meaningClassic: _text(j['meaning_classic']),
    radicalOf: _text(j['radical_of']),
    radicalStrokes: j['radical_strokes'] as int?,
  );
}

List<String> _strings(Object? v) => v is List
    ? v
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList(growable: false)
    : const [];

/// Chuỗi rỗng trong JSON coi như không có — đỡ phải kiểm cả null lẫn '' ở mọi
/// chỗ dùng.
String? _text(Object? v) {
  if (v is! String) return null;
  final s = v.trim();
  return s.isEmpty ? null : s;
}

/// Toàn bộ chữ Hán và mảnh cấu tạo, nạp một lần lúc khởi động.
class KanjiSet {
  KanjiSet._(this.kanji, this.parts, this._byChar, this._partByChar);

  final List<Kanji> kanji;

  /// Xếp giảm dần theo số chữ chứa nó — thứ tự này là căn cứ chia chặng học,
  /// nên đừng sắp lại ở chỗ khác.
  final List<KanjiPart> parts;

  final Map<String, Kanji> _byChar;
  final Map<String, KanjiPart> _partByChar;

  /// Nạp dữ liệu: ưu tiên bản đã tải về, chưa có thì lấy bản đóng gói.
  ///
  /// Đi qua [kanjiCache] chứ không đọc thẳng asset, để bấm đồng bộ một lần là
  /// những lần mở app sau đều thấy dữ liệu mới. Mở app vẫn không cần mạng.
  static Future<KanjiSet> load() async =>
      KanjiSet.fromJson(await kanjiCache.read());

  factory KanjiSet.fromJson(Map<String, dynamic> json) {
    final kanji = (json['kanji'] as List)
        .cast<Map<String, dynamic>>()
        .map(Kanji.fromJson)
        .toList(growable: false);
    final parts = (json['components'] as List)
        .cast<Map<String, dynamic>>()
        .map(KanjiPart.fromJson)
        .toList(growable: false);
    return KanjiSet._(
      kanji,
      parts,
      {for (final k in kanji) k.char: k},
      {for (final p in parts) p.char: p},
    );
  }

  Kanji? byChar(String c) => _byChar[c];
  KanjiPart? partByChar(String c) => _partByChar[c];

  List<Kanji> byLevel(String level) =>
      kanji.where((k) => k.level == level).toList(growable: false);
}
