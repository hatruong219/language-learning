import 'package:flutter/material.dart';

import '../quiz/translation_check.dart';
import '../theme.dart';

/// Bản đối chiếu câu đã gõ với đáp án, tô theo từng đoạn.
///
/// Đây là phần đáng giá nhất của mục luyện dịch. Chỉ báo "sai rồi" thì người
/// học không biết mình hỏng ở đâu — thiếu trợ từ, chia sai đuôi, hay lộn cả
/// trật tự đều hiện ra như nhau.
class DiffView extends StatelessWidget {
  const DiffView({super.key, required this.result});
  final TranslationResult result;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐỐI CHIẾU',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: c.inkFaint,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [for (final p in result.parts) _span(c, p)]),
            style: const TextStyle(fontSize: 17, height: 1.7),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Key(color: c.matcha, label: 'đúng'),
              _Key(color: c.shu, label: 'thiếu', underline: true),
              _Key(color: c.inkFaint, label: 'thừa', strike: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Thiếu thì GẠCH CHÂN, thừa thì GẠCH NGANG.
  ///
  /// Không chỉ dựa vào màu: đỏ với xám nhạt trên nền tối rất khó phân biệt, và
  /// khoảng 8% nam giới khó phân biệt đỏ–xanh. Kiểu gạch nói được cùng một điều
  /// mà không cần nhìn ra màu.
  TextSpan _span(Palette c, DiffPart p) => switch (p.kind) {
    DiffKind.same => TextSpan(
      text: p.text,
      style: TextStyle(color: c.matcha, fontWeight: FontWeight.w600),
    ),
    DiffKind.missing => TextSpan(
      text: p.text,
      style: TextStyle(
        color: c.shu,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationColor: c.shu,
        decorationThickness: 2,
      ),
    ),
    DiffKind.extra => TextSpan(
      text: p.text,
      style: TextStyle(
        color: c.inkFaint,
        decoration: TextDecoration.lineThrough,
        decorationColor: c.inkFaint,
      ),
    ),
  };
}

class _Key extends StatelessWidget {
  const _Key({
    required this.color,
    required this.label,
    this.underline = false,
    this.strike = false,
  });

  final Color color;
  final String label;
  final bool underline;
  final bool strike;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 11.5,
      color: color,
      fontWeight: FontWeight.w600,
      decoration: underline
          ? TextDecoration.underline
          : strike
          ? TextDecoration.lineThrough
          : null,
      decorationColor: color,
    ),
  );
}

/// Đáp án đầy đủ, hiện sau khi chấm.
class TranslationAnswer extends StatelessWidget {
  const TranslationAnswer({
    super.key,
    required this.kanji,
    required this.kana,
    required this.showKana,
  });

  final String kanji;
  final String kana;
  final bool showKana;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.matchaWash,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐÁP ÁN',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: c.matcha,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            kanji,
            style: TextStyle(fontSize: 17, height: 1.5, color: c.ink),
          ),
          if (showKana) ...[
            const SizedBox(height: 4),
            Text(
              kana,
              style: TextStyle(fontSize: 13, height: 1.4, color: c.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}
