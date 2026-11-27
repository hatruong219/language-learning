import 'package:flutter/material.dart';

import '../theme.dart';

/// Một chữ kanji đặt trong ô vuông bo tròn màu chàm nhạt — "hình minh hoạ"
/// của các màn trống.
///
/// Trước đây chữ đứng trần, màu viền ([Palette.line]) nên trông như bị mờ đi
/// vì lỗi. Đặt vào ô nền có chủ đích thì đọc ra là trang trí, không phải hỏng.
class GlyphBadge extends StatelessWidget {
  const GlyphBadge(this.glyph, {super.key});

  final String glyph;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.aiWash,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: c.ai.withValues(alpha: 0.12)),
      ),
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: 46,
          height: 1,
          fontWeight: FontWeight.w500,
          color: c.ai.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
