import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';
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
              child: _ModeSwitch(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$done / $total',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 3,
            backgroundColor: c.sunken,
            valueColor: AlwaysStoppedAnimation(c.ai),
          ),
        ),
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final QuizMode mode;
  final ValueChanged<QuizMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(
            c,
            'Viết',
            mode == QuizMode.write,
            () => onChanged(QuizMode.write),
          ),
          _seg(
            c,
            'Đọc',
            mode == QuizMode.speak,
            () => onChanged(QuizMode.speak),
          ),
        ],
      ),
    );
  }

  Widget _seg(Palette c, String label, bool on, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: on ? c.card : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on ? c.ink : c.inkSoft,
            ),
          ),
        ),
      );
}
