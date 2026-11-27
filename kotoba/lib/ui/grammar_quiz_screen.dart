import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/grammar_quiz.dart';
import 'grammar_quiz_intro.dart';
import 'grammar_quiz_parts.dart';
import 'grammar_quiz_summary.dart';
import 'lesson_picker.dart';

/// Mục Bài tập — chuẩn bị, làm bài, tổng kết, tất cả trong một màn.
///
/// Không mở route mới cho phiên làm bài: mục này nằm trong tab, mở route sẽ che
/// mất thanh tab và người dùng mất đường quay lại. Giống hệt mục Kiểm tra kanji.
class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  /// Rỗng = tất cả các bài.
  Set<int> _lessons = const {};
  int _count = GrammarQuizBuilder.defaultLength;
  Set<GrammarQuizKind> _kinds = const {
    GrammarQuizKind.particle,
    GrammarQuizKind.meaning,
  };

  GrammarQuizSession? _session;
  bool _revealed = false;

  Future<void> _pick() async {
    final picked = await showLessonPicker(context, initial: _lessons);
    if (picked is PickLessons && mounted) {
      setState(() => _lessons = picked.lessons);
    }
  }

  void _start() {
    final questions = GrammarQuizBuilder(
      AppScope.of(context).grammar,
    ).build(count: _count, lessons: _lessons, kinds: _kinds);
    if (questions.isEmpty) return;
    setState(() {
      _session = GrammarQuizSession(questions);
      _revealed = false;
    });
  }

  void _answer(String option) => setState(() {
    _session!.answer(option);
    _revealed = true;
  });

  void _next() {
    _session!.advance();
    setState(() => _revealed = false);
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
      return GrammarQuizIntro(
        lessons: _lessons,
        count: _count,
        kinds: _kinds,
        onPick: _pick,
        onCount: (v) => setState(() => _count = v),
        onKinds: (v) => setState(() => _kinds = v),
        onStart: _start,
      );
    }
    if (s.isFinished) {
      return GrammarQuizSummary(session: s, onDone: _quit, onAgain: _start);
    }
    return GrammarQuizRunner(
      session: s,
      revealed: _revealed,
      onAnswer: _answer,
      onNext: _next,
      onSkip: _skip,
      onQuit: _quit,
    );
  }
}
