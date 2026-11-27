import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion.dart';

/// Dấu tích / dấu chéo trong vòng tròn, "bật" ra khi thẻ chấm điểm hiện.
///
/// Màu đã nói đúng/sai rồi, nhưng người mù màu đỏ-lục thì không phân biệt
/// được — hình dấu là kênh thứ hai, không phụ thuộc màu.
class VerdictMark extends StatelessWidget {
  const VerdictMark({super.key, required this.ok});
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tone = ok ? c.matcha : c.shu;
    final mark = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tone,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tone.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        ok ? Icons.check_rounded : Icons.close_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
    if (Motion.reduced(context)) return mark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      child: mark,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
    );
  }
}
