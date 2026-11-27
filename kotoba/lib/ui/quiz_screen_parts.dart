import 'package:flutter/material.dart';

import '../quiz/quiz_session.dart';
import '../theme.dart';

/// Thanh đổi chế độ Viết/Đọc và màn mời chọn bài. Tách khỏi `quiz_screen.dart`
/// để file đó chỉ còn phần điều phối phiên học.

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key, required this.mode, required this.onChanged});

  final QuizMode mode;
  final ValueChanged<QuizMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(
            c,
            'Viết',
            mode == QuizMode.write,
            () => onChanged(QuizMode.write),
          ),
          _seg(
            c,
            'Đọc',
            mode == QuizMode.speak,
            () => onChanged(QuizMode.speak),
          ),
        ],
      ),
    );
  }

  Widget _seg(Palette c, String label, bool on, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: on ? c.card : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on ? c.ink : c.inkSoft,
            ),
          ),
        ),
      );
}

class QuizIntro extends StatelessWidget {
  const QuizIntro({super.key, required this.onPick});

  final VoidCallback onPick;

  /// Số từ đang đánh dấu. Bằng 0 thì KHÔNG hiện nút ôn — nút bấm vào không có
  /// gì xảy ra còn khó hiểu hơn là không có nút.

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Phải cuộn được, không phải Center trần. Cỡ chữ hệ thống anh chỉnh trong
    // Cài đặt máy có thể phóng tới gấp đôi — lúc đó khối này cao hơn màn hình.
    // Bản gỡ lỗi kêu sọc vàng, còn bản phát hành thì lặng lẽ CẮT phần tràn:
    // nội dung căn giữa bị đẩy văng khỏi khung, để lại đúng một màn trắng.
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '学',
                style: TextStyle(fontSize: 52, height: 1, color: c.line),
              ),
              const SizedBox(height: 20),
              Text(
                'Chọn bài để bắt đầu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn một hoặc nhiều bài. Xem nghĩa tiếng Việt, '
                'nhập hoặc đọc từ tiếng Nhật.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: c.inkFaint,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(onPressed: onPick, child: const Text('Chọn bài')),
            ],
          ),
        ),
      ),
    );
  }
}
