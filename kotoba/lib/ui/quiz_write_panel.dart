import 'package:flutter/material.dart';

import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'quiz_prompt.dart';

/// Chế độ gõ. App KHÔNG tự đổi chữ — bàn phím tiếng Nhật của iOS lo việc đó,
/// ô nhập chỉ nhận chuỗi. Bớt được một đống code và một đống chỗ để sai.

class WritePanel extends StatelessWidget {
  const WritePanel({
    super.key,
    required this.item,
    required this.controller,
    required this.onSubmit,
    required this.onSkip,
  });

  final QuizItem item;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuizPrompt(label: 'NGHĨA', text: item.word.meaning),
        TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmit,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: c.ink,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: c.paper,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: c.ai, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: c.ai, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => onSubmit(controller.text),
          child: const Text('Trả lời'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(foregroundColor: c.inkFaint),
          child: const Text('Bỏ qua từ này'),
        ),
      ],
    );
  }
}
