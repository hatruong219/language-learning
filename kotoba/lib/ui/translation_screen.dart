import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/grammar.dart';
import '../quiz/grammar_quiz.dart';
import '../quiz/translation_check.dart';
import 'lesson_picker.dart';
import 'translation_screen_parts.dart';

/// Mục Luyện dịch: cho câu tiếng Việt, gõ lại bằng tiếng Nhật.
///
/// Gõ chứ không chọn. Chọn trong bốn phương án thì nhận ra mặt chữ là đủ, còn
/// gõ ra thì phải nhớ cả trợ từ lẫn đuôi động từ — sát với việc thi 文法 hơn.
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  static const _sessionLength = 10;

  Set<int> _lessons = const {};
  List<Sentence>? _queue;
  int _index = 0;
  TranslationResult? _result;
  int _correct = 0;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Câu dùng được: đã lọc rác, và không quá dài.
  ///
  /// Gõ tiếng Nhật trên điện thoại vốn đã chậm; bắt gõ lại câu 30 ký tự là bài
  /// kiểm tra sự kiên nhẫn chứ không phải kiểm tra ngữ pháp.
  List<Sentence> _pool() => [
    for (final s in AppScope.of(context).grammar.sentences)
      if ((_lessons.isEmpty || _lessons.contains(s.lesson)) &&
          GrammarQuizBuilder.usable(s) &&
          s.jaKana.length <= 24)
        s,
  ];

  Future<void> _pick() async {
    final picked = await showLessonPicker(context, initial: _lessons);
    if (picked is PickLessons && mounted) {
      setState(() => _lessons = picked.lessons);
    }
  }

  void _start() {
    final pool = _pool()..shuffle(Random());
    if (pool.isEmpty) return;
    setState(() {
      _queue = pool.take(_sessionLength).toList();
      _index = 0;
      _correct = 0;
      _result = null;
      _controller.clear();
    });
  }

  void _check() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final r = checkTranslation(text, _queue![_index]);
    setState(() {
      _result = r;
      if (r.correct) _correct++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _result = null;
      _controller.clear();
    });
  }

  void _quit() => setState(() => _queue = null);

  @override
  Widget build(BuildContext context) {
    final q = _queue;
    if (q == null) {
      return TranslationIntro(
        lessons: _lessons,
        onPick: _pick,
        onStart: _start,
      );
    }
    if (_index >= q.length) {
      return TranslationDone(
        correct: _correct,
        total: q.length,
        onAgain: _start,
        onDone: _quit,
      );
    }
    return TranslationRunner(
      sentence: q[_index],
      controller: _controller,
      result: _result,
      done: _index,
      total: q.length,
      onCheck: _check,
      onNext: _next,
      onQuit: _quit,
    );
  }
}
