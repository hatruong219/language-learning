import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'answer_matcher.dart';

/// Một từ vựng. Bất biến — nạp một lần từ asset rồi dùng chung cả app.
class Word {
  const Word({
    required this.id,
    required this.lesson,
    required this.word,
    required this.reading,
    required this.romaji,
    required this.meaning,
    required this.posVi,
    this.kanji,
  });

  /// Khoá ổn định để gắn tiến độ và làm key cho widget trong danh sách.
  /// Ghép từ bài + chữ gốc nên không đổi giữa các lần bóc lại dữ liệu.
  final String id;
  final int lesson;

  /// Dạng gốc trong giáo trình — có thể lẫn ngoặc chú thích, ví dụ `すいます [たばこを～]`.
  final String word;

  /// Kana sạch, dùng để hiển thị và để chấm.
  final String reading;
  final String romaji;
  final String meaning;
  final String posVi;

  /// Giữ lại dù chưa hiển thị — ngày nào học tới kanji thì bật lên là có ngay.
  final String? kanji;

  factory Word.fromJson(Map<String, dynamic> j) {
    final lesson = j['lesson'] as int;
    final word = (j['word'] ?? '') as String;
    return Word(
      id: '$lesson:$word',
      lesson: lesson,
      word: word,
      reading: (j['reading'] ?? '') as String,
      romaji: (j['romaji'] ?? '') as String,
      meaning: (j['meaning'] ?? '') as String,
      posVi: (j['pos_vi'] ?? '') as String,
      kanji: j['kanji'] as String?,
    );
  }

  /// Các dạng đáp án được chấp nhận, truyền thẳng cho [checkAnswer].
  List<String?> get answerForms => [word, reading];

  MatchResult check(String input, {Leniency leniency = Leniency.strict}) =>
      checkAnswer(
        input,
        answers: answerForms,
        romaji: romaji,
        leniency: leniency,
      );
}

class Lesson {
  const Lesson({
    required this.number,
    required this.title,
    required this.count,
  });
  final int number;
  final String title;
  final int count;

  String get label => 'Bài $number';
}

/// Toàn bộ từ vựng, nạp một lần lúc khởi động.
class Vocabulary {
  Vocabulary._(
    this.words,
    this.lessons,
    this._byId,
    this._homophones,
    this._bySpokenForm,
    this.strictForms,
  );

  final List<Word> words;
  final List<Lesson> lessons;
  final Map<String, Word> _byId;

  /// Mọi chuỗi được chấp nhận NGHIÊM cho bất kỳ từ nào trong 2090 từ.
  ///
  /// Dùng làm chốt an toàn khi nới lỏng chấm điểm: gõ trúng một từ thật khác
  /// thì không được hưởng nới lỏng. Xem [Leniency.realWords].
  final Set<String> strictForms;

  /// Mọi dạng chữ có thể do bộ nhận diện giọng nói trả về (kanji, dạng gốc,
  /// kana) → từ tương ứng. Tra bằng bảng băm vì hàm này chạy lại sau *mỗi* mẩu
  /// kết quả tạm thời của mic, quét tuyến tính 2090 từ ở đó là phí.
  final Map<String, Word> _bySpokenForm;

  /// Cách đọc đã chuẩn hoá → những từ cùng đọc như vậy.
  ///
  /// Vì app không hiện kanji nên あつい (nóng thời tiết) và あつい (nóng đồ vật)
  /// nhìn y hệt nhau. Vẫn hỏi thành hai câu riêng — chúng là hai từ khác nhau
  /// thật — nhưng màn đáp án cần nói rõ "cũng đọc là ..." kẻo anh tưởng app lặp.
  final Map<String, List<Word>> _homophones;

  static Future<Vocabulary> load() async {
    final raw = await rootBundle.loadString('assets/vocabulary.json');
    return Vocabulary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    final words = (json['words'] as List)
        .cast<Map<String, dynamic>>()
        .map(Word.fromJson)
        .toList(growable: false);

    final lessons = (json['lessons'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (l) => Lesson(
            number: l['n'] as int,
            title: (l['title'] ?? '') as String,
            count: (l['count'] ?? 0) as int,
          ),
        )
        .where((l) => l.count > 0)
        .toList(growable: false);

    final byId = {for (final w in words) w.id: w};

    // Dựng từ TẬP DẠNG ĐÃ KHAI TRIỂN chứ không phải reading thô. Bài 10 có
    // ～や và ～や～[など]: hai reading khác nhau nhưng cùng nhận chuỗi "や",
    // dùng reading thô thì không phát hiện được cặp này.
    final homophones = <String, List<Word>>{};
    for (final w in words) {
      for (final f in {
        ...expandVariants(w.word),
        ...expandVariants(w.reading),
      }) {
        homophones.putIfAbsent(f, () => []).add(w);
      }
    }
    homophones.removeWhere((_, v) => v.length < 2);

    final spoken = <String, Word>{};
    for (final w in words) {
      for (final form in [w.kanji, w.word, w.reading]) {
        final key = form?.trim();
        if (key != null && key.isNotEmpty) spoken.putIfAbsent(key, () => w);
      }
    }

    final strictForms = <String>{};
    for (final w in words) {
      strictForms.addAll(expandVariants(w.word));
      strictForms.addAll(expandVariants(w.reading));
    }

    return Vocabulary._(words, lessons, byId, homophones, spoken, strictForms);
  }

  Word? byId(String id) => _byId[id];

  /// Thứ hạng của từ trong giáo trình, để sắp lại sau khi tra theo id.
  late final Map<String, int> _rankById = {
    for (var i = 0; i < words.length; i++) words[i].id: i,
  };

  /// Các từ có id nằm trong [ids], theo ĐÚNG thứ tự giáo trình.
  ///
  /// Tra bằng bảng băm chứ không quét cả danh sách: chỗ gọi nó là danh sách
  /// "cần học lại", dựng lại mỗi lần bấm một ngôi sao. Quét 2090 từ cho vài
  /// chục từ đã đánh dấu là đủ để thấy khựng ngay lúc đang học.
  List<Word> byIds(Iterable<String> ids) {
    final out = <Word>[];
    for (final id in ids) {
      final w = _byId[id];
      if (w != null) out.add(w);
    }
    out.sort((a, b) => (_rankById[a.id] ?? 0).compareTo(_rankById[b.id] ?? 0));
    return out;
  }

  /// Bộ nhận diện của Apple luôn trả chữ có kanji — đọc せんせい thì nó trả 先生.
  /// App không hiện kanji, nên tra ngược về từ đã biết để hiện lại dạng kana.
  /// Không tra ra thì trả null, lúc đó thường là đọc trật thật.
  Word? bySpokenForm(String raw) => _bySpokenForm[raw.trim()];

  List<Word> byLessons(Set<int> lessonNumbers) =>
      words.where((w) => lessonNumbers.contains(w.lesson)).toList();

  /// Những từ khác đọc y hệt [word] — dùng cho dòng "cũng đọc là" ở màn đáp án.
  List<Word> homophonesOf(Word word) {
    final seen = <String>{};
    final out = <Word>[];
    for (final f in {
      ...expandVariants(word.word),
      ...expandVariants(word.reading),
    }) {
      for (final other in _homophones[f] ?? const <Word>[]) {
        if (other.id != word.id && seen.add(other.id)) out.add(other);
      }
    }
    return out;
  }

  /// Tìm theo nghĩa tiếng Việt, kana, hoặc romaji — không bắt chọn kiểu tìm.
  ///
  /// Luôn quét toàn bộ từ điển, kể cả khi màn hình đang lọc theo nhánh khác:
  /// tìm mà chỉ tìm trong 14 từ đã đánh dấu thì vô nghĩa.
  List<Word> search(String query, {int limit = 60}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final kana = normalize(query);
    final latin = normalizeLatin(query);

    final hits = <Word>[];
    for (final w in words) {
      final matched =
          w.meaning.toLowerCase().contains(q) ||
          (kana.isNotEmpty && normalize(w.reading).contains(kana)) ||
          (latin.isNotEmpty && normalizeLatin(w.romaji).contains(latin));
      if (matched) {
        hits.add(w);
        if (hits.length >= limit) break;
      }
    }
    return hits;
  }
}
