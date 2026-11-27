import 'dart:js_interop';

import 'package:idb_shim/idb_browser.dart';
import 'package:web/web.dart' as web;

IdbFactory platformIdbFactory() => idbFactoryBrowser;

/// Xin trình duyệt đừng tự dọn dữ liệu của site (best-effort: Chrome Android
/// có thể cho, Safari thì chỉ chắc khi đã thêm vào màn hình chính).
Future<void> requestPersistentStorage() async {
  try {
    await web.window.navigator.storage.persist().toDart;
  } on Object {
    /* không hỗ trợ thì thôi — chỉ là xin thêm bảo đảm */
  }
}
