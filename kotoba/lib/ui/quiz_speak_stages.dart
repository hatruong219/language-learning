import 'package:flutter/material.dart';

import '../theme.dart';

/// Các trạng thái của chế độ đọc: đang nghe, chờ nhận diện, xem lại chữ, báo lỗi.
/// Tách khỏi `quiz_speak_panel.dart` để file đó chỉ còn phần điều phối mic.

class ListeningStage extends StatelessWidget {
  const ListeningStage({
    super.key,
    required this.levels,
    required this.onStop,
    this.partialText = '',
  });

  /// Mức âm thanh thô từ bộ ghi âm, đơn vị dBFS — LUÔN là số âm.
  /// Im lặng khoảng -50 dB, nói to khoảng -10 dB.
  final List<double> levels;

  /// Chữ máy đang nghe ra, cập nhật liên tục trong lúc anh nói.
  final String partialText;

  final VoidCallback onStop;

  /// Đổi decibel thành 0–1 để vẽ.
  ///
  /// Bản trước lấy `abs()` của decibel — ngược nghĩa hoàn toàn: im lặng (-50)
  /// ra số lớn hơn nói to (-10), rồi cả hai đều vượt trần nên mọi cột dính
  /// đỉnh và sóng phẳng lì. Đây là phép quy đổi đúng.
  static double _norm(double db) =>
      ((db + _floorDb) / _floorDb).clamp(0.0, 1.0);
  static const double _floorDb = 50;

  bool get _hearingSomething => levels.isNotEmpty && _norm(levels.last) > 0.12;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final active = _hearingSomething;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: active ? 104 : 92,
          height: active ? 104 : 92,
          decoration: BoxDecoration(
            color: active ? c.shu.withValues(alpha: 0.18) : c.shuWash,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mic_rounded, size: 34, color: c.shu),
        ),
        const SizedBox(height: 14),
        // Sóng nhảy theo tiếng thật. Đây là cách duy nhất biết mic có ăn hay
        // không khi app đã nằm trên máy thật.
        SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final l in (levels.isEmpty ? const [-60.0] : levels))
                AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  width: 4,
                  height: 4 + _norm(l) * 30,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c.shu.withValues(alpha: 0.35 + _norm(l) * 0.65),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Hiện chữ ngay trong lúc nói. Không có phần này thì nhìn vào chỉ thấy
        // một vòng tròn, không biết máy có hiểu mình nói gì không.
        if (partialText.isNotEmpty)
          Text(
            partialText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: c.ink,
            ),
          )
        else
          Text(
            active ? 'Đang nghe…' : 'Đọc to từ này',
            style: TextStyle(fontSize: 13.5, color: c.inkSoft),
          ),
        const SizedBox(height: 6),
        Text(
          'Sẽ tự dừng khi ngừng nói',
          style: TextStyle(fontSize: 11.5, color: c.inkFaint),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onStop,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: BorderSide(color: c.line),
            foregroundColor: c.inkSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Nút này để dùng khi xung quanh ồn, tiếng ồn giữ cho phiên không tự
          // tắt. Bình thường không cần bấm.
          child: const Text('Dừng'),
        ),
      ],
    );
  }
}

/// Lần ghi đầu của phiên trang: chờ một cú chạm để trình duyệt cho dùng mic.
class TapToSpeakStage extends StatelessWidget {
  const TapToSpeakStage({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'Chạm để đọc',
          child: InkWell(
            key: const Key('tap-to-speak'),
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: c.shuWash, shape: BoxShape.circle),
              child: Icon(Icons.mic_rounded, size: 34, color: c.shu),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Chạm để đọc',
          style: TextStyle(fontSize: 13.5, color: c.inkSoft),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Đã ngừng ghi, đang chờ máy chủ trả chữ (thường dưới 2 giây).
class RecognizingStage extends StatelessWidget {
  const RecognizingStage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        const SizedBox(height: 22),
        SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(strokeWidth: 3, color: c.shu),
        ),
        const SizedBox(height: 16),
        Text(
          'Đang nhận diện…',
          style: TextStyle(fontSize: 13.5, color: c.inkSoft),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class ReviewStage extends StatelessWidget {
  const ReviewStage({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: c.ink),
      decoration: InputDecoration(
        hintText: 'Không nhận được âm thanh',
        hintStyle: TextStyle(fontSize: 17, color: c.inkFaint),
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
    );
  }
}

class ErrorNote extends StatelessWidget {
  const ErrorNote({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.shuWash,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}
