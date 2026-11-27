import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'answer_tally_view.dart';
import 'star_feedback.dart';
import 'word_row.dart';

/// Tổng kết phiên. Đây cũng là chỗ nạp từ vào "Cần học lại" nhanh nhất —
/// một nút thay vì bấm sao sáu lần.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({
    super.key,
    required this.session,
    required this.onReviewWrong,
  });

  final QuizSession session;
  final VoidCallback onReviewWrong;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;
    final wrong = session.wrongWords;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Xong phiên thì câu hỏi đầu tiên trong đầu luôn là "được bao nhiêu"
          // — trả lời nó trước, chi tiết để nhỏ bên dưới.
          Center(
            child: Column(
              children: [
                Text(
                  '${session.correctCount}',
                  style: TextStyle(
                    fontSize: 62,
                    height: 1,
                    letterSpacing: -2,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'đúng trên ${session.total} từ',
                  style: TextStyle(fontSize: 15, color: c.inkFaint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TallyBars(tally: session),
          const SizedBox(height: 8),
          TallyLegend(tally: session),
          const SizedBox(height: 20),
          if (wrong.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '${wrong.length} TỪ CẦN ÔN LẠI',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: c.inkFaint,
                ),
              ),
            ),
            for (final w in wrong)
              WordRow(
                key: ValueKey('summary-${w.id}'),
                word: w,
                revealAll: _alwaysOn,
                starred: scope.progress.starListenable(w.id),
                alwaysRevealed: true,
                onSpeak: () => scope.speech.speak(
                  w.reading,
                  rate: scope.settings.speechRate,
                ),
                onToggleStar: () => toggleStarWithFeedback(context, w),
              ),
            const SizedBox(height: 14),
            // Nút này là lý do màn tổng kết đáng tồn tại: nó nối thẳng vòng lặp
            // học → sai → nằm ở trang chủ → hôm sau ôn lại.
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
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (wrong.isNotEmpty) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: onReviewWrong,
                    child: Text('Ôn lại ${wrong.length} từ sai'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(color: c.line),
                    foregroundColor: c.inkSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hoàn tất'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Danh sách tổng kết luôn hiện chữ, nên cờ chung cố định bật.
final ValueNotifier<bool> _alwaysOn = ValueNotifier(true);
