import 'package:flutter/material.dart';

import '../quiz/answer_tally.dart';
import '../theme.dart';

/// Thanh tỉ lệ bốn phần của một phiên.
///
/// Bốn phần cộng lại ĐÚNG BẰNG tổng. Thiếu `pendingCount` thì thanh chỉ vẽ phần
/// đã làm, nhìn như phiên 3 câu trong khi phiên có 50 — đúng lỗi đã có ở màn
/// tổng kết từ vựng. Dùng chung cho mọi loại phiên để không phải sửa hai lần.
class TallyBars extends StatelessWidget {
  const TallyBars({super.key, required this.tally});
  final AnswerTally tally;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final parts = [
      (tally.correctCount, c.matcha),
      (tally.wrongCount, c.shu),
      (tally.skippedCount, c.inkFaint),
      (tally.pendingCount, c.line),
    ].where((p) => p.$1 > 0);

    return Row(
      children: [
        for (final (value, color) in parts)
          Expanded(
            flex: value,
            child: Container(
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

/// Chú giải bốn số.
///
/// Wrap chứ không Row: số càng lớn chữ càng dài, phiên 120 câu ở cỡ chữ ×2 tràn
/// tới 276px. Xuống dòng còn đọc được, tràn thì mất hẳn.
class TallyLegend extends StatelessWidget {
  const TallyLegend({super.key, required this.tally, this.unit = 'từ'});

  final AnswerTally tally;

  /// Đơn vị trong nhãn — "từ" cho phiên từ vựng, "câu" cho phiên kanji.
  final String unit;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget entry(int n, String label, Color color) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$n ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: label,
              style: TextStyle(fontSize: 12.5, color: c.inkSoft),
            ),
          ],
        ),
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        entry(tally.correctCount, 'đúng', c.matcha),
        entry(tally.wrongCount, 'sai', c.shu),
        // "Bỏ qua" tách riêng khỏi "sai": đã xem rồi quyết định bỏ thì không
        // phải là làm hỏng.
        entry(tally.skippedCount, 'bỏ qua', c.inkFaint),
        // Và "chưa làm" tách riêng khỏi "bỏ qua": phiên kết thúc trước khi tới
        // lượt nó, thường vì thoát giữa chừng. Thoát không đi qua nút bỏ qua nên
        // không đếm riêng thì số $unit còn lại mất hút.
        entry(tally.pendingCount, 'chưa làm', c.inkFaint),
      ],
    );
  }
}
