import 'package:idb_shim/idb_client_memory.dart';
import 'package:mnn_flashcard/data/kv_store.dart';

/// Kho IndexedDB bản bộ nhớ, MỚI cho từng test.
///
/// Cùng mã [IdbKvStore] chạy ở trình duyệt — chỉ khác chỗ cất bên dưới — nên
/// test đi đúng đường mã thật chứ không phải một kho giả tự chế.
Future<IdbKvStore> newMemoryKv() => IdbKvStore.open(newIdbFactoryMemory());
