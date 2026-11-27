import 'data_cache.dart';

/// Ngữ pháp Minna no Nihongo 50 bài, và câu ví dụ Việt–Nhật.
///
/// Dạng dữ liệu giống hệt `/api/kotoba/grammar` bên web-mgmt-platform, nên bản
/// đóng gói và bản tải về dùng CHUNG bộ đọc này. Hai dạng khác nhau thì phải
/// nuôi hai đường đọc, và đường ít chạy hơn sẽ mục mà không ai biết.

/// Một mẫu ngữ pháp trong một bài.
class GrammarPattern {
  const GrammarPattern({
    required this.lesson,
    required this.ord,
    required this.pattern,
    required this.explain,
  });

  final int lesson;

  /// Thứ tự trong bài. Cùng với [lesson] tạo thành khoá để câu ví dụ trỏ về.
  final int ord;

  /// Bản thân mẫu, ví dụ `N1 は N2 です`.
  final String pattern;

  /// Giải thích tiếng Việt.
  final String explain;

  /// Khoá `bài:thứ-tự` — đúng dạng trường `grammar` của câu ví dụ.
  String get key => '$lesson:$ord';

  factory GrammarPattern.fromJson(Map<String, dynamic> j) => GrammarPattern(
    lesson: j['lesson'] as int,
    ord: j['ord'] as int,
    pattern: (j['pattern'] as String).trim(),
    explain: (j['explain'] as String?)?.trim() ?? '',
  );
}

/// Một câu ví dụ, kèm bản dịch.
class Sentence {
  const Sentence({
    required this.lesson,
    required this.grammarKey,
    required this.jaKanji,
    required this.jaKana,
    required this.vi,
    required this.hasFurigana,
  });

  final int lesson;

  /// Mẫu ngữ pháp mà câu này minh hoạ. Null nghĩa là câu không gắn mẫu nào.
  final String? grammarKey;

  /// Bản có kanji — bản để ĐỌC.
  final String jaKanji;

  /// Bản toàn kana — bản để GÕ.
  ///
  /// Nhờ có sẵn hai bản mà phần luyện dịch chấm được cả hai kiểu gõ, không phải
  /// tách từ lúc chạy. Nguồn nào không ghi furigana thì hai bản bằng nhau và
  /// [hasFurigana] = false; đó là sự thật chứ không phải thiếu dữ liệu.
  final String jaKana;

  final String vi;
  final bool hasFurigana;

  factory Sentence.fromJson(Map<String, dynamic> j) => Sentence(
    lesson: j['lesson'] as int,
    grammarKey: j['grammar'] as String?,
    jaKanji: (j['ja_kanji'] as String).trim(),
    jaKana: (j['ja_kana'] as String).trim(),
    vi: (j['vi'] as String).trim(),
    hasFurigana: j['has_furigana'] as bool? ?? false,
  );
}

/// Toàn bộ ngữ pháp, kèm sẵn các bảng tra.
class GrammarSet {
  GrammarSet._(this.patterns, this.sentences)
    : _byLesson = _group(patterns, (p) => p.lesson),
      _sentencesByLesson = _group(sentences, (s) => s.lesson),
      _sentencesByPattern = _group(
        sentences.where((s) => s.grammarKey != null),
        (s) => s.grammarKey!,
      );

  final List<GrammarPattern> patterns;
  final List<Sentence> sentences;

  final Map<int, List<GrammarPattern>> _byLesson;
  final Map<int, List<Sentence>> _sentencesByLesson;
  final Map<String, List<Sentence>> _sentencesByPattern;

  static Map<K, List<V>> _group<K, V>(Iterable<V> items, K Function(V) key) {
    final out = <K, List<V>>{};
    for (final item in items) {
      (out[key(item)] ??= []).add(item);
    }
    return out;
  }

  /// Các bài CÓ ngữ pháp, theo thứ tự.
  ///
  /// Không phải cứ 1..50: nếu nguồn thiếu một bài thì bài đó không được hiện ra
  /// như một mục rỗng bấm vào chẳng có gì.
  late final List<int> lessons = _byLesson.keys.toList()..sort();

  List<GrammarPattern> byLesson(int lesson) => _byLesson[lesson] ?? const [];

  List<Sentence> sentencesOf(GrammarPattern p) =>
      _sentencesByPattern[p.key] ?? const [];

  List<Sentence> sentencesInLesson(int lesson) =>
      _sentencesByLesson[lesson] ?? const [];

  /// Câu dùng được cho phần luyện dịch.
  ///
  /// Câu quá dài thì gõ lại là bài kiểm tra sự kiên nhẫn chứ không phải kiểm
  /// tra ngữ pháp — mà gõ tiếng Nhật trên điện thoại vốn đã chậm.
  List<Sentence> translatable(Set<int> lessons, {int maxLength = 30}) => [
    for (final s in sentences)
      if (lessons.contains(s.lesson) && s.jaKana.length <= maxLength) s,
  ];

  factory GrammarSet.fromJson(Map<String, dynamic> json) {
    final patterns = [
      for (final j in (json['grammar'] as List? ?? const []))
        GrammarPattern.fromJson(j as Map<String, dynamic>),
    ];
    final sentences = [
      for (final j in (json['sentences'] as List? ?? const []))
        Sentence.fromJson(j as Map<String, dynamic>),
    ];
    return GrammarSet._(patterns, sentences);
  }

  static Future<GrammarSet> load() async =>
      GrammarSet.fromJson(await grammarCache.read());
}
