import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/data_cache.dart';
import 'package:mnn_flashcard/data/kv_store.dart';

import 'support/memory_kv.dart';

/// Cache là chỗ app tự chữa hoặc tự hỏng.
///
/// Ghi vào đây là ghi vào thứ app đọc lúc mở lên. File hỏng mà không xử lý thì
/// app không mở được nữa, và trên iPhone thì không có cách nào xoá file đó ngoài
/// xoá cả app — tức mất luôn tiến độ học.
void main() {
  // rootBundle cần binding đã khởi tạo. Không có dòng này thì mọi test đọc asset
  // ném "Binding has not yet been initialized" — dễ tưởng là lỗi asset.
  TestWidgetsFlutterBinding.ensureInitialized();

  late KvStore kv;
  late DataCache cache;

  setUp(() async {
    kv = await newMemoryKv();
    cache = DataCache(
      assetPath: 'assets/kanji.json',
      key: 'kanji.json',
      store: kv,
    );
  });

  test('chưa tải thì rơi về asset đóng gói', () async {
    expect(await cache.hasDownload, isFalse);
    final json = await cache.read();
    // Đọc asset thật: 364 chữ. Đây cũng là bài kiểm rằng asset đã khai báo trong
    // pubspec — thiếu khai báo thì lời gọi này ném.
    expect((json['kanji'] as List).length, 364);
  });

  test('ghi rồi đọc lại ra đúng bản đã ghi, không phải asset', () async {
    await cache.write({'kanji': [], 'components': [], 'dau': 'nhan-dang'});
    expect(await cache.hasDownload, isTrue);
    final json = await cache.read();
    expect(json['dau'], 'nhan-dang');
    expect((json['kanji'] as List), isEmpty, reason: 'phải là bản đã ghi');
  });

  test('ghi xong chỉ có đúng một khoá, không để lại khoá phụ', () async {
    await cache.write({'x': 1});
    expect(await kv.get('kanji.json'), isNotNull);
    expect(await kv.get('kanji.json.tmp'), isNull);
    expect(await kv.get('kanji.json.bak'), isNull);
  });

  test('bản HỎNG thì đổi sang khoá .broken và rơi về asset, KHÔNG xoá', () async {
    await kv.putAll({'kanji.json': '{ day khong phai json'});
    final json = await cache.read();

    // App vẫn chạy được: rơi về asset.
    expect((json['kanji'] as List).length, 364);
    // File hỏng được giữ lại để còn truy được nguyên nhân. Xoá thì app tự chữa
    // nhưng không ai biết chuyện gì đã xảy ra.
    expect(await kv.get('kanji.json.broken'), '{ day khong phai json');
    expect(await kv.get('kanji.json'), isNull);
  });

  test('JSON hợp lệ nhưng gốc là mảng cũng bị coi là hỏng', () async {
    await kv.putAll({'kanji.json': jsonEncode([1, 2, 3])});
    final json = await cache.read();
    expect((json['kanji'] as List).length, 364);
    expect(await kv.get('kanji.json.broken'), isNotNull);
  });

  test('clear bỏ bản tải về, quay lại asset', () async {
    await cache.write({'kanji': [], 'components': []});
    expect(await cache.hasDownload, isTrue);
    await cache.clear();
    expect(await cache.hasDownload, isFalse);
    expect((await cache.read())['kanji'], isNotEmpty);
  });

  test('clear khi chưa có bản tải thì không nổ', () async {
    await cache.clear();
    expect(await cache.hasDownload, isFalse);
  });

  test('assets/grammar.json ĐÃ khai báo trong pubspec', () async {
    // Đây là bài kiểm cho pubspec, không phải cho cache. Quên khai báo thì mọi
    // test đọc thẳng file vẫn xanh, trong khi app thật đọc qua
    // rootBundle và nổ ngay lúc mở lên — chuyện đã xảy ra với assets/kanji.json.
    final grammar = DataCache(
      assetPath: 'assets/grammar.json',
      key: 'grammar.json',
      store: kv,
    );
    final json = await grammar.read();
    expect((json['grammar'] as List).length, 252);
    expect((json['sentences'] as List).length, 1247);
  });
}
