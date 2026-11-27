import 'package:flutter/material.dart';

import '../quiz/quiz_session.dart';
import '../theme.dart';
import 'glyph_badge.dart';
import 'motion.dart';

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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(
            context,
            'Viết',
            mode == QuizMode.write,
            () => onChanged(QuizMode.write),
          ),
          _seg(
            context,
            'Đọc',
            mode == QuizMode.speak,
            () => onChanged(QuizMode.speak),
          ),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, bool on, VoidCallback onTap) {
    final c = context.c;
    return Pressable(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.quick),
          curve: Motion.ease,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? c.card : c.card.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(8),
            boxShadow: on ? c.raise : const [],
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
      ),
    );
  }
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
          child: EnterFadeSlide(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlyphBadge('学'),
                const SizedBox(height: 22),
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
      ),
    );
  }
}
