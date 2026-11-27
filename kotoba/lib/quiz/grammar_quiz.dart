import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/grammar.dart';
import 'answer_tally.dart';

/// Hai dạng bài tập ngữ pháp, cả hai đều dựng được từ dữ liệu đang có.
enum GrammarQuizKind {
  /// Điền trợ từ vào chỗ trống. Đây là dạng 助詞 — phần 文法 của N5/N4 hỏi
  /// nhiều nhất, và cũng là chỗ người Việt sai nhiều nhất vì tiếng Việt không
  /// có trợ từ tương ứng.
  particle,

  /// Cho câu tiếng Nhật, chọn bản dịch đúng. Kiểm được là hiểu cả câu, không
  /// phải nhặt ra một từ quen rồi đoán.
  meaning,
}

/// Một câu hỏi ngữ pháp đã dựng xong.
class GrammarQuestion {
  GrammarQuestion({
    required this.kind,
    required this.sentence,
    required this.prompt,
    required this.answer,
    required this.options,
    this.hint = '',
  });

  final GrammarQuizKind kind;
  final Sentence sentence;

  /// Đề bài: câu đã khoét lỗ (particle) hoặc câu tiếng Nhật đầy đủ (meaning).
  final String prompt;

  final String answer;
  final List<String> options;

  /// Dòng gợi ý dưới đề — bản dịch, để biết câu đang nói gì mà chọn trợ từ.
  final String hint;

  AnswerState state = AnswerState.pending;
  String chosen = '';
  bool get answered => state != AnswerState.pending;
}

/// Dựng đề ngữ pháp từ kho câu ví dụ.
class GrammarQuizBuilder {
  GrammarQuizBuilder(this.grammar, {int? seed}) : _rng = Random(seed);

  static const defaultLength = 10;
  static const optionCount = 4;

  /// Chỗ trống chỉ khoét vào những trợ từ MỘT ký tự này.
  ///
  /// Trợ từ nhiều ký tự (から, まで, より) khoét ra thì nhìn độ dài chỗ trống là
  /// đoán được, hỏng cả câu hỏi.
  static const particles = ['は', 'が', 'を', 'に', 'で', 'と', 'も', 'へ', 'の', 'や'];

  /// Cặp hay lẫn nhau — dùng làm phương án nhiễu trước tiên.
  ///
  /// Nhiễu ngẫu nhiên thì loại được bằng cảm giác; nhiễu đúng cặp hay lẫn mới
  /// bắt người học phải thật sự biết luật.
  ///
  /// Mọi giá trị ở đây PHẢI nằm trong [particles]. Nhiễu nằm ngoài tập được
  /// khoét thì nó không bao giờ là đáp án, và học vài phiên là loại được nó mà
  /// không cần đọc câu — đúng thứ câu hỏi trắc nghiệm phải tránh.
  static const _confusable = {
    'は': ['が', 'も', 'を'],
    'が': ['は', 'を', 'に'],
    'を': ['が', 'は', 'に'],
    'に': ['で', 'へ', 'を'],
    'で': ['に', 'を', 'と'],
    'と': ['に', 'や', 'で'],
    'も': ['は', 'が', 'を'],
    'へ': ['に', 'で', 'を'],
    'の': ['が', 'は', 'に'],
    'や': ['と', 'も', 'の'],
  };

  final GrammarSet grammar;
  final Random _rng;

  static final _kanji = RegExp(r'[一-鿿]');

  /// Ký tự tố cáo câu còn dính rác của nguồn.
  ///
  /// Riki trộn số thứ tự bài tập, nhãn người nói, và chú thích vào cùng ô với
  /// câu: `例2：このパソコンの…`, `男の人：重いでしょう？`, `（国へ帰ります）`.
  /// Đọc thì vẫn hiểu, nhưng đưa vào đề trắc nghiệm thì thành đề hỏng — nhất là
  /// khi chỗ trống rơi đúng vào phần trong ngoặc.
  static final _dirty = RegExp(r'[例：:\[\]（）()＝→※…]');

  /// Câu dùng được làm ĐỀ. Lỏng hơn thì đề nhìn như lỗi hiển thị.
  static bool usable(Sentence s) =>
      !_dirty.hasMatch(s.jaKanji) &&
      !_dirty.hasMatch(s.vi) &&
      s.jaKanji.length <= 34 &&
      s.vi.length >= 6;

  /// Dựng [count] câu cho các bài đã chọn. [lessons] rỗng nghĩa là lấy tất cả.
  List<GrammarQuestion> build({
    int count = defaultLength,
    Set<int> lessons = const {},
    Set<GrammarQuizKind> kinds = const {
      GrammarQuizKind.particle,
      GrammarQuizKind.meaning,
    },
  }) {
    if (kinds.isEmpty) return const [];
    final pool = [
      for (final s in grammar.sentences)
        if ((lessons.isEmpty || lessons.contains(s.lesson)) && usable(s)) s,
    ];
    if (pool.isEmpty) return const [];

    final picked = [...pool]..shuffle(_rng);
    final kindList = kinds.toList();
    final out = <GrammarQuestion>[];
    // Không hỏi lại cùng một câu trong một phiên: nguồn có câu lặp nguyên văn
    // giữa các mẫu, gặp lại làm phiên trông như hết đề.
    final used = <String>{};

    for (final s in picked) {
      if (out.length >= count) break;
      if (!used.add(s.jaKanji)) continue;
      final q = _make(s, kindList[_rng.nextInt(kindList.length)], pool);
      if (q != null) out.add(q);
    }
    return out;
  }

  GrammarQuestion? _make(
    Sentence s,
    GrammarQuizKind kind,
    List<Sentence> pool,
  ) => switch (kind) {
    GrammarQuizKind.particle => _particle(s),
    GrammarQuizKind.meaning => _meaning(s, pool),
  };

  /// Khoét MỘT trợ từ đứng ngay sau một chữ kanji.
  ///
  /// Ràng buộc "ngay sau kanji" là cách nhận trợ từ mà không cần tách từ. Kana
  /// đứng sau kanji gần như luôn là trợ từ, còn đuôi động từ (đọc→読みます,
  /// nghe→聞きます) dùng み・き・り… chứ không dùng は・が・を. Bỏ sót vài câu
  /// thì không sao — 1247 câu là thừa; khoét nhầm giữa một từ mới là hỏng, vì
  /// lúc đó đề không còn đáp án đúng nào.
  GrammarQuestion? _particle(Sentence s) {
    final text = s.jaKanji;
    final spots = <int>[];
    for (var i = 1; i < text.length; i++) {
      if (!particles.contains(text[i])) continue;
      if (!_kanji.hasMatch(text[i - 1])) continue;
      // で của です／でした／ではありません là hệ từ, KHÔNG phải trợ từ. Khoét
      // vào đó thì đề vô nghĩa: 便利◯す。 không có đáp án nào đúng, vì chỗ đó
      // không phải chỗ chọn trợ từ.
      final next = i + 1 < text.length ? text[i + 1] : '';
      if (text[i] == 'で' && 'すしは'.contains(next)) continue;
      // Cùng lý do: や của 冷やす／増やす là đuôi động từ, không phải trợ từ
      // "và". Kho hiện tại chưa có câu nào như thế, nhưng luật thì phải đúng
      // trước khi dữ liệu đổi, không phải sau.
      if (text[i] == 'や' && 'すし'.contains(next)) continue;
      spots.add(i);
    }
    if (spots.isEmpty) return null;

    final at = spots[_rng.nextInt(spots.length)];
    final answer = text[at];
    final distractors = <String>{};
    for (final p in [
      ...?_confusable[answer],
      ...particles.where((p) => p != answer),
    ]) {
      if (distractors.length >= optionCount - 1) break;
      if (p != answer) distractors.add(p);
    }

    return GrammarQuestion(
      kind: GrammarQuizKind.particle,
      sentence: s,
      prompt: '${text.substring(0, at)}◯${text.substring(at + 1)}',
      answer: answer,
      options: [answer, ...distractors]..shuffle(_rng),
      hint: s.vi,
    );
  }

  /// Câu tiếng Nhật → chọn bản dịch.
  ///
  /// Nhiễu phải khác hẳn đáp án về nội dung nhưng gần về độ dài: câu dịch dài
  /// gấp đôi ba câu kia thì chọn được mà không cần đọc tiếng Nhật.
  GrammarQuestion? _meaning(Sentence s, List<Sentence> pool) {
    final answer = s.vi;
    if (answer.isEmpty) return null;

    final near = <String>[];
    final far = <String>[];
    for (final o in pool) {
      if (o.vi == answer || o.vi.isEmpty) continue;
      // Loại câu dịch trùng phần đầu: 「Anh Hải là bác sĩ.」 và 「Anh Hải là bác
      // sĩ phải không.」 đặt cạnh nhau thì không còn một đáp án đúng duy nhất.
      if (_tooClose(o.vi, answer)) continue;
      ((o.vi.length - answer.length).abs() <= 12 ? near : far).add(o.vi);
    }

    final options = <String>{};
    for (final bucket in [near, far]) {
      final shuffled = [...bucket]..shuffle(_rng);
      for (final v in shuffled) {
        if (options.length >= optionCount - 1) break;
        options.add(v);
      }
      if (options.length >= optionCount - 1) break;
    }
    if (options.length < optionCount - 1) return null;

    return GrammarQuestion(
      kind: GrammarQuizKind.meaning,
      sentence: s,
      prompt: s.jaKanji,
      answer: answer,
      options: [answer, ...options]..shuffle(_rng),
    );
  }

  static bool _tooClose(String a, String b) {
    final x = a.toLowerCase(), y = b.toLowerCase();
    if (x.contains(y) || y.contains(x)) return true;
    final n = min(x.length, y.length);
    var same = 0;
    while (same < n && x[same] == y[same]) {
      same++;
    }
    return same >= 10;
  }
}

/// Một phiên bài tập ngữ pháp. Đếm giống hệt phiên từ vựng và phiên kanji.
class GrammarQuizSession extends ChangeNotifier with AnswerTally {
  GrammarQuizSession(this.questions);

  final List<GrammarQuestion> questions;

  int _cursor = 0;
  int get cursor => _cursor;

  @override
  Iterable<AnswerState> get answerStates => questions.map((q) => q.state);

  GrammarQuestion? get current =>
      _cursor < questions.length ? questions[_cursor] : null;

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
    current?.state = AnswerState.skipped;
    notifyListeners();
  }

  /// Giống [KanjiQuizSession.advance]: trả false khi hết câu và KHÔNG dời con
  /// trỏ, để màn hình không dựng lại với câu rỗng trước khi kịp chuyển.
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
