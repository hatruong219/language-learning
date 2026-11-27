import 'package:flutter/material.dart';

import '../theme.dart';

/// Nhãn nhỏ + nghĩa to. Dùng chung cho cả chế độ viết lẫn chế độ đọc.
class QuizPrompt extends StatelessWidget {
  const QuizPrompt({super.key, required this.label, required this.text});

  final String label, text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: c.inkFaint,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: c.ink,
            ),
          ),
        ],
      ),
    );
  }
}
