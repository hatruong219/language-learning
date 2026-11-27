import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnn_flashcard/data/data_cache.dart';
import 'package:mnn_flashcard/data/kv_store.dart';
import 'package:mnn_flashcard/data/sync_service.dart';
import 'package:mnn_flashcard/theme.dart';
import 'package:mnn_flashcard/ui/sync_row.dart';

import 'support/memory_kv.dart';

/// Nút đồng bộ là chỗ duy nhất người dùng chạm vào mạng, nên mọi trạng thái
/// phải nói ra được: chưa cấu hình, đang tải, xong, và hỏng.
void main() {
  const base = 'https://example.test';

  http.Response ok(String body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(body), status);

  String kanjiPayload() => jsonEncode({
    'kanji': [
      {
        'c': '学',
        'on': ['ガク'],
        'kun': <String>[],
        'hv': ['học'],
        'en': ['study'],
        'strokes': 8,
        'level': 'N5',
        'level_ref': 'N5',
        'in_course': true,
        'parts': ['子'],
      },
    ],
    'components': [
      {
        'c': '子',
        'unlocks': 12,
        'in_set': false,
        'hv': ['tử'],
        'en': <String>[],
      },
    ],
  });

  String wordsPayload() => jsonEncode({
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
    'counts': {'lessons': 50, 'grammar': 252, 'sentences': 1247},
    'lessons': <Map<String, Object?>>[],
    'grammar': <Map<String, Object?>>[],
    'sentences': <Map<String, Object?>>[],
  });

  Widget wrap(SyncService svc) => MaterialApp(
    theme: buildTheme(Brightness.light),
    home: Scaffold(body: SyncRow(service: svc)),
  );

  late KvStore kv;

  setUp(() async => kv = await newMemoryKv());

  /// Cache ghi vào kho IndexedDB bản bộ nhớ MỚI cho mỗi test — cùng mã với
  /// trình duyệt, nên kiểm được cả đường ghi thật.
  DataCache store(String name) =>
      DataCache(assetPath: 'assets/$name', key: name, store: kv);

  SyncService svc(
    Future<http.Response> Function(http.Request) handler, {
    String? b,
  }) => SyncService(
    client: MockClient(handler),
    base: b ?? base,
    kanjiStore: store('kanji.json'),
    kanjiWordsStore: store('kanji-words.json'),
    grammarStore: store('grammar.json'),
  );

  /// Chọn payload theo đường dẫn.
  ///
  /// Ba route nên không so `endsWith('kanji')` được nữa — `kotoba/kanji-words`
  /// cũng chứa chữ "kanji" ở cuối phần đầu đường dẫn.
  http.Response pick(http.Request req) {
    final p = req.url.path;
    if (p.endsWith('kanji-words')) return ok(wordsPayload());
    if (p.endsWith('grammar')) return ok(grammarPayload());
    return ok(kanjiPayload());
  }

  /// Bấm nút rồi chờ xong.
  ///
  /// Hai cái bẫy ở đây, cả hai đều làm test treo nếu không xử lý:
  ///
  /// KHÔNG dùng pumpAndSettle. Lúc đang tải có CircularProgressIndicator mà nó
  /// quay vô hạn, nên pumpAndSettle hết giờ chứ không bao giờ "settle".
  ///
  /// PHẢI qua runAsync. downloadAll ghi vào kho IndexedDB (bản bộ nhớ), mà
  /// trong widget test vùng async là giả — Future của kho không hoàn thành nếu
  /// chỉ pump. runAsync nhường lại cho vòng lặp sự kiện thật, còn pump có
  /// thời lượng để chạy nốt các timer của vùng giả.
  Future<void> tapAndWait(WidgetTester tester) async {
    await tester.tap(find.text('Tải tất cả'));
    await tester.pump();
    for (var i = 0; i < 50; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
  }

  testWidgets('chưa cấu hình máy chủ thì nói rõ, không cho bấm', (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(
      wrap(
        svc((_) async {
          called = true;
          return ok('{}');
        }, b: ''),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Bản app này chưa cấu hình địa chỉ máy chủ'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tải tất cả'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(called, isFalse, reason: 'không được gọi mạng khi chưa cấu hình');
  });

  testWidgets('tải xong thì báo đã lấy được những gì', (tester) async {
    await tester.pumpWidget(wrap(svc((req) async => pick(req))));
    await tester.pumpAndSettle();

    expect(find.text('Từ vựng, chữ Hán, và ngữ pháp'), findsOneWidget);
    await tapAndWait(tester);

    // Con số lấy từ `counts` của máy chủ, không phải đếm lại ở app.
    expect(
      find.text('1 chữ · 1 mảnh · 1 từ Hán · 252 mẫu ngữ pháp · 1247 câu'),
      findsOneWidget,
    );
  });

  testWidgets('hỏng thì hiện lý do và cho thử lại', (tester) async {
    await tester.pumpWidget(wrap(svc((_) async => ok('{"error":"x"}', 404))));
    await tester.pumpAndSettle();

    await tapAndWait(tester);

    expect(find.textContaining('migration'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });

  testWidgets('máy chủ trả dữ liệu sai dạng thì KHÔNG ghi cache', (
    tester,
  ) async {
    // Đây là chỗ nguy hiểm nhất: ghi payload hỏng vào cache thì đè mất bản đang
    // dùng tốt, và app hỏng cho tới khi có mạng lại. Phải kiểm trước khi ghi.
    //
    // Hai lời gọi chạy SONG SONG nên phần ngữ pháp vẫn được gọi dù chữ Hán
    // hỏng — điều đó không sao. Bảo đảm nằm ở chỗ khác và chặt hơn: không file
    // nào bị thay. Xem nhóm "tất cả hoặc không gì cả" trong sync_service_test.
    await tester.pumpWidget(
      wrap(
        svc(
          (req) async => req.url.path.endsWith('/kanji')
              ? ok('{"kanji":"khong-phai-mang"}')
              : pick(req),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tapAndWait(tester);

    expect(find.textContaining('không đúng dạng'), findsOneWidget);
    for (final k in ['kanji.json', 'kanji-words.json', 'grammar.json']) {
      expect(
        // runAsync: vùng async của widget test là giả, kho thật không xong nếu
        // chỉ pump.
        await tester.runAsync(() => kv.get(k)),
        isNull,
        reason: 'hỏng thì không được để lại khoá nào trong cache',
      );
    }
  });

  testWidgets('ngữ pháp thiếu counts cũng bị coi là sai dạng', (tester) async {
    await tester.pumpWidget(
      wrap(
        svc(
          (req) async => req.url.path.endsWith('grammar')
              ? ok('{"grammar":[]}')
              : pick(req),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tapAndWait(tester);
    expect(find.textContaining('ngữ pháp'), findsOneWidget);
  });

  testWidgets('hàng nguồn dữ liệu nói đang dùng bản nào', (tester) async {
    for (final (has, label) in [(true, 'Đã tải về'), (false, 'Bản đóng gói')]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(Brightness.light),
          home: Scaffold(body: DataSourceRow(hasDownload: has)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget);
    }
  });
}
