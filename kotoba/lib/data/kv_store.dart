import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb_shim.dart';

/// Kho khoá–giá trị chung cho tiến độ, cài đặt và bản đồng bộ.
///
/// Một kho duy nhất thay vì mỗi nơi tự lo một file: thứ cần là "ghi vài khoá
/// cùng lúc, hoặc tất cả hoặc không gì cả", và IndexedDB cho đúng thứ đó bằng
/// một transaction.
abstract class KvStore {
  /// Dữ liệu có thực sự sống sót qua lần đóng app không. False khi kho chỉ nằm
  /// trong bộ nhớ (trình duyệt chặn IndexedDB) hoặc đã bị đánh dấu không an
  /// toàn để ghi — giao diện nhìn cờ này để báo người dùng xuất sao lưu.
  ValueListenable<bool> get persistent;

  /// Đánh dấu kho không còn đáng tin để lưu (đọc lỗi tạm thời đầu phiên).
  void markUnsafe();

  Future<String?> get(String key);

  /// Ghi NGUYÊN TỬ mọi khoá trong một transaction: lỗi thì không khoá nào đổi.
  Future<void> putAll(Map<String, String> entries);

  Future<void> delete(String key);

  /// Chuyển giá trị sang khoá mới (đè khoá đích). Khoá nguồn không có thì thôi.
  Future<void> rename(String from, String to);
}

/// [KvStore] trên IndexedDB: DB `kotoba`, object store `kv`.
///
/// Nhận [IdbFactory] từ ngoài: trình duyệt dùng IndexedDB thật, test trên VM
/// dùng bản bộ nhớ của idb_shim — cùng một đường mã, không phải giả lập tự chế.
class IdbKvStore implements KvStore {
  IdbKvStore._(this._db, bool persistent)
    : _persistent = ValueNotifier(persistent);

  static const dbName = 'kotoba';
  static const storeName = 'kv';

  final Database _db;
  final ValueNotifier<bool> _persistent;

  @override
  ValueListenable<bool> get persistent => _persistent;

  @override
  void markUnsafe() => _persistent.value = false;

  /// [persistent] = false cho kho dựng trên bộ nhớ (không sống qua đóng app).
  static Future<IdbKvStore> open(
    IdbFactory factory, {
    bool persistent = true,
  }) async {
    final db = await factory.open(
      dbName,
      version: 1,
      onUpgradeNeeded: (e) => e.database.createObjectStore(storeName),
    );
    return IdbKvStore._(db, persistent);
  }

  /// Chạy [body] trong MỘT transaction ghi rồi chờ nó commit xong.
  ///
  /// [body] chỉ được await các lời gọi idb: await thứ khác thì transaction tự
  /// commit giữa chừng và lệnh sau ném TransactionInactiveError.
  Future<T> _write<T>(Future<T> Function(ObjectStore store) body) async {
    final txn = _db.transaction(storeName, idbModeReadWrite);
    try {
      final result = await body(txn.objectStore(storeName));
      await txn.completed;
      return result;
    } on Object {
      // Hủy transaction để các lệnh put đã xếp hàng không bao giờ commit —
      // không thì lỗi giữa chừng để lại một nửa bản ghi.
      try {
        txn.abort();
        // Abort làm `completed` báo lỗi: nuốt, không thì thành lỗi vô chủ.
        await txn.completed;
      } on Object {
        /* đã commit/abort rồi thì thôi */
      }
      rethrow;
    }
  }

  @override
  Future<String?> get(String key) async {
    final txn = _db.transaction(storeName, idbModeReadOnly);
    final value = await txn.objectStore(storeName).getObject(key);
    await txn.completed;
    return value as String?;
  }

  @override
  Future<void> putAll(Map<String, String> entries) => _write((s) async {
    for (final e in entries.entries) {
      await s.put(e.value, e.key);
    }
  });

  @override
  Future<void> delete(String key) => _write((s) => s.delete(key));

  @override
  Future<void> rename(String from, String to) => _write((s) async {
    final value = await s.getObject(from);
    if (value == null) return;
    await s.put(value, to);
    await s.delete(from);
  });
}
