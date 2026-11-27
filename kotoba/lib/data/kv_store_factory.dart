import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb_client_memory.dart';

import 'kv_store.dart';
import 'kv_store_factory_stub.dart'
    if (dart.library.js_interop) 'kv_store_factory_web.dart';

Future<KvStore>? _default;

/// Kho dùng chung của app, mở một lần rồi cả tiến độ, cài đặt, cache đồng bộ
/// cùng dùng lại — mở DB ba lần thì tốn mà còn dễ chặn nhau lúc nâng cấp.
///
/// Mở không được (Safari chế độ riêng tư chặn IndexedDB) thì rơi về kho trong
/// bộ nhớ: app vẫn học được, chỉ là tắt tab là mất tiến độ. Ghi rõ ra log chứ
/// không im lặng.
Future<KvStore> openDefaultKvStore() => _default ??= _openDefault();

Future<KvStore> _openDefault() async {
  try {
    final store = await IdbKvStore.open(platformIdbFactory());
    await requestPersistentStorage();
    return store;
  } on Object catch (e) {
    debugPrint('IndexedDB không mở được ($e) — dùng kho trong bộ nhớ');
    return IdbKvStore.open(newIdbFactoryMemory(), persistent: false);
  }
}
