import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/data/kv_store.dart';
import 'package:mnn_flashcard/data/progress_store.dart';
import 'package:mnn_flashcard/data/settings_store.dart';

import 'support/memory_kv.dart';

/// Tiến độ và cài đặt đi qua kho IndexedDB: ghi → mở lại → còn nguyên.
void main() {
  late KvStore kv;
  setUp(() async => kv = await newMemoryKv());

  group('ProgressStore', () {
    test('flush rồi mở lại thấy đúng tiến độ', () async {
      final a = await ProgressStore.open(kv: kv);
      a.setStarred('w1', true);
      a.record('w2', correct: false);
      await a.flush();
      a.dispose();

      final b = await ProgressStore.open(kv: kv);
      expect(b.isStarred('w1'), isTrue);
      expect(b.of('w2').wrong, 1);
      b.dispose();
    });

    test('ghi trì hoãn: chưa flush thì kho chưa có gì', () async {
      final a = await ProgressStore.open(kv: kv);
      a.setStarred('w1', true);
      expect(await kv.get(ProgressStore.key), isNull);
      await a.flush();
      expect(await kv.get(ProgressStore.key), contains('"version": 1'));
      a.dispose();
    });

    test('bản hỏng thì mở trống và giữ lại ở .broken', () async {
      await kv.putAll({ProgressStore.key: '{ hong'});
      final a = await ProgressStore.open(kv: kv);
      expect(a.entries, isEmpty);
      expect(await kv.get('${ProgressStore.key}.broken'), '{ hong');
      expect(await kv.get(ProgressStore.key), isNull);
      a.dispose();
    });

    test('nhập file sao lưu của app iOS (định dạng version 1)', () async {
      final a = await ProgressStore.open(kv: kv);
      const backup =
          '{"app":"mnn_flashcard","version":1,"words":'
          '{"w9":{"c":3,"w":1,"s":1}}}';
      expect(await a.importJson(backup), 1);
      expect(a.of('w9').correct, 3);
      await a.flush();
      a.dispose();
      final b = await ProgressStore.open(kv: kv);
      expect(b.isStarred('w9'), isTrue);
      b.dispose();
    });
  });

  group('SettingsStore', () {
    test('flush rồi mở lại thấy đúng cài đặt', () async {
      final a = await SettingsStore.open(kv: kv);
      a.mixKana = true;
      a.lastLessons = {3, 1};
      await a.flush();
      a.dispose();

      final b = await SettingsStore.open(kv: kv);
      expect(b.mixKana, isTrue);
      expect(b.lastLessons, {1, 3});
      b.dispose();
    });

    test('khoá offlineSpeech cũ trong JSON không làm hỏng việc đọc', () async {
      await kv.putAll({
        SettingsStore.key: '{"offlineSpeech":true,"mixKana":true}',
      });
      final s = await SettingsStore.open(kv: kv);
      expect(s.mixKana, isTrue);
      s.dispose();
    });

    test('bản hỏng thì dùng mặc định, không nổ', () async {
      await kv.putAll({SettingsStore.key: 'khong phai json'});
      final a = await SettingsStore.open(kv: kv);
      expect(a.mixKana, isFalse);
      a.dispose();
    });
  });
}
