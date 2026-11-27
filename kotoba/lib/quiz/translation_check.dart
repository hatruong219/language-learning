import 'dart:math';

import '../data/answer_matcher.dart';
import '../data/grammar.dart';

/// Chấm bài dịch Việt → Nhật, và chỉ ra sai Ở ĐÂU.
///
/// Chỉ báo "sai rồi" thì người học không học được gì: câu 20 ký tự sai một trợ
/// từ và sai cả cấu trúc nhìn giống hệt nhau. Nên ngoài đúng/sai còn trả về một
/// bản đối chiếu từng đoạn — thiếu gì, thừa gì.
///
/// So với CẢ HAI bản của câu: bản kanji và bản toàn kana. Người học gõ
/// 私は学生です hay わたしはがくせいです đều phải được tính đúng, vì cả hai đều
/// là câu đó — chỉ khác bàn phím đang bật kiểu gì.

enum DiffKind {
  /// Gõ đúng.
  same,

  /// Đáp án có, người học không gõ.
  missing,

  /// Người học gõ thừa, đáp án không có.
  extra,
}

class DiffPart {
  const DiffPart(this.kind, this.text);
  final DiffKind kind;
  final String text;

  @override
  String toString() => '${kind.name}:$text';
}

class TranslationResult {
  const TranslationResult({
    required this.correct,
    required this.target,
    required this.parts,
    required this.similarity,
  });

  final bool correct;

  /// Bản đáp án được đem ra so — bản GẦN với câu người học gõ nhất.
  ///
  /// Gõ toàn kana thì đối chiếu với bản kana; có kanji thì đối chiếu bản kanji.
  /// So nhầm bản sẽ tô đỏ gần như cả câu dù người học chỉ sai một chữ.
  final String target;

  /// Đối chiếu từng đoạn, theo đúng thứ tự trong đáp án.
  final List<DiffPart> parts;

  /// Tỉ lệ ký tự khớp, 0..1. Dùng để nói "gần đúng" thay vì chỉ đúng/sai.
  final double similarity;

  bool get close => !correct && similarity >= 0.75;
}

/// Chấm [input] cho câu [s].
TranslationResult checkTranslation(String input, Sentence s) {
  final typed = normalize(input);
  final kanji = normalize(s.jaKanji);
  final kana = normalize(s.jaKana);

  if (typed.isNotEmpty && (typed == kanji || typed == kana)) {
    return TranslationResult(
      correct: true,
      target: s.jaKanji,
      parts: [DiffPart(DiffKind.same, s.jaKanji)],
      similarity: 1,
    );
  }

  // Chọn bản để đối chiếu theo bản nào giống hơn, KHÔNG theo "có kanji hay
  // không". Gõ đúng nửa câu bằng kanji rồi bỏ dở thì vẫn nên soi bản kanji.
  final byKanji = _diff(typed, kanji);
  final byKana = kana == kanji ? byKanji : _diff(typed, kana);
  final useKanji = _score(byKanji) >= _score(byKana);

  final parts = useKanji ? byKanji : byKana;
  return TranslationResult(
    correct: false,
    target: useKanji ? s.jaKanji : s.jaKana,
    parts: parts,
    similarity: _score(parts),
  );
}

/// Tỉ lệ khớp: số ký tự đúng chia cho ĐỘ DÀI CÂU DÀI HƠN.
///
/// Mẫu số không phải tổng mọi đoạn. Gõ nhầm một ký tự sinh ra HAI đoạn lệch —
/// một "thiếu" và một "thừa" — nên lấy tổng thì một lỗi bị trừ hai lần: câu 6
/// chữ sai đúng một trợ từ tụt xuống 0.71 và không còn được gọi là gần đúng,
/// dù người học chỉ hụt một chữ.
double _score(List<DiffPart> parts) {
  var same = 0, answerLen = 0, typedLen = 0;
  for (final p in parts) {
    final n = p.text.length;
    if (p.kind != DiffKind.extra) answerLen += n;
    if (p.kind != DiffKind.missing) typedLen += n;
    if (p.kind == DiffKind.same) same += n;
  }
  final longer = max(answerLen, typedLen);
  return longer == 0 ? 0 : same / longer;
}

/// Đối chiếu hai chuỗi theo dãy con chung dài nhất.
///
/// Câu dài nhất trong kho là 34 ký tự nên bảng 34×34 chạy tức thì; không cần
/// thuật toán khôn hơn, mà thuật toán khôn hơn thì khó đọc lại.
List<DiffPart> _diff(String typed, String answer) {
  final n = typed.length, m = answer.length;
  // lcs[i][j] = độ dài dãy con chung của typed[i..] và answer[j..].
  final lcs = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      lcs[i][j] = typed[i] == answer[j]
          ? lcs[i + 1][j + 1] + 1
          : max(lcs[i + 1][j], lcs[i][j + 1]);
    }
  }

  final out = <DiffPart>[];
  final buf = StringBuffer();
  DiffKind? kind;

  void flush() {
    if (buf.isNotEmpty && kind != null) {
      out.add(DiffPart(kind!, buf.toString()));
      buf.clear();
    }
  }

  void push(DiffKind k, String ch) {
    if (k != kind) {
      flush();
      kind = k;
    }
    buf.write(ch);
  }

  var i = 0, j = 0;
  while (i < n && j < m) {
    if (typed[i] == answer[j]) {
      push(DiffKind.same, answer[j]);
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      push(DiffKind.extra, typed[i]);
      i++;
    } else {
      push(DiffKind.missing, answer[j]);
      j++;
    }
  }
  while (i < n) {
    push(DiffKind.extra, typed[i++]);
  }
  while (j < m) {
    push(DiffKind.missing, answer[j++]);
  }
  flush();
  return out;
}
