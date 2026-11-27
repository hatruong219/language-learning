import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/kanji_quiz.dart';
import 'kanji_quiz_intro.dart';
import 'kanji_quiz_parts.dart';

/// Mục Kiểm tra — chuẩn bị, làm bài, tổng kết, tất cả trong một màn.
///
/// Không mở route mới cho phiên làm bài: mục này nằm trong tab, mở route sẽ che
/// mất thanh tab và người dùng mất đường quay lại.
class KanjiQuizScreen extends StatefulWidget {
  const KanjiQuizScreen({super.key});

  @override
  State<KanjiQuizScreen> createState() => _KanjiQuizScreenState();
}

class _KanjiQuizScreenState extends State<KanjiQuizScreen> {
  /// Chỉ ra đề bằng từ ghép từ 2 chữ trở lên.
  ///
  /// Từ ghép mới là chỗ dễ nhầm cách đọc — 生 trong 学生 đọc せい, trong
  /// 生まれる đọc う. Bật lên để luyện đúng chỗ đó.
  bool _onlyCompound = false;
  int _count = KanjiQuizBuilder.defaultLength;

  KanjiQuizSession? _session;

  /// Đã chọn đáp án cho câu hiện tại chưa. Chọn rồi thì các nút khoá lại và
  /// hiện đúng/sai — không cho đổi ý, vì đổi được thì điểm vô nghĩa.
  bool _revealed = false;

  void _start() {
    final questions = KanjiQuizBuilder(
      AppScope.of(context).kanjiWords,
    ).build(count: _count, onlyCompound: _onlyCompound);
    if (questions.isEmpty) return;
    setState(() {
      _session = KanjiQuizSession(questions);
      _revealed = false;
    });
  }

  void _answer(String option) {
    final q = _session!.current!;
    final ok = _session!.answer(option);
    // Ghi vào tiến độ của TỪ, giống hệt quiz từ vựng.
    //
    // Thiếu dòng này thì màn Thống kê chỉ đếm lượt của quiz từ vựng, và một
    // người học chủ yếu bằng quiz Kanji sẽ thấy thống kê gần như trống — mà
    // không hiểu vì sao. Ghi theo từ chứ không theo chữ vì ở dạng 漢字読み không
    // cách nào biết chắc người học vấp ở chữ nào trong từ.
    AppScope.of(context).progress.record(q.word.id, correct: ok);
    setState(() => _revealed = true);
  }

  void _next() {
    final more = _session!.advance();
    setState(() => _revealed = false);
    // Hết câu thì KHÔNG đóng phiên: giữ lại để hiện tổng kết. `advance` trả
    // false mà con trỏ vẫn trỏ vào câu cuối, nên phải tự chuyển bằng cờ này.
    if (!more) setState(() {});
  }

  void _skip() {
    _session!.skip();
    _next();
  }

  void _quit() => setState(() {
    _session = null;
    _revealed = false;
  });

  @override
  Widget build(BuildContext context) {
    final s = _session;
    if (s == null) {
      return KanjiQuizIntro(
        onlyCompound: _onlyCompound,
        count: _count,
        onCompound: (v) => setState(() => _onlyCompound = v),
        onCount: (v) => setState(() => _count = v),
        onStart: _start,
      );
    }
    if (s.isFinished) {
      return KanjiQuizSummary(session: s, onDone: _quit, onAgain: _start);
    }
    return KanjiQuizRunner(
      session: s,
      revealed: _revealed,
      onAnswer: _answer,
      onNext: _next,
      onSkip: _skip,
      onQuit: _quit,
    );
  }
}
