import 'package:flutter/material.dart';

import '../quiz/answer_tally.dart';
import '../quiz/grammar_quiz.dart';
import '../theme.dart';
import 'answer_tally_view.dart';

/// Tổng kết phiên: đếm bốn loại, rồi liệt kê câu sai để xem lại.
class GrammarQuizSummary extends StatelessWidget {
  const GrammarQuizSummary({
    super.key,
    required this.session,
    required this.onDone,
    required this.onAgain,
  });

  final GrammarQuizSession session;
  final VoidCallback onDone;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final missed = session.questions
        .where((q) => q.state != AnswerState.correct)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Text(
          'Kết quả',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 14),
        TallyBars(tally: session),
        const SizedBox(height: 10),
        TallyLegend(tally: session, unit: 'câu'),
        if (missed.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Xem lại ${missed.length} câu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          for (final q in missed) _MissedRow(question: q),
        ],
        const SizedBox(height: 22),
        FilledButton(onPressed: onAgain, child: const Text('Làm phiên mới')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onDone,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: BorderSide(color: c.line),
            foregroundColor: c.inkSoft,
          ),
          child: const Text('Xong'),
        ),
      ],
    );
  }
}

class _MissedRow extends StatelessWidget {
  const _MissedRow({required this.question});
  final GrammarQuestion question;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final skipped = question.state == AnswerState.skipped;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: c.cardBox(radius: Radii.row),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.sentence.jaKanji,
            style: TextStyle(fontSize: 14.5, height: 1.5, color: c.ink),
          ),
          const SizedBox(height: 4),
          Text(
            question.sentence.vi,
            style: TextStyle(fontSize: 12.5, height: 1.4, color: c.inkFaint),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Đáp án: ${question.answer}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: c.matcha,
                ),
              ),
              if (!skipped && question.chosen.isNotEmpty) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Đã chọn: ${question.chosen}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: c.shu),
                  ),
                ),
              ],
              if (skipped) ...[
                const SizedBox(width: 12),
                Text(
                  'Đã bỏ qua',
                  style: TextStyle(fontSize: 12.5, color: c.inkFaint),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
