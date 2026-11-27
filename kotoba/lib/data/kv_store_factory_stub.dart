import 'package:idb_shim/idb_client_memory.dart';
import 'package:idb_shim/idb_shim.dart';

/// Ngoài trình duyệt (VM, test) không có IndexedDB: dùng bản bộ nhớ.
IdbFactory platformIdbFactory() => newIdbFactoryMemory();

/// Không có gì để xin ngoài trình duyệt.
Future<void> requestPersistentStorage() async {}
