import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:mnn_flashcard/data/kv_store.dart';

import 'support/memory_kv.dart';

/// Kho khoá–giá trị là nền của tiến độ, cài đặt và bản đồng bộ. Chạy trên
/// IndexedDB bản bộ nhớ của idb_shim — cùng mã [IdbKvStore] như ở trình duyệt.
void main() {
  late KvStore kv;
  setUp(() async => kv = await newMemoryKv());

  test('khoá chưa có thì trả null', () async {
    expect(await kv.get('khong-co'), isNull);
  });

  test('putAll ghi nhiều khoá, ghi lại thì đè', () async {
    await kv.putAll({'a': '1', 'b': '2'});
    expect(await kv.get('a'), '1');
    expect(await kv.get('b'), '2');
    await kv.putAll({'a': '3'});
    expect(await kv.get('a'), '3');
    expect(await kv.get('b'), '2', reason: 'khoá không nhắc tới thì giữ nguyên');
  });

  test('chuỗi tiếng Nhật và chuỗi lớn ghi đọc lại y nguyên', () async {
    final big = List.filled(200000, '漢字ひらがな').join();
    await kv.putAll({'big': big});
    expect(await kv.get('big'), big);
  });

  test('delete bỏ khoá, khoá không có thì không nổ', () async {
    await kv.putAll({'a': '1'});
    await kv.delete('a');
    await kv.delete('a');
    expect(await kv.get('a'), isNull);
  });

  test('rename chuyển giá trị và đè khoá đích', () async {
    await kv.putAll({'x': 'hong', 'x.broken': 'cu'});
    await kv.rename('x', 'x.broken');
    expect(await kv.get('x'), isNull);
    expect(await kv.get('x.broken'), 'hong');
  });

  test('rename khoá không có thì không tạo gì', () async {
    await kv.rename('khong-co', 'dich');
    expect(await kv.get('dich'), isNull);
  });

  test('mở lại cùng factory vẫn thấy dữ liệu đã ghi', () async {
    final factory = newIdbFactoryMemory();
    final first = await IdbKvStore.open(factory);
    await first.putAll({'k': 'v'});
    final second = await IdbKvStore.open(factory);
    expect(await second.get('k'), 'v');
  });
}
