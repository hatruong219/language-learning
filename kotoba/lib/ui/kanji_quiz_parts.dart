import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/kanji_quiz.dart';
import '../theme.dart';
import 'answer_tally_view.dart';
import 'kanji_detail_sheet.dart';
import 'kanji_word_row.dart';

/// Màn làm bài: câu hỏi, bốn phương án, và phần chấm ngay sau khi chọn.
class KanjiQuizRunner extends StatelessWidget {
  const KanjiQuizRunner({
    super.key,
    required this.session,
    required this.revealed,
    required this.onAnswer,
    required this.onNext,
    required this.onSkip,
    required this.onQuit,
  });

  final KanjiQuizSession session;
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
        _Progress(session: session, onQuit: onQuit),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              _Prompt(question: q),
              const SizedBox(height: 18),
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
              const SizedBox(height: 8),
              if (revealed)
                FilledButton(
                  onPressed: onNext,
                  child: Text(
                    session.pendingCount <= 1
                        ? 'Xem kết quả'
                        : 'Câu tiếp theo →',
                  ),
                )
              else
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
          ),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.session, required this.onQuit});
  final KanjiQuizSession session;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = session.answeredCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done / ${session.total}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.inkSoft,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: session.total == 0 ? 0 : done / session.total,
                    minHeight: 4,
                    backgroundColor: c.sunken,
                    valueColor: AlwaysStoppedAnimation(c.ai),
                  ),
                ),
              ],
            ),
          ),
          // Thoát giữa chừng phải được, và điểm chốt tại đó. Không cho thoát thì
          // người dùng buộc phải làm hết mới ra được — đúng cái đã sửa ở phiên
          // từ vựng.
          IconButton(
            onPressed: onQuit,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Dừng phiên',
          ),
        ],
      ),
    );
  }
}

/// Đề bài: chuỗi cần đọc/viết, kèm NGHĨA hiện sẵn.
class _Prompt extends StatelessWidget {
  const _Prompt({required this.question});
  final KanjiQuestion question;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isReading = question.kind == KanjiQuizKind.reading;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Text(
            isReading
                ? 'Từ này đọc thế nào?'
                : 'Từ này viết bằng kanji ra sao?',
            style: TextStyle(fontSize: 12.5, color: c.inkFaint),
          ),
          const SizedBox(height: 12),
          // Chuỗi đề KHÔNG scale: nó là hình để nhận dạng. Để nó phóng theo hệ
          // thống thì ở ×2.0 một từ bốn chữ tràn ngang và bản release cắt mất.
          MediaQuery.withNoTextScaling(
            child: Text(
              question.prompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: c.ink,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nghĩa hiện SẴN, không giấu sau nút. Đề thi thật đặt từ trong một câu
          // để có ngữ cảnh; ở đây chỉ có từ trơ nên nghĩa thay vai ngữ cảnh.
          Text(
            question.meaning,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: c.inkSoft, height: 1.35),
          ),
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
  final KanjiQuestion question;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isAnswer = text == question.answer;
    final isChosen = text == question.chosen;

    // Sau khi chấm: tô xanh đáp án đúng, tô đỏ phương án đã chọn nếu sai. Không
    // tô gì cho các phương án còn lại — tô hết thì mắt không biết nhìn đâu.
    Color? bg;
    Color? border;
    Color fg = c.ink;
    if (revealed) {
      if (isAnswer) {
        bg = c.matchaWash;
        border = c.matcha;
        fg = c.matcha;
      } else if (isChosen) {
        bg = c.shuWash;
        border = c.shu;
        fg = c.shu;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: bg ?? c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border ?? c.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: MediaQuery.withNoTextScaling(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 19,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ),
            if (revealed && isAnswer)
              Icon(Icons.check_rounded, size: 20, color: c.matcha)
            else if (revealed && isChosen)
              Icon(Icons.close_rounded, size: 20, color: c.shu),
          ],
        ),
      ),
    );
  }
}

/// Danh sách tổng kết luôn hiện chữ.

/// Tổng kết phiên kiểm tra.
class KanjiQuizSummary extends StatelessWidget {
  const KanjiQuizSummary({
    super.key,
    required this.session,
    required this.onDone,
    required this.onAgain,
  });

  final KanjiQuizSession session;
  final VoidCallback onDone;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    final wrong = session.wrongWords;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '${session.correctCount}',
                style: TextStyle(
                  fontSize: 58,
                  height: 1,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'đúng trên ${session.total} câu',
                style: TextStyle(fontSize: 15, color: c.inkFaint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TallyBars(tally: session),
        const SizedBox(height: 8),
        TallyLegend(tally: session, unit: 'câu'),
        const SizedBox(height: 22),
        if (wrong.isNotEmpty) ...[
          Text(
            '${wrong.length} TỪ CẦN ÔN LẠI',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: c.inkFaint,
            ),
          ),
          const SizedBox(height: 8),
          // Ghi nợ theo TỪ, không theo chữ: ở dạng 漢字読み không cách nào biết
          // chắc người học vấp ở chữ nào trong từ. Và đây là cùng một danh sách
          // "Cần học lại" với phần từ vựng, không phải danh sách thứ hai.
          for (final w in wrong)
            KanjiWordRow(
              key: ValueKey('kq-${w.id}'),
              word: w,
              onTapChar: (ch) {
                final k = scope.kanji.set.byChar(ch);
                if (k != null) showKanjiDetailSheet(context, k);
              },
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              scope.progress.starAll(wrong.map((w) => w.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã thêm ${wrong.length} từ vào Cần học lại'),
                ),
              );
            },
            icon: const Icon(Icons.star_rounded, size: 19),
            label: Text('Thêm cả ${wrong.length} từ vào Cần học lại'),
            style: FilledButton.styleFrom(
              backgroundColor: c.kinchaWash,
              foregroundColor: c.kincha,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onAgain,
                child: const Text('Làm phiên mới'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: onDone,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(color: c.line),
                  foregroundColor: c.inkSoft,
                ),
                child: const Text('Hoàn tất'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
