import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/study_stats.dart';
import '../theme.dart';
import 'stats_parts.dart';

/// Màn Thống kê: từ nào đã học bao nhiêu lượt, sai mấy lượt.
///
/// Toàn bộ số liệu nằm trong máy, không gửi đi đâu. Tính lại từ `progress.json`
/// mỗi lần mở màn — 2090 từ nên rẻ, mà đổi lại không phải giữ thêm một bản đếm
/// song song có thể lệch với sự thật.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum StatsSort {
  /// Sai nhiều nhất lên đầu. Đây là thứ tự mặc định vì nó trả lời đúng câu hỏi
  /// người học mang tới màn này: "mình đang yếu chỗ nào".
  concern,

  /// Được kiểm nhiều nhất lên đầu.
  attempts,

  /// Theo thứ tự bài, để soi một bài cụ thể.
  lesson,
}

class _StatsScreenState extends State<StatsScreen> {
  StatsSort _sort = StatsSort.concern;

  /// Chỉ hiện từ còn sai. Bật lên khi danh sách dài mà phần lớn đã đúng hết.
  bool _onlyWrong = false;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = context.c;

    return Scaffold(
      appBar: AppBar(titleSpacing: 20, title: const Text('Thống kê')),
      // Nghe tiến độ: gắn sao ngay trên màn này thì dòng đó phải đổi theo.
      body: AnimatedBuilder(
        animation: scope.progress,
        builder: (context, _) {
          final stats = StudyStats.of(scope.progress, scope.vocabulary);
          if (stats.isEmpty) return const StatsEmpty();

          final rows = _rows(stats);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            // +2: một thẻ tổng quan, một hàng điều khiển.
            itemCount: rows.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) return StatsSummary(stats: stats);
              if (i == 1) {
                return StatsControls(
                  sort: _sort,
                  onlyWrong: _onlyWrong,
                  shown: rows.length,
                  onSort: (v) => setState(() => _sort = v),
                  onOnlyWrong: (v) => setState(() => _onlyWrong = v),
                );
              }
              return StatRow(
                stat: rows[i - 2],
                onToggleStar: () =>
                    scope.progress.toggleStar(rows[i - 2].word.id),
              );
            },
          );
        },
      ),
      backgroundColor: c.paper,
    );
  }

  List<WordStat> _rows(StudyStats stats) {
    final base = _onlyWrong ? stats.needWork : stats.words;
    final out = [...base];
    switch (_sort) {
      case StatsSort.concern:
        // Đã sắp sẵn theo thứ tự này lúc dựng, không sắp lại.
        break;
      case StatsSort.attempts:
        out.sort((a, b) => b.attempts.compareTo(a.attempts));
      case StatsSort.lesson:
        out.sort((a, b) {
          final byLesson = a.word.lesson.compareTo(b.word.lesson);
          return byLesson != 0 ? byLesson : b.wrong.compareTo(a.wrong);
        });
    }
    return out;
  }
}
