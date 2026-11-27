import 'package:flutter/widgets.dart';

/// Gọi [flush] mọi lần app có thể không bao giờ quay lại.
///
/// Chỉ nghe `onHide` thì chưa đủ: Safari iOS đẩy tab vào nền, hay bị hệ thống
/// dọn, thường chỉ kịp báo inactive/pause. Gọi dư không sao — flush rỗng thì
/// chẳng làm gì.
AppLifecycleListener flushOnLeave(VoidCallback flush) => AppLifecycleListener(
  onInactive: flush,
  onPause: flush,
  onHide: flush,
  onDetach: flush,
);
