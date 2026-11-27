import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'motion.dart';
import 'quiz_progress_bar.dart';
import 'quiz_screen_parts.dart';
import 'quiz_speak_panel.dart';
import 'quiz_verdict_panel.dart';
import 'quiz_write_panel.dart';

/// Màn trả lời — một màn hình riêng, không phải tấm nền trượt lên.
///
/// Bản trước dùng bottom sheet khoá cứng (`isDismissible: false`) để giữ danh
/// sách nhìn thấy phía trên. Sai: vào rồi là không thoát ra được giữa chừng,
/// mà học hành thì lúc nào cũng có việc chen ngang. Đổi thành màn riêng có
/// nút đóng, thoát lúc nào chốt điểm lúc đó.
Future<void> openQuizAnswerScreen(
  BuildContext context, {
  required QuizSession session,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => QuizAnswerScreen(session: session),
    ),
  );
}

class QuizAnswerScreen extends StatefulWidget {
  const QuizAnswerScreen({super.key, required this.session});

  final QuizSession session;

  @override
  State<QuizAnswerScreen> createState() => _QuizAnswerScreenState();
}

class _QuizAnswerScreenState extends State<QuizAnswerScreen> {
  final _input = TextEditingController();
  bool _showingVerdict = false;

  QuizSession get _s => widget.session;

  @override
  void initState() {
    super.initState();
    _s.addListener(_onSession);
  }

  @override
  void dispose() {
    _s.removeListener(_onSession);
    _input.dispose();
    super.dispose();
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  void _check(String raw) {
    final scope = AppScope.of(context);
    final item = _s.current;
    if (item == null) return;
    final answer = raw.trim();
    if (answer.isEmpty) return;

    final result = item.word.check(answer, leniency: scope.leniency);
    _s.submit(correct: result.correct, submitted: answer);
    scope.progress.record(item.word.id, correct: result.correct);

    if (scope.settings.autoSpeakAnswer) {
      scope.speech.speak(item.word.reading, rate: scope.settings.speechRate);
    }
    setState(() => _showingVerdict = true);
  }

  void _next() {
    _input.clear();
    setState(() => _showingVerdict = false);
    if (!_s.advance()) _leave();
  }

  void _skip() {
    _s.skip();
    _next();
  }

  /// Rời màn. Không hỏi lại, không cảnh báo — tiến độ đã ghi sau mỗi từ, thoát
  /// giữa chừng chỉ đơn giản là phiên ngắn hơn.
  void _leave() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final item = _s.current;
    if (item == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Dừng phiên',
          onPressed: _leave,
        ),
        titleSpacing: 0,
        title: _Progress(session: _s),
        actions: [
          if (!_showingVerdict)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ModeToggle(
                mode: _s.mode,
                onChanged: (m) {
                  _s.mode = m;
                  // Nhớ để lần sau mở ra đúng chế độ đang quen dùng.
                  AppScope.of(context).settings.lastModeIsSpeak =
                      m == QuizMode.speak;
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          // Mỗi câu mới / mỗi lần chấm là một khoá mới → khối nội dung hiện ra
          // lại từ đầu (mờ + trượt), người học cảm được "đã sang bước khác".
          child: EnterFadeSlide(
            key: ValueKey('${item.word.id}|$_showingVerdict|${_s.mode}'),
            fromScale: _showingVerdict ? 0.97 : 1,
            child: _showingVerdict
                ? QuizVerdictPanel(item: item, onNext: _next, onClose: _leave)
                : _s.mode == QuizMode.write
                ? WritePanel(
                    item: item,
                    controller: _input,
                    onSubmit: _check,
                    onSkip: _skip,
                  )
                : QuizSpeakPanel(
                    item: item,
                    onSubmit: _check,
                    onSkip: _skip,
                    onSwitchToWrite: () => _s.mode = QuizMode.write,
                  ),
          ),
        ),
      ),
      backgroundColor: c.paper,
    );
  }
}

/// Thanh tiến độ trên tiêu đề: đã làm bao nhiêu trên tổng bao nhiêu.
class _Progress extends StatelessWidget {
  const _Progress({required this.session});
  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = session.answeredCount;
    final total = session.total;
    // Chừa lề phải: lúc chấm điểm không còn nút Viết/Đọc, vạch kéo sát mép
    // màn hình trông như bị cắt.
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$done'),
                TextSpan(
                  text: ' / $total',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: c.inkFaint,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: c.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          ProgressTrack(done: done, total: total, height: 5),
        ],
      ),
    );
  }
}
