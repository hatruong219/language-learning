import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnn_flashcard/data/data_cache.dart';
import 'package:mnn_flashcard/data/sync_service.dart';

import 'support/memory_kv.dart';

/// Hợp đồng với server: route proxy chỉ cho đúng các resource này.
/// Khớp với `src/app/kotoba-app/api/kotoba/[resource]/route.ts` (ALLOWED).
/// Thêm đường mới ở app mà quên bên server là sync hỏng ngoài production.
const allowedResources = {'grammar', 'kanji', 'kanji-words'};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mọi đường SyncService gọi nằm trong allowlist của server', () async {
    final paths = <String>[];
    final client = MockClient((r) async {
      paths.add(r.url.path);
      return http.Response.bytes(utf8.encode(jsonEncode({})), 200);
    });
    final kv = await newMemoryKv();
    DataCache cache(String key) =>
        DataCache(assetPath: 'assets/$key', key: key, store: kv);
    final s = SyncService(
      client: client,
      base: 'https://x.test/kotoba-app',
      kanjiStore: cache('kanji.json'),
      kanjiWordsStore: cache('kanji-words.json'),
      grammarStore: cache('grammar.json'),
    );
    try {
      await s.downloadAll();
    } on Object {
      /* payload giả có thể bị từ chối khi kiểm — chỉ cần các đường đã gọi */
    }
    try {
      await s.fetchGrammar();
    } on Object {/* như trên */}
    try {
      await s.fetchKanji();
    } on Object {/* như trên */}

    expect(paths, isNotEmpty);
    const prefix = '/kotoba-app/api/kotoba/';
    for (final p in paths) {
      expect(p, startsWith(prefix));
      expect(allowedResources, contains(p.substring(prefix.length)));
    }
  });
}
