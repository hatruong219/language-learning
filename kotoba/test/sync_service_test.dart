import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnn_flashcard/data/data_cache.dart';
import 'package:mnn_flashcard/data/kv_store.dart';
import 'package:mnn_flashcard/data/sync_service.dart';

import 'support/memory_kv.dart';

/// Đồng bộ là chỗ duy nhất app phụ thuộc máy chủ, nên mọi đường hỏng phải trả
/// về câu người dùng đọc hiểu — không để `ClientException` hay mã trạng thái
/// thô lọt lên màn hình.
void main() {
  // Cache ghi vào kho IndexedDB bộ nhớ nên cần binding đã khởi tạo cho nhánh đọc asset.
  TestWidgetsFlutterBinding.ensureInitialized();

  const base = 'https://example.test';

  SyncService svc(
    Future<http.Response> Function(http.Request) handler, {
    String? b,
  }) => SyncService(client: MockClient(handler), base: b ?? base);

  /// Dựng phản hồi bằng BYTES, không bằng String.
  ///
  /// `http.Response(body, status)` mã hoá thân theo charset trong Content-Type,
  /// mà mặc định là latin-1 — tiếng Nhật không biểu diễn được trong latin-1 nên
  /// nó ném "Contains invalid characters". Đúng là lý do production đọc
  /// bodyBytes rồi tự giải UTF-8 thay vì dùng res.body.
  http.Response ok(String body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(body), status);

  /// Một bộ dữ liệu tối thiểu đúng hình dạng assets/kanji.json.
  String kanjiPayload() => jsonEncode({
    'kanji': [
      {
        'c': '学',
        'on': ['ガク'],
        'kun': ['まな.ぶ'],
        'hv': ['học'],
        'en': ['study'],
        'strokes': 8,
        'grade': 1,
        'radical': 39,
        'freq': 63,
        'level': 'N5',
        'level_ref': 'N5',
        'in_course': true,
        'parts': ['子', '冖'],
        'kyujitai': null,
        'meaning_vi': null,
        'meaning_classic': 'Bắt chước',
      },
    ],
    'components': [
      {
        'c': '子',
        'unlocks': 12,
        'in_set': true,
        'hv': ['tử'],
        'meaning_vi': 'con',
        'radical_of': null,
        'radical_strokes': 3,
        'en': ['child'],
        'meaning_classic': null,
        'is_shape': false,
      },
    ],
  });

  test('chưa cấu hình địa chỉ thì không gọi mạng, và nói rõ lý do', () async {
    var called = false;
    final s = svc((_) async {
      called = true;
      return ok('{}');
    }, b: '');
    expect(s.configured, isFalse);
    await expectLater(
      s.fetchKanji(),
      throwsA(
        isA<SyncException>().having(
          (e) => e.message,
          'message',
          contains('Chưa cấu hình'),
        ),
      ),
    );
    expect(called, isFalse, reason: 'không được gọi mạng khi chưa cấu hình');
  });

  test('mặc định bật sẵn và gọi cùng nguồn dưới /kotoba-app', () async {
    Uri? seen;
    final s = SyncService(
      client: MockClient((req) async {
        seen = req.url;
        return ok(kanjiPayload());
      }),
    );
    expect(s.configured, isTrue);
    await s.fetchKanji();
    expect(seen.toString(), '/kotoba-app/api/kotoba/kanji');
  });

  test('gọi đúng đường dẫn', () async {
    Uri? seen;
    final s = svc((req) async {
      seen = req.url;
      return ok(kanjiPayload());
    });
    await s.fetchKanji();
    expect(seen.toString(), '$base/api/kotoba/kanji');
  });

  test('đọc được dữ liệu qua CHUNG bộ phân tích với asset', () async {
    final s = svc((_) async => ok(kanjiPayload()));
    final set = await s.fetchKanji();
    expect(set.kanji.length, 1);
    expect(set.byChar('学')!.hanViet.first, 'học');
    expect(set.partByChar('子')!.meaningVi, 'con');
  });

  test('giải UTF-8 đúng dù máy chủ không ghi charset', () async {
    // res.body dùng latin-1 khi Content-Type thiếu charset — tiếng Nhật thành
    // ký tự rác. Phải đọc bodyBytes rồi tự giải.
    final s = svc(
      (_) async => http.Response.bytes(
        utf8.encode(kanjiPayload()),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final set = await s.fetchKanji();
    expect(set.byChar('学'), isNotNull, reason: 'chữ Hán phải đọc đúng');
    expect(set.byChar('学')!.on.first, 'ガク');
  });

  test('404 nói rõ là chưa có dữ liệu, không phải lỗi mạng', () async {
    final s = svc((_) async => ok('{"error":"x"}', 404));
    await expectLater(
      s.fetchKanji(),
      throwsA(
        isA<SyncException>().having(
          (e) => e.message,
          'message',
          contains('migration'),
        ),
      ),
    );
  });

  test('500 báo mã lỗi mà không đổ nội dung thô ra màn hình', () async {
    final s = svc((_) async => ok('<html>Internal Server Error</html>', 500));
    await expectLater(
      s.fetchKanji(),
      throwsA(
        isA<SyncException>().having(
          (e) => e.message,
          'message',
          allOf(contains('500'), isNot(contains('html'))),
        ),
      ),
    );
  });

  test('JSON hỏng không để FormatException lọt ra', () async {
    final s = svc((_) async => ok('{ khong phai json'));
    await expectLater(s.fetchKanji(), throwsA(isA<SyncException>()));
  });

  test(
    'dữ liệu đúng JSON nhưng sai hình dạng thì nói app có thể đã cũ',
    () async {
      final s = svc((_) async => ok('{"kanji":"khong-phai-mang"}'));
      await expectLater(
        s.fetchKanji(),
        throwsA(
          isA<SyncException>().having(
            (e) => e.message,
            'message',
            contains('không đúng dạng'),
          ),
        ),
      );
    },
  );

  test('trả mảng ở gốc thay vì object cũng không làm sập', () async {
    final s = svc((_) async => ok('[1,2,3]'));
    await expectLater(s.fetchKanji(), throwsA(isA<SyncException>()));
  });

  test('ngữ pháp trả JSON thô, đúng đường dẫn', () async {
    Uri? seen;
    final s = svc((req) async {
      seen = req.url;
      return ok(
        jsonEncode({
          'counts': {'grammar': 252},
          'grammar': [],
        }),
      );
    });
    final json = await s.fetchGrammar();
    expect(seen.toString(), '$base/api/kotoba/grammar');
    expect((json['counts'] as Map)['grammar'], 252);
  });

  group('địa chỉ máy chủ', () {
    test('cắt dấu / thừa ở cuối, không ghép thành //api', () async {
      // Dán từ thanh địa chỉ trình duyệt là dính dấu / cuối. Ghép thẳng ra
      // '…//api/kotoba/kanji'; nhiều máy chủ trả 404 cho đường dẫn đó, mà app
      // lại hiện "có thể migration chưa chạy" — dẫn đi tìm nhầm hẳn chỗ.
      Uri? seen;
      final s = svc((req) async {
        seen = req.url;
        return ok(kanjiPayload());
      }, b: 'https://admin.truongha.com///');

      await s.fetchKanji();
      expect(seen.toString(), 'https://admin.truongha.com/api/kotoba/kanji');
    });
  });

  test('mất mạng (ClientException) thì báo câu kiểm tra mạng', () async {
    final s = svc((_) async => throw http.ClientException('Failed to fetch'));
    await expectLater(
      s.fetchGrammar(),
      throwsA(
        isA<SyncException>().having(
          (e) => e.message,
          'message',
          contains('Kiểm tra mạng'),
        ),
      ),
    );
  });

  group('tất cả hoặc không gì cả', () {
    late KvStore kv;

    setUp(() async => kv = await newMemoryKv());

    DataCache store(String name, [KvStore? over]) =>
        DataCache(assetPath: 'assets/$name', key: name, store: over ?? kv);

    SyncService withStores(
      Future<http.Response> Function(http.Request) handler, {
      KvStore? over,
    }) => SyncService(
      client: MockClient(handler),
      base: base,
      kanjiStore: store('kanji.json', over),
      kanjiWordsStore: store('kanji-words.json', over),
      grammarStore: store('grammar.json', over),
    );

    String wordsPayload() => jsonEncode({
      'moc': 'moi',
      'count': 1,
      'words': [
        {
          'n': 1,
          'word': '家',
          'hv': 'GIA',
          'kana': 'いえ',
          'meaning': 'Nhà',
          'level': 'N4',
          'chars': ['家'],
          'unknown': <String>[],
        },
      ],
    });

    String grammarPayload() => jsonEncode({
      'moc': 'moi',
      'counts': {'lessons': 50, 'grammar': 252, 'sentences': 1247},
      'lessons': <Map<String, Object?>>[],
      'grammar': <Map<String, Object?>>[],
      'sentences': <Map<String, Object?>>[],
    });

    /// Bản CŨ đang dùng, để xem nó có bị đụng vào không.
    Future<void> seedOld() async {
      await store('kanji.json').write({
        'moc': 'cu',
        'kanji': <Map<String, Object?>>[],
        'components': <Map<String, Object?>>[],
      });
      await store(
        'kanji-words.json',
      ).write({'moc': 'cu', 'words': <Map<String, Object?>>[]});
      await store('grammar.json').write({'moc': 'cu', 'counts': {}});
    }

    Future<String> mocOf(String name) async =>
        (jsonDecode((await kv.get(name))!) as Map)['moc'] as String;

    /// Khoá phụ (.tmp/.bak) không còn tồn tại trong thiết kế mới; giữ kiểm để
    /// khoá hồi quy nếu ai đó đưa lại kiểu ghi hai bước.
    Future<List<String>> junk() async => [
      for (final n in ['kanji.json', 'kanji-words.json', 'grammar.json'])
        for (final ext in ['.tmp', '.bak'])
          if (await kv.get('$n$ext') != null) '$n$ext',
    ];

    /// Bản mới có mốc riêng để phân biệt với bản cũ.
    String kanjiNew() {
      final j = jsonDecode(kanjiPayload()) as Map<String, dynamic>;
      j['moc'] = 'moi';
      return jsonEncode(j);
    }

    test('cả ba phần ổn thì thay CẢ BA', () async {
      await seedOld();
      final s = withStores(
        (req) async =>
            ok(_pick(req, kanjiNew(), wordsPayload(), grammarPayload())),
      );

      final r = await s.downloadAll();
      expect(r.grammarCount, 252);
      expect(r.sentenceCount, 1247);
      expect(await mocOf('kanji.json'), 'moi');
      expect(await mocOf('kanji-words.json'), 'moi');
      expect(await mocOf('grammar.json'), 'moi');
      expect(await junk(), isEmpty, reason: 'xong rồi phải dọn sạch');
    });

    test('ngữ pháp hỏng thì chữ Hán cũng KHÔNG bị thay', () async {
      // Bài kiểm chính. Bản trước đây ghi chữ Hán ngay khi tải xong, nên ngữ
      // pháp hỏng là còn lại chữ Hán đời mới lẫn ngữ pháp đời cũ — hai file đến
      // từ cùng một lần chụp database nên trộn hai đời là dữ liệu SAI, mà app
      // vẫn chạy bình thường nên không ai biết.
      await seedOld();
      final s = withStores(
        (req) async =>
            ok(_pick(req, kanjiNew(), wordsPayload(), '{"thieu":"counts"}')),
      );

      await expectLater(s.downloadAll(), throwsA(isA<SyncException>()));
      expect(await mocOf('kanji.json'), 'cu', reason: 'chữ Hán phải còn nguyên');
      expect(await mocOf('kanji-words.json'), 'cu');
      expect(await mocOf('grammar.json'), 'cu');
      expect(await junk(), isEmpty, reason: 'hỏng rồi cũng phải dọn sạch');
    });

    test('chữ Hán hỏng thì ngữ pháp cũng KHÔNG bị thay', () async {
      await seedOld();
      final s = withStores(
        (req) async => ok(
          _pick(
            req,
            '{"kanji":"khong-phai-mang"}',
            wordsPayload(),
            grammarPayload(),
          ),
        ),
      );

      await expectLater(s.downloadAll(), throwsA(isA<SyncException>()));
      expect(await mocOf('kanji.json'), 'cu');
      expect(await mocOf('grammar.json'), 'cu', reason: 'ngữ pháp phải còn nguyên');
    });

    test('máy chủ lỗi ở một phần thì không đụng gì vào cache', () async {
      await seedOld();
      final s = withStores(
        (req) async =>
            req.url.path.endsWith('kanji') ? ok(kanjiNew()) : ok('loi', 500),
      );

      await expectLater(s.downloadAll(), throwsA(isA<SyncException>()));
      expect(await mocOf('kanji.json'), 'cu');
      expect(await mocOf('grammar.json'), 'cu');
    });

    test('ghi vào kho LỖI thì báo SyncException và bản cũ còn nguyên', () async {
      await seedOld();
      final s = withStores(
        (req) async =>
            ok(_pick(req, kanjiNew(), wordsPayload(), grammarPayload())),
        over: _FailingPutKv(kv),
      );

      await expectLater(s.downloadAll(), throwsA(isA<SyncException>()));
      expect(await mocOf('kanji.json'), 'cu');
      expect(await mocOf('kanji-words.json'), 'cu');
      expect(await mocOf('grammar.json'), 'cu');
    });

    test('chưa có bản cũ mà hỏng thì không sinh ra khoá dở dang', () async {
      // Lần đầu cài app: cache rỗng, đang đọc asset. Hỏng giữa chừng mà để lại
      // một file kanji.json không có cặp ngữ pháp đi kèm thì lần mở sau app đọc
      // chữ Hán từ máy chủ còn ngữ pháp từ asset — vẫn là trộn hai đời.
      final s = withStores(
        (req) async => ok(_pick(req, kanjiNew(), wordsPayload(), '{"x":1}')),
      );
      await expectLater(s.downloadAll(), throwsA(isA<SyncException>()));

      expect(await kv.get('kanji.json'), isNull);
      expect(await kv.get('kanji-words.json'), isNull);
      expect(await kv.get('grammar.json'), isNull);
      expect(await junk(), isEmpty);
    });
  });
}

/// Kho mà mọi lần ghi đều ném, còn đọc thì chuyển cho kho thật.
class _FailingPutKv implements KvStore {
  _FailingPutKv(this._inner);
  final KvStore _inner;

  @override
  ValueListenable<bool> get persistent => _inner.persistent;

  @override
  void markUnsafe() => _inner.markUnsafe();

  @override
  Future<void> putAll(Map<String, String> entries) =>
      Future.error(StateError('đĩa đầy'));

  @override
  Future<String?> get(String key) => _inner.get(key);

  @override
  Future<void> delete(String key) => _inner.delete(key);

  @override
  Future<void> rename(String from, String to) => _inner.rename(from, to);
}

/// Chọn payload theo đường dẫn. Ba route nên không so bằng `endsWith('kanji')`
/// được nữa — `kotoba/kanji-words` cũng chứa chữ "kanji".
String _pick(http.Request req, String kanji, String words, String grammar) {
  final p = req.url.path;
  if (p.endsWith('kanji-words')) return words;
  if (p.endsWith('grammar')) return grammar;
  return kanji;
}
