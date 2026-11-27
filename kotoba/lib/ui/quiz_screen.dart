import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/vocabulary.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'lesson_picker.dart';
import 'quiz_screen_parts.dart';
import 'quiz_answer_screen.dart';
import 'star_feedback.dart';
import 'summary_screen.dart';
import 'word_row.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _revealAll = ValueNotifier(false);
  QuizSession? _session;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dựng lại phiên từ bộ bài lần trước — mở app lên là học được ngay.
    // Chỉ làm một lần cho mỗi vòng đời màn hình: chuyển tab qua lại không
    // được xoá phiên đang dở.
    if (_restored) return;
    _restored = true;
    final scope = AppScope.of(context);
    final saved = scope.settings.lastLessons;
    if (saved.isEmpty) return;
    final words = scope.vocabulary.byLessons(saved);
    if (words.isEmpty) return;
    _startSession(words, saved);
  }

  @override
  void dispose() {
    _revealAll.dispose();
    _session?.dispose();
    super.dispose();
  }

  Future<void> _pickLessons() async {
    final scope = AppScope.of(context);
    final picked = await showLessonPicker(
      context,
      initial: _session?.lessons ?? const {},
      allowStarred: true,
    );
    if (picked == null || !mounted) return;
    switch (picked) {
      case PickStarred():
        _startStarred();
      case PickLessons(:final lessons):
        if (lessons.isEmpty) return;
        scope.settings.lastLessons = lessons;
        _startSession(scope.vocabulary.byLessons(lessons), lessons);
    }
  }

  /// Ôn lại những từ đã đánh dấu, không theo bài nào.
  ///
  /// Đây là vòng khép kín của app: học sai → đánh dấu → nằm ở trang chủ → ôn
  /// lại. Trước đó chỉ có đường xem lại danh sách, không có đường LUYỆN chúng.
  void _startStarred() {
    final scope = AppScope.of(context);
    final words = scope.progress.starredIds
        .map(scope.vocabulary.byId)
        .whereType<Word>()
        .toList();
    if (words.isEmpty) return;
    _startSession(words, const {}, title: 'Cần học lại');
  }

  void _startSession(List words, Set<int> lessons, {String? title}) {
    final scope = AppScope.of(context);
    _session?.dispose();
    setState(() {
      _session = QuizSession(
        words: words.cast(),
        lessons: lessons,
        title: title,
        shuffle: scope.settings.shuffle,
        mode:
            _session?.mode ??
            (scope.settings.lastModeIsSpeak ? QuizMode.speak : QuizMode.write),
      )..addListener(_onSession);
    });
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  Future<void> _openSheet(int index) async {
    final s = _session;
    if (s == null) return;
    s.jumpTo(index);
    await openQuizAnswerScreen(context, session: s);
    // Về tới đây nghĩa là anh đã thoát — hết từ, hoặc bấm đóng giữa chừng.
    // Có làm được từ nào thì mới chốt điểm; chưa làm gì thì về lại danh sách.
    if (mounted && s.answeredCount > 0) await _finish();
  }

  Future<void> _finish() async {
    final s = _session;
    if (s == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          session: s,
          onReviewWrong: () {
            Navigator.of(context).pop();
            _startSession(s.wrongWords, s.lessons);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = _session;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('Luyện tập'),
        actions: [
          if (s != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ModeToggle(mode: s.mode, onChanged: (m) => s.mode = m),
            ),
        ],
      ),
      // "Cần học lại" nằm TRONG bộ chọn bài, không phải nút riêng ở đây hay
      // chip riêng trong phiên. Với người học nó cũng chỉ là một phạm vi để
      // luyện, ngang hàng với "Bài 4" — tách ra là bắt nhớ thêm một chỗ.
      body: s == null ? QuizIntro(onPick: _pickLessons) : _sessionBody(c, s),
    );
  }

  Widget _sessionBody(Palette c, QuizSession s) {
    final scope = AppScope.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(
            children: [
              // Chip co được, ô đếm thì không: chữ "3/40" ngắn và quan trọng
              // hơn nhãn bài, nên cho nhãn nhường chỗ trước.
              Flexible(
                child: GestureDetector(
                  onTap: _pickLessons,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c.line),
                    ),
                    child: Text(
                      '${_lessonLabel(s)} ▼',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: c.inkSoft),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${s.answeredCount} / ${s.total}',
                style: TextStyle(fontSize: 12, color: c.inkFaint),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: s.items.length,
            itemExtent: rowExtent,
            itemBuilder: (context, i) {
              final item = s.items[i];
              return WordRow(
                key: ValueKey(item.word.id),
                word: item.word,
                revealAll: _revealAll,
                starred: scope.progress.starListenable(item.word.id),
                alwaysRevealed: item.answered,
                trailingStatus: switch (item.state) {
                  AnswerState.correct => c.matcha,
                  AnswerState.wrong => c.shu,
                  AnswerState.skipped => c.inkFaint,
                  AnswerState.pending => null,
                },
                onTap: item.answered ? null : () => _openSheet(i),
                onToggleStar: () => toggleStarWithFeedback(context, item.word),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: s.isFinished
                ? _finish
                // clamp(0, -1) ném lỗi nếu phiên rỗng — chặn từ đầu thay vì
                // để nó nổ ra thành màn trắng.
                : s.total == 0
                ? null
                : () => _openSheet(
                    s.items
                        .indexWhere((i) => !i.answered)
                        .clamp(0, s.total - 1),
                  ),
            child: Text(
              s.isFinished
                  ? 'Xem tổng kết'
                  : (s.answeredCount == 0 ? 'Bắt đầu' : 'Học tiếp'),
            ),
          ),
        ),
      ],
    );
  }

  String _lessonLabel(QuizSession s) {
    final t = s.title;
    if (t != null) return t;
    if (s.lessons.isEmpty) return 'Từ sai';
    if (s.lessons.length <= 2) {
      return s.lessons.map((n) => 'Bài $n').join(' · ');
    }
    return '${s.lessons.length} bài';
  }
}
