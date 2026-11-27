import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'browser_safe_area_reader.dart';

/// Bù vùng an toàn (thanh Home, tai thỏ) mà Flutter web không tự báo.
///
/// Trên iPhone, app mở từ màn hình chính chiếm cả mép dưới màn hình
/// (`viewport-fit=cover`), nhưng Flutter web luôn đặt `MediaQuery.padding`
/// = 0, nên thanh tab nằm đè lên thanh vuốt Home. Widget này đọc
/// `env(safe-area-inset-*)` từ trình duyệt và đưa vào `MediaQuery` để mọi
/// `SafeArea`/`BottomNavigationBar` bên dưới tự chừa chỗ.
///
/// Lấy giá trị lớn hơn ở mỗi cạnh, nên khi Flutter tự báo được inset thì
/// cũng không bị cộng hai lần.
class BrowserSafeArea extends StatefulWidget {
  const BrowserSafeArea({
    super.key,
    required this.child,
    this.read = readBrowserSafeArea,
  });

  final Widget child;

  /// Đọc inset hiện tại của trình duyệt. Tách ra để test được trên VM.
  final EdgeInsets Function() read;

  @override
  State<BrowserSafeArea> createState() => _BrowserSafeAreaState();
}

class _BrowserSafeAreaState extends State<BrowserSafeArea>
    with WidgetsBindingObserver {
  late EdgeInsets _insets = widget.read();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Xoay máy / đổi cỡ cửa sổ thì inset đổi theo.
  @override
  void didChangeMetrics() {
    final next = widget.read();
    if (next != _insets) setState(() => _insets = next);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: _max(mq.padding, _insets),
        viewPadding: _max(mq.viewPadding, _insets),
      ),
      child: widget.child,
    );
  }

  static EdgeInsets _max(EdgeInsets a, EdgeInsets b) => EdgeInsets.fromLTRB(
    math.max(a.left, b.left),
    math.max(a.top, b.top),
    math.max(a.right, b.right),
    math.max(a.bottom, b.bottom),
  );
}
