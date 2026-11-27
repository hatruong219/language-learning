import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/app_scope.dart';
import 'package:mnn_flashcard/data/kanji.dart';
import 'package:mnn_flashcard/data/kanji_index.dart';
import 'package:mnn_flashcard/data/progress_store.dart';
import 'package:mnn_flashcard/data/settings_store.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';
import 'package:mnn_flashcard/speech/speech_service.dart';
import 'package:mnn_flashcard/theme.dart';
import 'package:mnn_flashcard/ui/root_tabs.dart';

import 'support/asset_fixtures.dart';

/// Mọi chữ trên màn hình phải mang font đóng gói (NotoSans + fallback
/// NotoSansJP) hoặc font icon.
///
/// Widget nào đặt `textStyle`/`labelStyle`/`titleTextStyle` riêng thì style đó
/// THAY theme chứ không gộp, nên mất family → engine CanvasKit dùng 'Roboto',
/// không có kana, rồi tải Noto Sans/Noto Sans SC từ fonts.gstatic.com lúc chạy
/// (đã gặp: nút, tab, tiêu đề). Test này bắt đúng lỗi đó ở mức widget.
void main() {
  late Vocabulary vocab;
  late KanjiIndex kanji;

  setUpAll(() {
    vocab = Vocabulary.fromJson(
      jsonDecode(File('assets/vocabulary.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    kanji = KanjiIndex.build(
      KanjiSet.fromJson(
        jsonDecode(File('assets/kanji.json').readAsStringSync())
            as Map<String, dynamic>,
      ),
      vocab,
    );
  });

  /// Các chuỗi đang vẽ bằng font KHÔNG phải của app.
  List<String> offenders(WidgetTester tester) {
    final bad = <String>[];
    for (final w in tester.widgetList<RichText>(
      find.byType(RichText, skipOffstage: false),
    )) {
      final style = w.text.style;
      final family = style?.fontFamily;
      final ok =
          family == 'MaterialIcons' ||
          family == 'CupertinoIcons' ||
          (family == bundledFontFamily &&
              (style?.fontFamilyFallback ?? const []).contains('NotoSansJP'));
      if (!ok) bad.add('[$family] ${w.text.toPlainText().split('\n').first}');
    }
    return bad;
  }

  void useIPhoneFrame(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('theme: AppBar, nút, thanh đáy và SnackBar giữ font app', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Builder(
          builder: (c) {
            ctx = c;
            return Scaffold(
              appBar: AppBar(title: const Text('Tiêu đề')),
              body: FilledButton(onPressed: () {}, child: const Text('Nút')),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'A'),
                  BottomNavigationBarItem(icon: Icon(Icons.star), label: 'B'),
                ],
              ),
            );
          },
        ),
      ),
    );
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(const SnackBar(content: Text('Thông báo ひらがな')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(offenders(tester), isEmpty);
  });

  testWidgets('các tab chính và bộ chọn bài giữ font app', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(
      AppScope(
        vocabulary: vocab,
        kanji: kanji,
        kanjiWords: loadKanjiWordsFixture(),
        grammar: loadGrammarFixture(),
        progress: ProgressStore.inMemory(),
        settings: SettingsStore.inMemory(),
        speech: SpeechService(),
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: const RootTabs(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // IndexedStack dựng đủ năm tab, kể cả tab đang ẩn (skipOffstage: false).
    expect(offenders(tester), isEmpty);

    await tester.tap(find.text('Luyện tập').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    expect(offenders(tester), isEmpty);
  });
}
