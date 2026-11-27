import 'package:flutter/material.dart';

import '../theme.dart';

/// Các mảnh nhỏ dựng nên một dòng từ vựng. Tách khỏi `word_row.dart` để file đó
/// chỉ còn phần logic ẩn/hiện — thứ đáng đọc kỹ nhất ở đấy.

/// Ô che khi từ đang ẩn: nền chìm có gạch mờ, không phải ô trống.
/// Nhìn là biết "có cái gì đó ở đây, chạm đi", chứ không tưởng dữ liệu lỗi.
class MaskBar extends StatelessWidget {
  const MaskBar({super.key, required this.c});
  final Palette c;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: c.sunken,
      borderRadius: BorderRadius.circular(6),
    ),
    alignment: Alignment.center,
    child: Container(
      width: 42,
      height: 3,
      decoration: BoxDecoration(
        color: c.line,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color color, background;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Tô vàng đúng đoạn khớp trong kết quả tìm kiếm.
///
/// Ba kết quả cùng chứa chữ "học" nhưng ở vị trí khác nhau — tô lên thì mắt bắt
/// ngay, không phải dò từng dòng.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.style,
    required this.hitStyle,
    this.highlight,
    this.maxLines,
  });

  final String text;
  final String? highlight;
  final TextStyle style, hitStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final needle = highlight?.trim().toLowerCase();
    if (needle == null || needle.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final hay = text.toLowerCase();
    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      final at = hay.indexOf(needle, i);
      if (at < 0) {
        spans.add(TextSpan(text: text.substring(i), style: style));
        break;
      }
      if (at > i) {
        spans.add(TextSpan(text: text.substring(i, at), style: style));
      }
      spans.add(
        TextSpan(text: text.substring(at, at + needle.length), style: hitStyle),
      );
      i = at + needle.length;
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
