import 'package:flutter/material.dart';

import '../data/sync_service.dart';
import '../theme.dart';
import 'settings_widgets.dart';

/// Hàng "Tải tất cả" trong Cài đặt — đường duy nhất để lấy dữ liệu mới.
///
/// MỘT nút cho cả từ vựng, chữ Hán, mảnh cấu tạo và ngữ pháp. Đặt nút riêng
/// trong từng tab thì đứng đâu cũng thấy một nút đồng bộ khác nhau, và người
/// dùng không biết bấm cái nào là đủ.
///
/// App KHÔNG tự đồng bộ. Dữ liệu giáo trình đổi rất ít, mà tự gọi mạng lúc mở
/// app thì lần nào mất mạng cũng thành một màn chờ vô nghĩa.
class SyncRow extends StatefulWidget {
  const SyncRow({super.key, this.service});

  /// Bỏ trống thì tự dựng. Truyền vào để test không gọi mạng thật.
  final SyncService? service;

  @override
  State<SyncRow> createState() => _SyncRowState();
}

class _SyncRowState extends State<SyncRow> {
  late final SyncService _svc = widget.service ?? SyncService();

  bool _busy = false;
  String? _error;
  SyncResult? _done;

  @override
  void dispose() {
    // Chỉ đóng client mình tự dựng. Client do người gọi truyền vào là của họ,
    // đóng hộ thì lần dùng sau của họ nổ.
    if (widget.service == null) _svc.close();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _error = null;
      _done = null;
    });
    try {
      final r = await _svc.downloadAll();
      if (!mounted) return;
      setState(() => _done = r);
    } on SyncException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    if (!_svc.configured) {
      // Nói rõ vì sao không bấm được, thay vì để nút bấm rồi báo lỗi mạng mù mờ.
      return SettingsRow(
        label: 'Tải tất cả',
        sublabel: 'Bản app này chưa cấu hình địa chỉ máy chủ',
        accent: c.inkFaint,
      );
    }

    if (_busy) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(strokeWidth: 2, color: c.ai),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đang tải…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: c.ink,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SettingsRow(
      label: 'Tải tất cả',
      sublabel: _error ?? _done?.summary ?? 'Từ vựng, chữ Hán, và ngữ pháp',
      accent: _error != null ? c.shu : null,
      value: _error != null ? 'Thử lại' : null,
      onTap: _run,
    );
  }
}

/// Hàng cho biết đang dùng bản đã tải hay bản đóng gói.
///
/// Cần nói ra vì hai bản có thể lệch nhau: bản đóng gói cố định theo lần build,
/// bản tải về thì theo database. Không nói thì lúc thấy số liệu khác nhau người
/// dùng không biết mình đang xem cái nào.
class DataSourceRow extends StatelessWidget {
  const DataSourceRow({super.key, required this.hasDownload});
  final bool hasDownload;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Nguồn dữ liệu',
    value: hasDownload ? 'Đã tải về' : 'Bản đóng gói',
  );
}
