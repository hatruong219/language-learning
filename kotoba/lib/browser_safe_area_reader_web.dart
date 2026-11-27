import 'package:flutter/painting.dart';
import 'package:web/web.dart' as web;

/// Đọc `env(safe-area-inset-*)` qua thẻ dò `#kotoba-safe-area` trong
/// `web/index.html` (thẻ đó lấy padding = inset). Không thấy thẻ thì trả 0.
EdgeInsets readBrowserSafeArea() {
  final probe = web.document.getElementById('kotoba-safe-area');
  if (probe == null) return EdgeInsets.zero;
  final s = web.window.getComputedStyle(probe);
  double px(String v) => double.tryParse(v.replaceAll('px', '').trim()) ?? 0;
  return EdgeInsets.fromLTRB(
    px(s.paddingLeft),
    px(s.paddingTop),
    px(s.paddingRight),
    px(s.paddingBottom),
  );
}
