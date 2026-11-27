import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'grammar_lesson_screen.dart';

/// Danh sách 50 bài ngữ pháp — cửa vào phần đọc.
///
/// Chỉ hiện bài NÀO CÓ mẫu ngữ pháp. Bày đủ 1..50 rồi để vài bài bấm vào trống
/// trơn thì người học tưởng app hỏng, trong khi sự thật là nguồn chưa có.
class GrammarLessonList extends StatelessWidget {
  const GrammarLessonList({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final grammar = scope.grammar;
    final titles = {
      for (final l in scope.vocabulary.lessons) l.number: l.title,
    };

    if (grammar.lessons.isEmpty) {
      return const _NoGrammar();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grammar.lessons.length,
      separatorBuilder: (_, _) => const _Divider(),
      itemBuilder: (context, i) {
        final n = grammar.lessons[i];
        return _LessonRow(
          number: n,
          title: titles[n] ?? '',
          patterns: grammar.byLesson(n).length,
          sentences: grammar.sentencesInLesson(n).length,
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 62),
    child: Divider(height: 1, thickness: 1, color: context.c.line),
  );
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.number,
    required this.title,
    required this.patterns,
    required this.sentences,
  });

  final int number;
  final String title;
  final int patterns;
  final int sentences;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GrammarLessonScreen(lesson: number, title: title),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Số bài trong ô vuông: quét mắt tìm bài nhanh hơn đọc chữ "Bài".
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.aiWash,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.ai,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Bài $number' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$patterns mẫu · $sentences câu ví dụ',
                    style: TextStyle(fontSize: 12.5, color: c.inkFaint),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: c.inkFaint),
          ],
        ),
      ),
    );
  }
}

/// Không có dữ liệu ngữ pháp — chỉ xảy ra khi bản đóng gói bị thiếu.
class _NoGrammar extends StatelessWidget {
  const _NoGrammar();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 40, color: c.inkFaint),
            const SizedBox(height: 12),
            Text(
              'Chưa có dữ liệu ngữ pháp',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c.inkSoft,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vào Cài đặt → Tải tất cả để lấy về.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}
