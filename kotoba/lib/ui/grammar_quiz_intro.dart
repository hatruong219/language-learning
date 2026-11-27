import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../quiz/grammar_quiz.dart';
import '../theme.dart';
import 'quiz_progress_bar.dart';

/// Màn chuẩn bị phiên bài tập ngữ pháp: chọn bài, dạng bài, số câu.
class GrammarQuizIntro extends StatelessWidget {
  const GrammarQuizIntro({
    super.key,
    required this.lessons,
    required this.count,
    required this.kinds,
    required this.onPick,
    required this.onCount,
    required this.onKinds,
    required this.onStart,
  });

  final Set<int> lessons;
  final int count;
  final Set<GrammarQuizKind> kinds;
  final VoidCallback onPick;
  final ValueChanged<int> onCount;
  final ValueChanged<Set<GrammarQuizKind>> onKinds;
  final VoidCallback onStart;

  static const counts = [5, 10, 20, 40];

  /// Số câu dựng được với lựa chọn hiện tại.
  ///
  /// Tính thật bằng cách dựng thử, không ước lượng: bộ lọc câu sạch và luật
  /// khoét trợ từ loại đi khá nhiều, nên "bài 16" nhìn thì có 24 câu mà ra đề
  /// chỉ được 3. Nói trước còn hơn để người học bấm Bắt đầu rồi mới thấy hụt.
  int _available(BuildContext context) => GrammarQuizBuilder(
    AppScope.of(context).grammar,
    seed: 0,
  ).build(count: 999, lessons: lessons, kinds: kinds).length;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final available = _available(context);
    final enough = available > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        Text(
          'Bài tập ngữ pháp',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Đề dựng từ chính câu ví dụ của giáo trình. Điền trợ từ là dạng phần '
          '文法 hỏi nhiều nhất, và cũng là chỗ người Việt sai nhiều nhất vì '
          'tiếng Việt không có trợ từ tương ứng.',
          style: TextStyle(fontSize: 13, color: c.inkSoft, height: 1.45),
        ),
        const SizedBox(height: 22),
        const QuizFieldLabel('PHẠM VI'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(
            lessons.isEmpty ? 'Tất cả các bài' : _range(lessons),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: BorderSide(color: c.line),
            foregroundColor: c.ink,
          ),
        ),
        const SizedBox(height: 20),
        const QuizFieldLabel('DẠNG BÀI'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _kindChip(GrammarQuizKind.particle, 'Điền trợ từ'),
            _kindChip(GrammarQuizKind.meaning, 'Chọn nghĩa'),
          ],
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
        const SizedBox(height: 20),
        _Availability(available: available, wanted: count),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: enough ? onStart : null,
          child: Text(
            enough
                ? 'Bắt đầu · ${available < count ? available : count} câu'
                : 'Chưa dựng được câu nào',
          ),
        ),
      ],
    );
  }

  Widget _kindChip(GrammarQuizKind kind, String label) => QuizChip(
    label: label,
    on: kinds.contains(kind),
    // Bỏ chọn cái cuối cùng thì không còn dạng nào để ra đề. Giữ lại ít nhất
    // một, thay vì cho tắt hết rồi báo lỗi.
    onTap: () {
      final next = {...kinds};
      if (!next.remove(kind)) next.add(kind);
      if (next.isNotEmpty) onKinds(next);
    },
  );

  static String _range(Set<int> lessons) {
    final sorted = lessons.toList()..sort();
    if (sorted.length == 1) return 'Bài ${sorted.first}';
    return '${sorted.length} bài · ${sorted.first}–${sorted.last}';
  }
}

/// Nói rõ còn bao nhiêu câu ra đề được — và vì sao ít.
class _Availability extends StatelessWidget {
  const _Availability({required this.available, required this.wanted});
  final int available;
  final int wanted;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (available >= wanted) {
      return Text(
        '$available câu ra đề được trong phạm vi này.',
        style: TextStyle(fontSize: 12.5, color: c.inkFaint),
      );
    }
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.kinchaWash,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            available == 0
                ? 'Phạm vi này chưa dựng được câu nào'
                : 'Chỉ dựng được $available câu',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: c.kincha,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Câu ví dụ còn lẫn số thứ tự, nhãn hội thoại và chú thích của giáo '
            'trình; những câu đó bỏ ra vì khoét chỗ trống vào là đề hỏng. Chọn '
            'thêm bài hoặc bật thêm dạng bài để có nhiều câu hơn.',
            style: TextStyle(fontSize: 12.5, color: c.inkSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}
