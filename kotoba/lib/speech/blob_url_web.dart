import 'package:web/web.dart' as web;

/// Giải phóng bộ nhớ của blob WAV mà `record` tạo ra. Không thu hồi thì mỗi
/// lần nói giữ lại vài trăm KB tới khi đóng tab.
void revokeBlobUrl(String url) => web.URL.revokeObjectURL(url);
