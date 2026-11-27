import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/grammar.dart';
import '../theme.dart';

/// Ngữ pháp của MỘT bài: từng mẫu, giải thích, và câu ví dụ.
///
/// Mỗi mẫu là một thẻ mở gấp được, mặc định ĐÓNG. Một bài có tới 8 mẫu, mỗi mẫu
/// một đoạn giải thích dài — mở hết ra thì phải cuộn qua vài màn mới thấy mẫu
/// thứ hai, và không ai nhìn ra bài này gồm những gì.
class GrammarLessonScreen extends StatelessWidget {
  const GrammarLessonScreen({
    super.key,
    required this.lesson,
    required this.title,
  });

  final int lesson;
  final String title;

  @override
  Widget build(BuildContext context) {
    final grammar = AppScope.of(context).grammar;
    final patterns = grammar.byLesson(lesson);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bài $lesson', style: const TextStyle(fontSize: 16)),
            if (title.isNotEmpty)
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: context.c.inkFaint),
              ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        itemCount: patterns.length,
        itemBuilder: (context, i) => GrammarPatternCard(
          pattern: patterns[i],
          examples: grammar.sentencesOf(patterns[i]),
          // Mẫu đầu mở sẵn: mở màn ra thấy ngay nội dung thật, không phải một
          // danh sách tiêu đề câm.
          initiallyOpen: i == 0,
        ),
      ),
    );
  }
}

/// Một mẫu ngữ pháp: tên mẫu, giải thích, và các câu ví dụ.
class GrammarPatternCard extends StatelessWidget {
  const GrammarPatternCard({
    super.key,
    required this.pattern,
    required this.examples,
    this.initiallyOpen = false,
  });

  final GrammarPattern pattern;
  final List<Sentence> examples;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: c.cardBox(radius: Radii.card),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Bỏ vạch kẻ mặc định của ExpansionTile — thẻ đã có viền riêng rồi.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyOpen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: c.ai,
          collapsedIconColor: c.inkFaint,
          title: Text(
            pattern.pattern,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.ink,
              height: 1.35,
            ),
          ),
          subtitle: examples.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${examples.length} ví dụ',
                    style: TextStyle(fontSize: 12, color: c.inkFaint),
                  ),
                ),
          children: [
            if (pattern.explain.isNotEmpty)
              Text(
                pattern.explain,
                style: TextStyle(fontSize: 14, height: 1.55, color: c.inkSoft),
              ),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 14),
              for (final s in examples) _Example(sentence: s),
            ],
          ],
        ),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({required this.sentence});
  final Sentence sentence;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sentence.jaKanji,
            style: TextStyle(fontSize: 15.5, height: 1.5, color: c.ink),
          ),
          // Chỉ hiện dòng kana khi nó THẬT SỰ khác dòng trên. Nguồn không ghi
          // furigana thì hai bản bằng nhau, in lại y nguyên chỉ tổ rối mắt.
          if (sentence.hasFurigana) ...[
            const SizedBox(height: 3),
            Text(
              sentence.jaKana,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: c.inkFaint),
            ),
          ],
          const SizedBox(height: 5),
          Text(
            sentence.vi,
            style: TextStyle(fontSize: 13.5, height: 1.45, color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}
