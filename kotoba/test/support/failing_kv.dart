import 'package:flutter/foundation.dart';
import 'package:mnn_flashcard/data/kv_store.dart';

/// Kho bọc kho thật nhưng có thể làm cho đọc/đổi khoá ném lỗi — mô phỏng lỗi
/// tạm thời của IndexedDB (đang nâng cấp, bị chặn, hết quota).
class FlakyKv implements KvStore {
  FlakyKv(this.inner);
  final KvStore inner;
  bool failGet = false, failRename = false;
  int puts = 0;

  @override
  ValueListenable<bool> get persistent => inner.persistent;

  @override
  void markUnsafe() => inner.markUnsafe();

  @override
  Future<String?> get(String key) =>
      failGet ? Future.error(StateError('đọc lỗi')) : inner.get(key);

  @override
  Future<void> putAll(Map<String, String> entries) {
    puts++;
    return inner.putAll(entries);
  }

  @override
  Future<void> delete(String key) => inner.delete(key);

  @override
  Future<void> rename(String from, String to) => failRename
      ? Future.error(StateError('đổi khoá lỗi'))
      : inner.rename(from, to);
}
