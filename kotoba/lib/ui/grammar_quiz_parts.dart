import 'package:flutter/material.dart';

import '../quiz/grammar_quiz.dart';
import '../theme.dart';
import 'quiz_progress_bar.dart';

/// Màn làm bài ngữ pháp: đề, bốn phương án, chấm ngay sau khi chọn.
class GrammarQuizRunner extends StatelessWidget {
  const GrammarQuizRunner({
    super.key,
    required this.session,
    required this.revealed,
    required this.onAnswer,
    required this.onNext,
    required this.onSkip,
    required this.onQuit,
  });

  final GrammarQuizSession session;
  final bool revealed;
  final ValueChanged<String> onAnswer;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final q = session.current!;
    final c = context.c;

    return Column(
      children: [
        QuizProgressBar(
          done: session.answeredCount,
          total: session.total,
          onQuit: onQuit,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              GrammarPrompt(question: q),
              const SizedBox(height: 16),
              for (final o in q.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _Option(
                    text: o,
                    question: q,
                    revealed: revealed,
                    onTap: revealed ? null : () => onAnswer(o),
                  ),
                ),
              // Sau khi chấm mới hiện câu đầy đủ và bản dịch. Hiện sẵn thì với
              // dạng chọn nghĩa là lộ luôn đáp án.
              if (revealed) ...[
                const SizedBox(height: 4),
                _Reveal(question: q),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onNext,
                  child: Text(
                    session.pendingCount <= 1
                        ? 'Xem kết quả'
                        : 'Câu tiếp theo →',
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(color: c.line),
                    foregroundColor: c.inkSoft,
                  ),
                  child: const Text('Bỏ qua câu này'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Đề bài.
class GrammarPrompt extends StatelessWidget {
  const GrammarPrompt({super.key, required this.question});
  final GrammarQuestion question;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final particle = question.kind == GrammarQuizKind.particle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: c.cardBox(radius: Radii.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            particle ? 'Điền trợ từ vào ◯' : 'Câu này nghĩa là gì?',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: c.inkFaint,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            question.prompt,
            style: TextStyle(fontSize: 18, height: 1.55, color: c.ink),
          ),
          if (question.hint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.hint,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: c.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.text,
    required this.question,
    required this.revealed,
    required this.onTap,
  });

  final String text;
  final GrammarQuestion question;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isAnswer = text == question.answer;
    final isChosen = text == question.chosen;

    // Sau khi chấm: tô xanh đáp án đúng, tô đỏ đúng ô đã chọn sai. Không tô đỏ
    // cả ba ô còn lại — người học cần thấy MÌNH chọn gì, không phải thấy ba ô
    // đỏ vô danh.
    var bg = c.card, border = c.line, fg = c.ink;
    if (revealed && isAnswer) {
      bg = c.matchaWash;
      border = c.matcha;
      fg = c.matcha;
    } else if (revealed && isChosen) {
      bg = c.shuWash;
      border = c.shu;
      fg = c.shu;
    }

    // Trợ từ là một ký tự — căn giữa cho dễ nhắm; câu dịch dài thì căn trái.
    final short = text.characters.length <= 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: revealed ? 1.5 : 1),
        ),
        child: Text(
          text,
          textAlign: short ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: short ? 20 : 14.5,
            height: 1.4,
            fontWeight: short ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Câu đầy đủ và bản dịch, hiện sau khi đã chấm.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.question});
  final GrammarQuestion question;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = question.sentence;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.jaKanji,
            style: TextStyle(fontSize: 15.5, height: 1.5, color: c.ink),
          ),
          if (s.hasFurigana) ...[
            const SizedBox(height: 3),
            Text(s.jaKana, style: TextStyle(fontSize: 12.5, color: c.inkFaint)),
          ],
          const SizedBox(height: 5),
          Text(
            s.vi,
            style: TextStyle(fontSize: 13.5, height: 1.45, color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}
