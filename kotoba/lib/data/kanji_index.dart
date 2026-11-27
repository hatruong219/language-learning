import 'kanji.dart';
import 'vocabulary.dart';

/// Một chặng học mảnh cấu tạo — 20 mảnh, xếp theo số chữ chứa nó giảm dần.
class PartStage {
  const PartStage({
    required this.number,
    required this.parts,
    required this.fullyUnlocked,
  });

  final int number;
  final List<KanjiPart> parts;

  /// Số chữ mở TRỌN sau khi học hết chặng này và mọi chặng trước.
  ///
  /// "Mở trọn" nghĩa là MỌI mảnh của chữ đó đều đã học. Đây là con số duy nhất
  /// được phép nói "mở khoá", khác hẳn [KanjiPart.containedIn]: 一 nằm trong 66
  /// chữ nhưng học một mình nó chỉ mở được đúng chữ 一.
  ///
  /// Là số TĨNH, tính từ thứ tự mảnh — giống nhau với mọi người dùng, không
  /// theo tiến độ. App không lưu trạng thái "đã học" cho mảnh.
  final int fullyUnlocked;

  String get label => 'Chặng $number';
  String get range =>
      'mảnh ${(number - 1) * KanjiIndex.stageSize + 1}'
      '–${(number - 1) * KanjiIndex.stageSize + parts.length}';
}

/// Những truy vấn phải ghép chữ Hán với từ vựng, hoặc phải tính toán trước.
///
/// Tách khỏi [KanjiSet] vì [KanjiSet] chỉ biết file kanji.json, còn ở đây cần
/// cả 2090 từ. Dựng một lần lúc khởi động: các bảng dưới đây quét toàn bộ từ
/// vựng nên không được tính lại trong hàm build của widget.
class KanjiIndex {
  KanjiIndex._(
    this.set,
    this._wordsByChar,
    this.questionWords,
    this.stages,
    this._kanjiByPart,
  );

  /// Số mảnh mỗi chặng. 181 mảnh chia thành 9 chặng, chặng cuối 21 mảnh.
  static const stageSize = 20;

  final KanjiSet set;

  /// chữ → những từ ra đề được có chứa chữ đó
  final Map<String, List<Word>> _wordsByChar;

  /// Toàn bộ từ dùng ra đề được. Luật lọc xem [_usableForQuestion].
  final List<Word> questionWords;

  final List<PartStage> stages;

  /// mảnh → những chữ có chứa mảnh đó
  final Map<String, List<Kanji>> _kanjiByPart;

  factory KanjiIndex.build(KanjiSet set, Vocabulary vocab) {
    final inSet = {for (final k in set.kanji) k.char};

    final questionWords = vocab.words
        .where((w) => _usableForQuestion(w, inSet))
        .toList(growable: false);

    final wordsByChar = <String, List<Word>>{};
    for (final w in questionWords) {
      for (final c in _kanjiChars(w.kanji!)) {
        (wordsByChar[c] ??= []).add(w);
      }
    }

    final kanjiByPart = <String, List<Kanji>>{};
    for (final k in set.kanji) {
      for (final p in k.parts) {
        (kanjiByPart[p] ??= []).add(k);
      }
    }

    return KanjiIndex._(
      set,
      wordsByChar,
      questionWords,
      _buildStages(set),
      kanjiByPart,
    );
  }

  /// Từ này ra đề kanji được không.
  ///
  /// Ba điều kiện, và cả ba đều cần:
  ///   1. có dạng viết bằng kanji — không có thì chẳng hỏi được gì
  ///   2. dạng đó chỉ gồm kanji và kana, không lẫn `～` hay ngoặc chú thích:
  ///      `～円` và `すいます [たばこを～]` không phải từ hoàn chỉnh để đưa lên đề
  ///   3. MỌI kanji trong từ đều nằm trong bộ đang học — hỏi 友達 khi người học
  ///      chưa biết chữ 達 là hỏi cái chưa dạy
  static bool _usableForQuestion(Word w, Set<String> inSet) {
    final form = w.kanji?.trim();
    if (form == null || form.isEmpty) return false;
    if (!_cleanForm.hasMatch(form)) return false;
    final chars = _kanjiChars(form);
    if (chars.isEmpty) return false;
    return chars.every(inSet.contains);
  }

  static final _cleanForm = RegExp(r'^[ぁ-ゖァ-ヺー一-鿿]+$');
  static final _kanjiOnly = RegExp(r'[一-鿿]');

  static List<String> _kanjiChars(String s) =>
      _kanjiOnly.allMatches(s).map((m) => m.group(0)!).toList(growable: false);

  static List<PartStage> _buildStages(KanjiSet set) {
    final out = <PartStage>[];
    final learned = <String>{};
    final n = set.parts.length;
    for (var i = 0; i < n; i += stageSize) {
      var end = (i + stageSize).clamp(0, n);
      // 181 mảnh chia 20 thì dư 1 — để nguyên sẽ sinh ra một chặng chỉ có ĐÚNG
      // MỘT mảnh, đọc như lỗi hiển thị. Phần dư nhỏ hơn nửa chặng thì dồn vào
      // chặng này luôn: 9 chặng, chặng cuối 21 mảnh.
      if (n - end < stageSize / 2) end = n;
      final chunk = set.parts.sublist(i, end);
      learned.addAll(chunk.map((p) => p.char));
      // Chữ nào MỌI mảnh đều đã học thì tính là mở trọn. Chữ không có dữ liệu
      // phân rã thì không tính — không biết nó gồm gì thì không thể nói đã mở.
      final done = set.kanji
          .where((k) => k.parts.isNotEmpty && k.parts.every(learned.contains))
          .length;
      out.add(
        PartStage(number: out.length + 1, parts: chunk, fullyUnlocked: done),
      );
      if (end == n) break;
    }
    return out;
  }

  /// Những từ ra đề được có chứa [char]. Rỗng nghĩa là chữ này KHÔNG kiểm tra
  /// được theo cách JLPT hỏi — vẫn học mặt chữ bình thường, chỉ là không ra đề.
  List<Word> wordsFor(String char) => _wordsByChar[char] ?? const [];

  /// Chữ này có ra đề được không. Đây là bộ lọc duy nhất trên thanh lọc màn
  /// Chữ Hán ("Có từ để luyện") — hữu dụng hơn `in_course` vì nó trả lời đúng
  /// câu người học cần: chữ này có thể bị hỏi hay không.
  bool testable(String char) => _wordsByChar.containsKey(char);

  /// Những chữ có chứa mảnh [part].
  List<Kanji> kanjiContaining(String part) => _kanjiByPart[part] ?? const [];

  /// Bài Minna no Nihongo SỚM NHẤT có từ chứa chữ này. null nghĩa là không bài
  /// nào — chữ đó chưa gặp trong giáo trình.
  ///
  /// Dùng để dán nhãn "bài 1" lên hàng chữ, trả lời câu người học hỏi đầu tiên:
  /// chữ này tôi đã học tới chưa.
  int? firstLesson(String char) {
    final words = _wordsByChar[char];
    if (words == null || words.isEmpty) return null;
    return words.map((w) => w.lesson).reduce((a, b) => a < b ? a : b);
  }

  /// Chữ đã lọc theo cấp và theo việc có ra đề được hay không.
  ///
  /// [levels] rỗng nghĩa là lấy cả hai cấp. [onlyTestable] là bộ lọc DUY NHẤT
  /// trên thanh lọc — "Có từ để luyện" — vì nó trả lời đúng câu người học cần:
  /// chữ này có thể bị hỏi hay không. Không dùng `in_course`: hai tập lệch nhau
  /// 21 + 73 chữ, và 73 chữ chỉ testable có thì toàn số đếm mà giáo trình bỏ qua
  /// vì coi như đã biết.
  List<Kanji> filter({
    Set<String> levels = const {},
    bool onlyTestable = false,
  }) => set.kanji
      .where(
        (k) =>
            (levels.isEmpty || levels.contains(k.level)) &&
            (!onlyTestable || testable(k.char)),
      )
      .toList(growable: false);

  /// Chữ ra đề được, lọc theo thang học ('N5' / 'N4').
  List<Kanji> testableByLevel(String level) => set.kanji
      .where((k) => k.level == level && testable(k.char))
      .toList(growable: false);

  /// Chữ KHÔNG ra đề được — màn chuẩn bị Kiểm tra phải nói rõ danh sách này
  /// thay vì âm thầm bỏ qua.
  List<Kanji> get notTestable =>
      set.kanji.where((k) => !testable(k.char)).toList(growable: false);
}
