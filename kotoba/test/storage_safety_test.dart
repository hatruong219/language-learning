import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/data_cache.dart';
import 'package:mnn_flashcard/data/kv_store.dart';
import 'package:mnn_flashcard/data/progress_store.dart';
import 'package:mnn_flashcard/data/settings_store.dart';
import 'package:mnn_flashcard/theme.dart';
import 'package:mnn_flashcard/ui/storage_banner.dart';

import 'support/failing_kv.dart';
import 'support/memory_kv.dart';

const _good =
    '{"app":"mnn_flashcard","version":1,"words":{"w1":{"c":2,"w":0,"s":1}}}';

/// Map mà duyệt tới phần tử thứ hai thì nổ — ép một lệnh put giữa chừng thất bại.
class _BoomMap extends MapBase<String, String> {
  @override
  Iterable<MapEntry<String, String>> get entries sync* {
    yield const MapEntry('a', '1');
    throw StateError('nổ giữa chừng');
  }

  @override
  String? operator [](Object? key) => null;
  @override
  void operator []=(String key, String value) {}
  @override
  void clear() {}
  @override
  Iterable<String> get keys => const [];
  @override
  String? remove(Object? key) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KvStore real;
  late FlakyKv kv;
  setUp(() async {
    real = await newMemoryKv();
    kv = FlakyKv(real);
  });

  group('đọc lỗi tạm thời không làm mất dữ liệu', () {
    test('ProgressStore: không đổi .broken, không ghi đè, đánh dấu không bền', () async {
      await real.putAll({ProgressStore.key: _good});
      kv.failGet = true;
      final p = await ProgressStore.open(kv: kv);
      kv.failGet = false;
      p.setStarred('w9', true);
      await p.flush();
      p.dispose();

      expect(await real.get(ProgressStore.key), _good, reason: 'bản tốt còn nguyên');
      expect(await real.get('${ProgressStore.key}.broken'), isNull);
      expect(kv.puts, 0);
      expect(real.persistent.value, isFalse);
    });

    test('ProgressStore: bản hỏng thật thì đổi .broken (vẫn bền)', () async {
      await real.putAll({ProgressStore.key: '{ hong'});
      final p = await ProgressStore.open(kv: kv);
      expect(await real.get('${ProgressStore.key}.broken'), '{ hong');
      expect(real.persistent.value, isTrue);
      p.dispose();
    });

    test('ProgressStore: bản sai kiểu (TypeError) cũng đổi .broken', () async {
      await real.putAll({ProgressStore.key: '{"words":{"w":5}}'});
      final p = await ProgressStore.open(kv: kv);
      expect(p.entries, isEmpty);
      expect(await real.get('${ProgressStore.key}.broken'), isNotNull);
      p.dispose();
    });

    test('ProgressStore: đổi khoá cũng hỏng thì không ghi đè', () async {
      await real.putAll({ProgressStore.key: '{ hong'});
      kv.failRename = true;
      final p = await ProgressStore.open(kv: kv);
      p.setStarred('w1', true);
      await p.flush();
      p.dispose();
      expect(await real.get(ProgressStore.key), '{ hong');
      expect(real.persistent.value, isFalse);
    });

    test('SettingsStore: đọc lỗi thì không ghi đè', () async {
      await real.putAll({SettingsStore.key: '{"mixKana":true}'});
      kv.failGet = true;
      final s = await SettingsStore.open(kv: kv);
      kv.failGet = false;
      s.shuffle = false;
      await s.flush();
      s.dispose();
      expect(await real.get(SettingsStore.key), '{"mixKana":true}');
      expect(real.persistent.value, isFalse);
    });

    test('SettingsStore: bản hỏng thật thì đổi .broken', () async {
      await real.putAll({SettingsStore.key: 'khong phai json'});
      final s = await SettingsStore.open(kv: kv);
      expect(await real.get('${SettingsStore.key}.broken'), 'khong phai json');
      s.dispose();
    });

    test('DataCache: đọc lỗi thì rơi về asset và KHÔNG đổi khoá', () async {
      await real.putAll({'kanji.json': '{"kanji":[],"components":[]}'});
      final cache = DataCache(
        assetPath: 'assets/kanji.json',
        key: 'kanji.json',
        store: kv,
      );
      kv.failGet = true;
      final json = await cache.read();
      kv.failGet = false;
      expect((json['kanji'] as List).length, 364);
      expect(await real.get('kanji.json'), isNotNull);
      expect(await real.get('kanji.json.broken'), isNull);
    });
  });

  group('nhập file sao lưu', () {
    late ProgressStore p;
    setUp(() async {
      p = await ProgressStore.open(kv: kv);
      p.setStarred('cu', true);
    });
    tearDown(() => p.dispose());

    test('nhận bản của app iOS và cất bản dự phòng bản cũ', () async {
      expect(await p.importJson(_good), 1);
      expect(p.isStarred('w1'), isTrue);
      expect(p.isStarred('cu'), isFalse);
      expect(await real.get(ProgressStore.backupKey), contains('"cu"'));
    });

    test('ô dự phòng chỉ có một, nhập lần sau đè lần trước', () async {
      await p.importJson(_good);
      await p.importJson(
        '{"app":"mnn_flashcard","version":1,"words":{"z":{"c":1,"w":0,"s":0}}}',
      );
      final b = await real.get(ProgressStore.backupKey);
      expect(b, contains('"w1"'));
      expect(b, isNot(contains('"cu"')));
    });

    test('tiến độ đang trống thì không đè mất bản dự phòng cũ', () async {
      await p.importJson(_good);
      p.clearAll();
      final before = await real.get(ProgressStore.backupKey);
      await p.importJson(_good);
      expect(await real.get(ProgressStore.backupKey), before);
    });

    for (final (name, raw) in [
      ('không phải JSON', 'xin chao'),
      ('thiếu app', '{"version":1,"words":{"w":{"c":1,"w":0,"s":0}}}'),
      ('sai app', '{"app":"khac","words":{"w":{"c":1,"w":0,"s":0}}}'),
      ('thiếu words', '{"app":"mnn_flashcard","version":1}'),
      ('words không phải map', '{"app":"mnn_flashcard","words":[]}'),
      ('words rỗng', '{"app":"mnn_flashcard","version":1,"words":{}}'),
      ('mục sai kiểu', '{"app":"mnn_flashcard","words":{"w":5}}'),
    ]) {
      test('từ chối: $name — tiến độ cũ giữ nguyên', () async {
        await expectLater(p.importJson(raw), throwsA(isA<ImportException>()));
        expect(p.isStarred('cu'), isTrue);
        expect(await real.get(ProgressStore.backupKey), isNull);
      });
    }
  });

  group('IdbKvStore._write', () {
    test('lỗi giữa chừng: put đã xếp hàng không commit', () async {
      await real.putAll({'a': 'cu'});
      await expectLater(real.putAll(_BoomMap()), throwsStateError);
      expect(await real.get('a'), 'cu', reason: 'transaction phải bị huỷ');
      await real.putAll({'b': '1'}); // kho vẫn dùng được sau lỗi
      expect(await real.get('b'), '1');
    });
  });

  group('StorageBanner', () {
    Widget host(ValueListenable<bool> p) => MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: StorageBanner(persistent: p, child: const Text('noi-dung')),
      ),
    );

    testWidgets('chỉ hiện khi không bền, và biến mất khi hết lỗi', (t) async {
      final flag = ValueNotifier(true);
      await t.pumpWidget(host(flag));
      expect(find.byKey(const Key('storage-banner')), findsNothing);
      expect(find.text('noi-dung'), findsOneWidget);

      flag.value = false;
      await t.pump();
      expect(find.text(StorageBanner.message), findsOneWidget);
      expect(find.text('noi-dung'), findsOneWidget);
    });
  });
}
