import 'package:flutter/material.dart';

/// Nhịp chuyển động dùng chung cho cả app.
///
/// Một chỗ duy nhất định thời lượng và đường cong: mỗi màn tự chọn con số
/// riêng thì app chuyển động "lệch nhịp", nhìn rẻ tiền dù từng chỗ đều mượt.
abstract final class Motion {
  /// Đổi trạng thái nhỏ: chip bật/tắt, màu nền, vạch chọn.
  static const quick = Duration(milliseconds: 180);

  /// Khối nội dung hiện ra: câu hỏi mới, thẻ chấm điểm.
  static const enter = Duration(milliseconds: 320);

  /// Thanh tiến độ trượt tới vị trí mới.
  static const progress = Duration(milliseconds: 450);

  static const ease = Curves.easeOutCubic;

  /// Người dùng bật "Giảm chuyển động" trong cài đặt máy thì mọi hiệu ứng
  /// trang trí phải tắt — với người say chuyển động đây không phải sở thích.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Thời lượng đã tính tới "Giảm chuyển động": tắt thì về 0, đổi tức thì.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}

/// Cho nội dung hiện ra bằng mờ dần + trượt nhẹ lên (+ phóng nhẹ nếu cần).
///
/// Chỉ chạy một lần lúc widget được dựng. Muốn chạy lại cho câu mới thì đổi
/// `key` ở chỗ gọi. Không dùng AnimatedSwitcher: nó giữ khối cũ song song với
/// khối mới trong lúc chuyển, mà khối cũ có ô nhập dùng chung controller.
class EnterFadeSlide extends StatelessWidget {
  const EnterFadeSlide({
    super.key,
    required this.child,
    this.offsetY = 14,
    this.fromScale = 1,
    this.duration = Motion.enter,
  });

  final Widget child;
  final double offsetY;
  final double fromScale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Motion.ease,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offsetY),
          child: Transform.scale(
            scale: fromScale + (1 - fromScale) * t,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Lún nhẹ khi ngón tay đặt xuống — phản hồi xúc giác bằng mắt, vì Safari iOS
/// không có API rung.
///
/// Dùng Listener chứ không phải GestureDetector: chỉ nghe con trỏ, không giành
/// cử chỉ với nút/ô bên trong, nên bọc ngoài cái gì cũng được.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.96});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
