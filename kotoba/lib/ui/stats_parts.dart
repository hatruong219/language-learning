import 'package:flutter/material.dart';

import '../data/study_stats.dart';
import '../theme.dart';
import 'stats_screen.dart' show StatsSort;

/// Thẻ tổng quan trên đầu màn Thống kê.
class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key, required this.stats});
  final StudyStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pct = (stats.accuracy * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: c.cardBox(radius: Radii.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: pct >= 80
                      ? c.matcha
                      : pct >= 60
                      ? c.kincha
                      : c.shu,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'đúng trên ${stats.totalAttempts} lượt',
                  style: TextStyle(fontSize: 13.5, color: c.inkSoft),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _Cell(label: 'Từ đã kiểm', value: '${stats.testedCount}'),
              _Cell(
                label: 'Còn sai',
                value: '${stats.needWork.length}',
                color: stats.needWork.isEmpty ? null : c.shu,
              ),
              _Cell(label: 'Chưa sai lần nào', value: '${stats.cleanCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, this.color});
  final String label, value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color ?? c.ink,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11.5, color: c.inkFaint)),
      ],
    );
  }
}

/// Hàng chọn cách sắp xếp và bộ lọc.
class StatsControls extends StatelessWidget {
  const StatsControls({
    super.key,
    required this.sort,
    required this.onlyWrong,
    required this.shown,
    required this.onSort,
    required this.onOnlyWrong,
  });

  final StatsSort sort;
  final bool onlyWrong;
  final int shown;
  final ValueChanged<StatsSort> onSort;
  final ValueChanged<bool> onOnlyWrong;

  static const _labels = {
    StatsSort.concern: 'Sai nhiều nhất',
    StatsSort.attempts: 'Kiểm nhiều nhất',
    StatsSort.lesson: 'Theo bài',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cuộn ngang: ba nhãn này ở cỡ chữ ×2.0 trên máy nhỏ thì tràn, mà bản
          // phát hành cắt phần tràn âm thầm — mất chữ chứ không báo lỗi.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final e in _labels.entries) ...[
                  _Pill(
                    label: e.value,
                    on: sort == e.key,
                    onTap: () => onSort(e.key),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$shown từ',
            style: TextStyle(fontSize: 12.5, color: c.inkFaint),
          ),
          // Nhãn PHẢI co và xuống dòng được.
          //
          // Trước đây đặt nhãn và số đếm chung một hàng với công tắc. Công tắc
          // rộng cố định (~60px) không theo cỡ chữ, nên ở chữ ×2.0 trên iPhone
          // SE nhãn đẩy nó tràn 73px ra ngoài — mà bản phát hành cắt phần tràn
          // âm thầm, người dùng chỉ thấy mất nửa cái công tắc.
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chỉ hiện từ còn sai',
                  style: TextStyle(fontSize: 12.5, color: c.inkSoft),
                ),
              ),
              const SizedBox(width: 6),
              Switch.adaptive(value: onlyWrong, onChanged: onOnlyWrong),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on ? c.ai : c.sunken,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: on ? c.onAi : c.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// Một dòng thống kê của một từ.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stat, required this.onToggleStar});

  final WordStat stat;
  final VoidCallback onToggleStar;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final w = stat.word;
    final pct = (stat.accuracy * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(13, 11, 6, 11),
      decoration: c.cardBox(radius: Radii.row),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.kanji?.isNotEmpty == true
                      ? '${w.kanji}（${w.word}）'
                      : w.word,
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
                  w.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: c.inkFaint),
                ),
                const SizedBox(height: 5),
                // Nói cả LƯỢT lẫn SAI. Chỉ nói tỉ lệ thì sai 1/1 lượt trông
                // như thảm hoạ, mà thật ra mới gặp đúng một lần.
                Wrap(
                  spacing: 10,
                  runSpacing: 3,
                  children: [
                    _Tag(text: 'Bài ${w.lesson}', color: c.inkFaint),
                    _Tag(text: '${stat.attempts} lượt', color: c.inkSoft),
                    if (stat.wrong > 0)
                      _Tag(text: 'sai ${stat.wrong}', color: c.shu, bold: true)
                    else
                      _Tag(text: 'chưa sai', color: c.matcha),
                    _Tag(
                      text: '$pct%',
                      color: pct >= 80
                          ? c.matcha
                          : pct >= 60
                          ? c.kincha
                          : c.shu,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleStar,
            tooltip: stat.starred ? 'Bỏ đánh dấu' : 'Đánh dấu cần học lại',
            icon: Icon(
              stat.starred ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 21,
              color: stat.starred ? c.kincha : c.inkFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color, this.bold = false});
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    ),
  );
}

/// Chưa kiểm tra từ nào.
class StatsEmpty extends StatelessWidget {
  const StatsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined, size: 40, color: c.inkFaint),
            const SizedBox(height: 12),
            Text(
              'Chưa có số liệu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c.inkSoft,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Làm một phiên ở tab Luyện tập hoặc Kanji, số liệu sẽ hiện ở đây.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.45, color: c.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}
