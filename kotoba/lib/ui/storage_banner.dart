import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Dòng cảnh báo cố định phía trên app khi tiến độ không được lưu bền.
///
/// Kho rơi về bộ nhớ (trình duyệt chặn IndexedDB) hoặc bị đánh dấu không an
/// toàn thì tiến độ mất lúc đóng app. Im lặng ở đây nghĩa là học cả tháng rồi
/// mất sạch, nên báo ngay từ đầu và giữ nguyên cho tới khi hết lỗi.
class StorageBanner extends StatelessWidget {
  const StorageBanner({
    super.key,
    required this.persistent,
    required this.child,
  });

  /// Cờ từ `ProgressStore.persistent`.
  final ValueListenable<bool> persistent;
  final Widget child;

  static const message =
      'Trình duyệt đang chặn lưu dữ liệu — tiến độ sẽ mất khi đóng app. '
      'Hãy xuất sao lưu.';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: persistent,
      child: child,
      builder: (context, ok, child) {
        if (ok) return child!;
        final c = context.c;
        return Column(
          children: [
            Material(
              color: c.shuWash,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: c.shu),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          key: const Key('storage-banner'),
                          style: TextStyle(fontSize: 12.5, color: c.shu),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Banner đã ăn phần tai thỏ phía trên, các tab bên dưới đừng chừa lần nữa.
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child!,
              ),
            ),
          ],
        );
      },
    );
  }
}
