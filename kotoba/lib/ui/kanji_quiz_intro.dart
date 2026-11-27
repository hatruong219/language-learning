import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/kanji_quiz.dart';
import '../theme.dart';
import 'quiz_progress_bar.dart';

/// Màn chuẩn bị phiên Kiểm tra chữ Hán.
class KanjiQuizIntro extends StatelessWidget {
  const KanjiQuizIntro({
    super.key,
    required this.onlyCompound,
    required this.count,
    required this.onCompound,
    required this.onCount,
    required this.onStart,
  });

  final bool onlyCompound;
  final int count;
  final ValueChanged<bool> onCompound;
  final ValueChanged<int> onCount;
  final VoidCallback onStart;

  static const counts = [5, 10, 20, 40];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final builder = KanjiQuizBuilder(AppScope.of(context).kanjiWords);
    final available = onlyCompound
        ? builder.compoundPool.length
        : builder.pool.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Text(
          'Hai dạng câu hỏi của đề thi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'JLPT hỏi kanji đúng hai kiểu, và luôn hỏi TRONG MỘT TỪ: cho từ viết '
          'bằng kanji thì chọn cách đọc, cho từ viết bằng kana thì chọn dạng '
          'kanji. Không có viết tay, không có đọc thành tiếng, không hỏi bộ thủ.',
          style: TextStyle(fontSize: 13, color: c.inkSoft, height: 1.45),
        ),
        const SizedBox(height: 22),
        const QuizFieldLabel('PHẠM VI'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Chỉ từ ghép từ 2 chữ trở lên',
                style: TextStyle(fontSize: 13.5, color: c.ink),
              ),
            ),
            Switch.adaptive(value: onlyCompound, onChanged: onCompound),
          ],
        ),
        Text(
          // Nói rõ vì sao có công tắc này, thay vì để người dùng đoán.
          'Từ ghép là chỗ dễ nhầm cách đọc nhất — 生 trong 学生 đọc せい, '
          'trong 生まれる đọc う.',
          style: TextStyle(fontSize: 12, color: c.inkFaint, height: 1.4),
        ),
        const SizedBox(height: 20),
        const QuizFieldLabel('SỐ CÂU'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final n in counts)
              QuizChip(label: '$n', on: n == count, onTap: () => onCount(n)),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '$available từ ra đề được trong phạm vi này.',
          style: TextStyle(fontSize: 12.5, color: c.inkFaint),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: available == 0 ? null : onStart,
          child: Text('Bắt đầu · ${available < count ? available : count} câu'),
        ),
      ],
    );
  }
}
