import 'package:flutter/material.dart';

import '../theme.dart';

/// Thanh tiến độ trên đầu một phiên làm bài, kèm nút dừng.
///
/// Dùng chung cho mọi phiên (từ vựng, kanji, ngữ pháp): ba bản sao của cùng một
/// thanh thì sớm muộn lệch nhau, mà lệch ở đây thì người học đọc ra hai con số
/// khác nhau cho cùng một việc.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    super.key,
    required this.done,
    required this.total,
    required this.onQuit,
  });

  final int done;
  final int total;

  /// Thoát giữa chừng phải được, và điểm chốt tại đó. Không cho thoát thì người
  /// dùng buộc phải làm hết mới ra được.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$done / $total',
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
                    value: total == 0 ? 0 : done / total,
                    minHeight: 4,
                    backgroundColor: c.sunken,
                    valueColor: AlwaysStoppedAnimation(c.ai),
                  ),
                ),
              ],
            ),
          ),
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

/// Ô chọn nhỏ dạng viên thuốc, bật/tắt.
///
/// Dùng ở mọi màn chuẩn bị phiên — chọn cấp độ, số câu, dạng bài.
class QuizChip extends StatelessWidget {
  const QuizChip({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? c.ai : c.sunken,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: on ? Colors.white : c.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// Nhãn nhỏ in hoa phía trên một nhóm lựa chọn.
class QuizFieldLabel extends StatelessWidget {
  const QuizFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 10.5,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w700,
      color: context.c.inkFaint,
    ),
  );
}
