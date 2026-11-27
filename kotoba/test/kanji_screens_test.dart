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
import 'package:mnn_flashcard/ui/kanji_quiz_parts.dart';
import 'package:mnn_flashcard/ui/kanji_tabs.dart';
import 'package:mnn_flashcard/ui/kanji_word_row.dart';
import 'package:mnn_flashcard/ui/root_tabs.dart';

import 'support/asset_fixtures.dart';

/// Tab Kanji sau khi dựng lại: Từ vựng · Kiểm tra.
///
/// Bỏ hai màn cũ — 181 mảnh cấu tạo và 364 chữ đơn — vì chúng bày chữ ĐỨNG
/// TRƠ, trong khi đề thi luôn hỏi kanji TRONG MỘT TỪ. Bộ thủ và chi tiết chữ
/// vẫn tới được: bấm vào một chữ bất kỳ trong từ.
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

  Widget wrap(Widget child, {double scale = 1.0, ProgressStore? progress}) =>
      AppScope(
        vocabulary: vocab,
        kanji: kanji,
        kanjiWords: loadKanjiWordsFixture(),
        grammar: loadGrammarFixture(),
        progress: progress ?? ProgressStore.inMemory(),
        settings: SettingsStore.inMemory(),
        speech: SpeechService(),
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: child,
          ),
        ),
      );

  testWidgets('Kanji đứng thứ ba, Ngữ pháp thứ tư, Cài đặt cuối', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const RootTabs()));
    await tester.pumpAndSettle();
    final bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bar.items.map((i) => i.label), [
      'Trang chủ',
      'Luyện tập',
      'Kanji',
      'Ngữ pháp',
      'Cài đặt',
    ]);
    expect(RootTabs.tabKanji, 2);
    expect(RootTabs.tabGrammar, 3);
    // Cài đặt LUÔN cuối. Chèn tab mới thì chèn trước nó, không đẩy nó lên.
    expect(RootTabs.tabSettings, 4);
  });

  testWidgets('tab Kanji còn đúng hai mục con', (tester) async {
    await tester.pumpWidget(wrap(const KanjiTabs()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(Tab, 'Từ vựng'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Kiểm tra'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Thành phần'), findsNothing);
    expect(find.widgetWithText(Tab, 'Chữ Hán'), findsNothing);
  });

  testWidgets('thanh tab con vẫn cuộn ngang được', (tester) async {
    await tester.pumpWidget(wrap(const KanjiTabs()));
    await tester.pumpAndSettle();
    expect(tester.widget<TabBar>(find.byType(TabBar)).isScrollable, isTrue);
  });

  group('Từ vựng', () {
    testWidgets('hiện đủ 448 từ, kèm cách đọc, âm Hán-Việt và nghĩa', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final set = loadKanjiWordsFixture();
      expect(find.text('${set.words.length} từ'), findsOneWidget);

      final first = set.words.first;
      expect(find.text(first.kana), findsWidgets);
      expect(find.text(first.meaning), findsWidgets);
      expect(find.text(first.hanViet), findsWidgets);
    });

    testWidgets('giữ ĐÚNG thứ tự PDF, không sắp lại', (tester) async {
      // Thứ tự PDF là theo chủ đề, và chính cách nhóm đó là lý do bỏ chia cấp
      // độ. Sắp lại theo bảng chữ cái là phá mất nó.
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      final ns = tester
          .widgetList<KanjiWordRow>(find.byType(KanjiWordRow))
          .map((r) => r.word.n)
          .toList();
      expect(ns.length, greaterThan(3));
      expect(ns, orderedEquals([...ns]..sort()));
      expect(ns.first, 1);
    });

    testWidgets('tìm theo nghĩa tiếng Việt KHÔNG cần bỏ dấu', (tester) async {
      // Gõ trên bàn phím tiếng Nhật thì không bỏ dấu được; bắt gõ đúng dấu là
      // gần như không tìm nổi.
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'gia dinh');
      await tester.pumpAndSettle();

      expect(find.text('かぞく'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tìm theo cách đọc kana', (tester) async {
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'かぞく');
      await tester.pumpAndSettle();
      expect(find.text('かぞく'), findsWidgets);
    });

    testWidgets('không tìm thấy thì nói rõ, không để trang trắng', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'zzzkhongcogi');
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy từ nào'), findsOneWidget);
    });

    testWidgets('lọc "chỉ từ ghép" bỏ đi từ một chữ', (tester) async {
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final set = loadKanjiWordsFixture();
      final compound = set.words.where((w) => w.isCompound).length;
      expect(find.text('$compound / ${set.words.length} từ'), findsOneWidget);

      for (final r in tester.widgetList<KanjiWordRow>(
        find.byType(KanjiWordRow),
      )) {
        expect(r.word.isCompound, isTrue, reason: r.word.word);
      }
    });

    testWidgets('chỉ một cấp độ thì KHÔNG hiện hàng lọc cấp', (tester) async {
      // Một nút luôn bật thì không phải lựa chọn, chỉ tổ chiếm chỗ. Hôm nào
      // database phân lại cấp thì hàng này tự hiện.
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      expect(loadKanjiWordsFixture().levels, ['N4']);
      expect(find.text('Tất cả'), findsNothing);
      expect(find.text('N4'), findsNothing);
    });

    testWidgets('bấm một chữ trong từ thì mở trang chữ đó', (tester) async {
      // Đây là thứ thay cho tab duyệt 364 chữ đã bỏ. Hỏng cái này là mất
      // đường tới âm on/kun, số nét và mảnh cấu tạo.
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('家').first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('nét'), findsWidgets);
    });

    testWidgets(
      'bấm sao thì ghi vào Cần học lại, khoá riêng không đụng Minna',
      (tester) async {
        final progress = ProgressStore.inMemory();
        await tester.pumpWidget(wrap(const KanjiTabs(), progress: progress));
        await tester.pumpAndSettle();

        expect(progress.starredCount, 0);
        await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
        await tester.pumpAndSettle();

        expect(progress.starredCount, 1);
        expect(progress.starredIds.first, startsWith('kw'));
      },
    );
  });

  group('Kiểm tra', () {
    Future<void> openQuiz(WidgetTester tester, {double scale = 1.0}) async {
      await tester.pumpWidget(wrap(const KanjiTabs(), scale: scale));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, 'Kiểm tra'));
      await tester.pumpAndSettle();
    }

    testWidgets('màn chuẩn bị nói rõ hai dạng đề và số từ ra được', (
      tester,
    ) async {
      await openQuiz(tester);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('luôn hỏi TRONG MỘT TỪ'), findsOneWidget);
      expect(find.textContaining('từ ra đề được'), findsOneWidget);
      expect(find.text('Bắt đầu · 10 câu'), findsOneWidget);
    });

    testWidgets('bật "chỉ từ ghép" thì số từ ra đề GIẢM', (tester) async {
      await openQuiz(tester);
      final set = loadKanjiWordsFixture();
      final all = set.words.where((w) => w.hasKanji).length;
      final compound = set.words.where((w) => w.isCompound).length;
      expect(
        find.text('$all từ ra đề được trong phạm vi này.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(compound, lessThan(all));
      expect(
        find.text('$compound từ ra đề được trong phạm vi này.'),
        findsOneWidget,
      );
    });

    testWidgets('bấm Bắt đầu thì vào phiên, có nút bỏ qua', (tester) async {
      await openQuiz(tester);
      await tester.tap(find.text('Bắt đầu · 10 câu'));
      await tester.pumpAndSettle();

      expect(find.text('0 / 10'), findsOneWidget);
      // Bốn phương án là từ đầy đủ nên dài hơn hẳn đề kanji đơn — nút bỏ qua
      // rơi xuống dưới tầm nhìn, ListView chưa dựng tới. Cuộn tới như người
      // dùng thật, và đó cũng là bài kiểm rằng nó VẪN CHẠM ĐƯỢC.
      // Chỉ đích danh ListView của phiên làm bài. TabBarView giữ cả tab Từ
      // vựng sống nên trong cây có nhiều Scrollable; không chỉ rõ thì
      // scrollUntilVisible không biết cuộn cái nào.
      await tester.scrollUntilVisible(
        find.text('Bỏ qua câu này'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(KanjiQuizRunner),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Bỏ qua câu này'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('thoát giữa chừng về lại màn chuẩn bị', (tester) async {
      await openQuiz(tester);
      await tester.tap(find.text('Bắt đầu · 10 câu'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Bắt đầu · 10 câu'), findsOneWidget);
    });
  });

  group('cỡ chữ lớn trên máy nhỏ', () {
    for (final scale in [1.35, 2.0]) {
      testWidgets('hai mục con dựng được ở chữ ×$scale', (tester) async {
        tester.view.physicalSize = const Size(1125, 2001); // iPhone SE
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(wrap(const KanjiTabs(), scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.widgetWithText(Tab, 'Kiểm tra'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('MẶT CHỮ trong từ KHÔNG phóng theo cỡ chữ hệ thống', (
      tester,
    ) async {
      // Mặt chữ là hình, không phải chữ đọc. Cho nó phóng ×2.0 thì nó đội cả
      // dòng lên và đẩy phần kana ra ngoài.
      await tester.pumpWidget(wrap(const KanjiTabs()));
      await tester.pumpAndSettle();
      final small = tester.getSize(find.text('家').first);

      await tester.pumpWidget(wrap(const KanjiTabs(), scale: 2.0));
      await tester.pumpAndSettle();
      final big = tester.getSize(find.text('家').first);

      expect(big.height, closeTo(small.height, 0.5));
      expect(big.width, closeTo(small.width, 0.5));
    });
  });
}
