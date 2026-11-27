import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/kanji_words.dart';
import 'answer_tally.dart';

/// Hai dạng câu hỏi kanji của JLPT, và chỉ hai dạng này.
///
/// Phần 文字・語彙 của N5/N4 hỏi kanji đúng hai kiểu, luôn trắc nghiệm 4 đáp án,
/// và LUÔN hỏi trong một TỪ chứ không hỏi chữ đơn lẻ. Không có viết tay, không
/// có đọc thành tiếng, không hỏi bộ thủ.
enum KanjiQuizKind {
  /// 漢字読み — cho từ viết bằng kanji, chọn cách đọc kana.
  reading,

  /// 表記 — cho từ viết bằng kana, chọn dạng viết kanji.
  writing,
}

/// Một câu hỏi đã dựng xong, kèm bốn đáp án đã xáo.
class KanjiQuestion {
  KanjiQuestion({
    required this.kind,
    required this.word,
    required this.prompt,
    required this.answer,
    required this.options,
  });

  final KanjiQuizKind kind;

  /// Từ được hỏi. Giữ cả đối tượng vì khi sai thì đánh dấu CẢ TỪ vào "Cần học
  /// lại" — không tách ra chữ nào, vì ở dạng 漢字読み không cách nào biết chắc
  /// người học vấp ở chữ nào.
  final KanjiWord word;

  /// Chuỗi hiện trên đề: dạng kanji (reading) hoặc dạng kana (writing).
  final String prompt;
  final String answer;

  /// Bốn phương án, đã xáo, luôn chứa [answer].
  final List<String> options;

  /// Nghĩa tiếng Việt hiện SẴN cạnh câu hỏi.
  ///
  /// Đề thi thật đặt từ trong một câu để có ngữ cảnh; ở đây chỉ có từ trơ nên
  /// nghĩa thay vai ngữ cảnh. Hiện sẵn chứ không giấu sau nút bấm.
  String get meaning => word.meaning;

  AnswerState state = AnswerState.pending;

  /// Phương án người học đã chọn. Rỗng nghĩa là chưa chọn hoặc đã bỏ qua.
  String chosen = '';

  bool get answered => state != AnswerState.pending;
}

/// Dựng đề từ 448 từ của PDF MINATO.
///
/// Trước đây lấy từ 2090 từ Minna no Nihongo. Đổi nguồn vì đó là giáo trình
/// học trên lớp, phần lớn viết bằng kana, và chứa nhiều chữ ngoài phạm vi thi;
/// còn PDF là tài liệu người học dùng để LUYỆN THI. Ra đề đúng thứ đang học
/// thì mỗi câu sai mới chỉ ra được chỗ cần ôn.
class KanjiQuizBuilder {
  KanjiQuizBuilder(this.set, {int? seed}) : _rng = Random(seed);

  /// Số câu mặc định mỗi phiên. Mười câu đủ để thấy mình yếu chỗ nào mà chưa
  /// mất kiên nhẫn; người học đổi được trên màn chuẩn bị.
  static const defaultLength = 10;

  static const optionCount = 4;

  final KanjiWordSet set;
  final Random _rng;

  /// Từ dùng được để ra đề: phải có ít nhất một chữ Hán.
  ///
  /// PDF cố ý viết chữ ngoài phạm vi bằng kana (家ちん = 家賃), nên vẫn còn
  /// chữ Hán để hỏi — chỉ loại những từ không còn chữ nào.
  late final List<KanjiWord> pool = [
    for (final w in set.words)
      if (w.hasKanji) w,
  ];

  /// Chỉ những từ ghép từ hai chữ trở lên.
  late final List<KanjiWord> compoundPool = [
    for (final w in pool)
      if (w.isCompound) w,
  ];

  /// Dựng [count] câu.
  ///
  /// Mỗi từ chỉ hỏi MỘT lần trong phiên: gặp lại 家族 ở câu 3 và câu 8 làm
  /// phiên trông như hết đề.
  List<KanjiQuestion> build({
    int count = defaultLength,
    bool onlyCompound = false,
    Set<KanjiQuizKind> kinds = const {
      KanjiQuizKind.reading,
      KanjiQuizKind.writing,
    },
  }) {
    final source = onlyCompound ? compoundPool : pool;
    if (source.isEmpty || kinds.isEmpty) return const [];

    final picked = [...source]..shuffle(_rng);
    final wanted = min(count, picked.length);
    final kindList = kinds.toList();

    final out = <KanjiQuestion>[];
    for (final w in picked) {
      if (out.length >= wanted) break;
      final q = _make(w, kindList[_rng.nextInt(kindList.length)], source);
      if (q != null) out.add(q);
    }
    return out;
  }

  KanjiQuestion? _make(
    KanjiWord word,
    KanjiQuizKind kind,
    List<KanjiWord> source,
  ) {
    final answer = kind == KanjiQuizKind.reading ? word.kana : word.word;
    final prompt = kind == KanjiQuizKind.reading ? word.word : word.kana;
    if (answer.isEmpty || prompt.isEmpty) return null;

    final distractors = _distractors(word, kind, answer, source);
    if (distractors.length < optionCount - 1) return null;

    final options = [answer, ...distractors]..shuffle(_rng);
    return KanjiQuestion(
      kind: kind,
      word: word,
      prompt: prompt,
      answer: answer,
      options: options,
    );
  }

  /// Ba phương án sai, ưu tiên loại KHÓ.
  ///
  /// Nhiễu tốt nhất là từ CÙNG CHỨA một chữ với đáp án: hỏi 学生 thì nhiễu
  /// 学校 buộc người học phân biệt がくせい với がっこう — đúng chỗ đề thi nhắm.
  /// Nhiễu ngẫu nhiên thì loại được bằng độ dài, quá dễ.
  ///
  /// Hết nhiễu cùng chữ thì mới lấy theo độ dài xấp xỉ, và cuối cùng lấy bừa —
  /// thà câu dễ hơn là không dựng nổi câu.
  List<String> _distractors(
    KanjiWord word,
    KanjiQuizKind kind,
    String answer,
    List<KanjiWord> source,
  ) {
    final chars = word.chars.toSet();
    String formOf(KanjiWord w) =>
        kind == KanjiQuizKind.reading ? w.kana : w.word;

    final sharing = <String>[];
    final similar = <String>[];
    final rest = <String>[];
    for (final w in source) {
      if (w.id == word.id) continue;
      final f = formOf(w);
      if (f.isEmpty || f == answer) continue;
      if (w.chars.any(chars.contains)) {
        sharing.add(f);
      } else if ((f.length - answer.length).abs() <= 1) {
        similar.add(f);
      } else {
        rest.add(f);
      }
    }

    final out = <String>{};
    for (final bucket in [sharing, similar, rest]) {
      final shuffled = [...bucket]..shuffle(_rng);
      for (final f in shuffled) {
        if (out.length >= optionCount - 1) break;
        out.add(f);
      }
      if (out.length >= optionCount - 1) break;
    }
    return out.toList(growable: false);
  }
}

/// Một phiên kiểm tra kanji. Dùng chung cách đếm với phiên từ vựng.
class KanjiQuizSession extends ChangeNotifier with AnswerTally {
  KanjiQuizSession(this.questions);

  final List<KanjiQuestion> questions;

  int _cursor = 0;
  int get cursor => _cursor;

  @override
  Iterable<AnswerState> get answerStates => questions.map((q) => q.state);

  KanjiQuestion? get current =>
      _cursor < questions.length ? questions[_cursor] : null;

  /// Từ đã trả lời SAI. Đánh dấu theo TỪ, không theo chữ — xem [KanjiQuestion.word].
  List<KanjiWord> get wrongWords => questions
      .where((q) => q.state == AnswerState.wrong)
      .map((q) => q.word)
      .toList(growable: false);

  /// Chọn một phương án. Trả về đúng/sai để giao diện hiện ngay.
  bool answer(String option) {
    final q = current;
    if (q == null) return false;
    final ok = option == q.answer;
    q
      ..chosen = option
      ..state = ok ? AnswerState.correct : AnswerState.wrong;
    notifyListeners();
    return ok;
  }

  void skip() {
    final q = current;
    if (q == null) return;
    q.state = AnswerState.skipped;
    notifyListeners();
  }

  /// Nhảy tới câu chưa làm gần nhất phía sau con trỏ, vòng lại đầu nếu cần.
  ///
  /// Trả về false khi không còn câu nào, và KHÔNG dời con trỏ — [current] vẫn
  /// trỏ vào câu vừa làm. Giao diện phải dựa vào giá trị trả về để rời màn,
  /// đừng chờ [current] thành null. Cố ý giống [QuizSession.advance] để hai
  /// phiên hành xử như nhau; đổi thành null ở đây sẽ làm màn hình dựng lại với
  /// câu rỗng trong một khung hình trước khi kịp chuyển.
  bool advance() {
    for (var step = 1; step <= questions.length; step++) {
      final i = (_cursor + step) % questions.length;
      if (!questions[i].answered) {
        _cursor = i;
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }
}
