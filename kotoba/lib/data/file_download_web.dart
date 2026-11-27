import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Cho trình duyệt tải [text] xuống thành file [name] (JSON, UTF-8).
void downloadTextFile(String name, String text) {
  final blob = web.Blob(
    [text.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  a.click();
  // Thu hồi chậm một nhịp: Safari huỷ tải nếu URL biến mất ngay sau click.
  Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
}
