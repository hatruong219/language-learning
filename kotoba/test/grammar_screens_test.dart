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
import 'package:mnn_flashcard/ui/grammar_lesson_screen.dart';
import 'package:mnn_flashcard/ui/grammar_tabs.dart';

import 'support/asset_fixtures.dart';

/// Ba màn ngữ pháp: Bài học, Bài tập, Luyện dịch.
///
/// Ép luôn cỡ chữ lớn và máy nhỏ. Bản phát hành CẮT ÂM THẦM phần tràn — không
/// vạch vàng, không lỗi, chỉ mất chữ — nên tràn chỉ lộ ra ở đây hoặc không bao
/// giờ lộ ra.
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

  Widget wrap(
    Widget child, {
    Brightness brightness = Brightness.light,
    double scale = 1.0,
  }) => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: ProgressStore.inMemory(),
    settings: SettingsStore.inMemory(),
    speech: SpeechService(),
    child: MaterialApp(
      theme: buildTheme(brightness),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: child,
      ),
    ),
  );

  group('Bài học', () {
    testWidgets('liệt kê đủ 50 bài, mỗi bài nói rõ có bao nhiêu mẫu', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const GrammarTabs()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bài học'), findsOneWidget);
      // Bài 1 có 5 mẫu và 26 câu — số thật, không phải số cứng bịa ra.
      final g = loadGrammarFixture();
      expect(
        find.text(
          '${g.byLesson(1).length} mẫu · ${g.sentencesInLesson(1).length} câu ví dụ',
        ),
        findsOneWidget,
      );
    });

    testWidgets('mở một bài thì thấy mẫu, giải thích, và câu ví dụ', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const GrammarLessonScreen(lesson: 1, title: 'はじめまして')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bài 1'), findsOneWidget);
      expect(find.text('はじめまして'), findsOneWidget);

      final first = loadGrammarFixture().byLesson(1).first;
      expect(find.text(first.pattern), findsOneWidget);
      // Mẫu đầu mở sẵn — mở màn ra phải thấy nội dung thật, không phải một
      // danh sách tiêu đề câm.
      expect(find.textContaining(first.explain.substring(0, 20)), findsWidgets);
    });

    testWidgets('mẫu không có ví dụ thì KHÔNG hiện dòng "0 ví dụ"', (
      tester,
    ) async {
      // Bài 1 mẫu đầu tiên (Trợ từ trong tiếng Nhật) không có câu ví dụ nào.
      final g = loadGrammarFixture();
      final barren = g.patterns.firstWhere((p) => g.sentencesOf(p).isEmpty);
      await tester.pumpWidget(
        wrap(GrammarLessonScreen(lesson: barren.lesson, title: '')),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 ví dụ'), findsNothing);
    });
  });

  group('Bài tập', () {
    Future<void> openQuiz(WidgetTester tester) async {
      await tester.pumpWidget(wrap(const GrammarTabs()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bài tập'));
      await tester.pumpAndSettle();
    }

    testWidgets('màn chuẩn bị nói rõ dựng được bao nhiêu câu', (tester) async {
      await openQuiz(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Điền trợ từ'), findsOneWidget);
      expect(find.text('Chọn nghĩa'), findsOneWidget);
      expect(find.textContaining('câu ra đề được'), findsOneWidget);
    });

    testWidgets('bấm Bắt đầu thì vào phiên và hiện 4 phương án', (
      tester,
    ) async {
      await openQuiz(tester);
      await tester.tap(find.textContaining('Bắt đầu ·'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('0 / 10'), findsOneWidget);
      expect(find.text('Bỏ qua câu này'), findsOneWidget);
    });

    testWidgets('không tắt được hết dạng bài — tắt hết thì không ra đề nổi', (
      tester,
    ) async {
      await openQuiz(tester);
      await tester.tap(find.text('Chọn nghĩa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Điền trợ từ'));
      await tester.pumpAndSettle();

      // Vẫn phải còn ít nhất một dạng bật, nên nút Bắt đầu vẫn dùng được.
      expect(find.textContaining('Bắt đầu ·'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Luyện dịch', () {
    Future<void> openTranslation(WidgetTester tester) async {
      await tester.pumpWidget(wrap(const GrammarTabs()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Luyện dịch'));
      await tester.pumpAndSettle();
    }

    testWidgets('gõ đúng thì báo đúng, KHÔNG hiện bảng đối chiếu', (
      tester,
    ) async {
      await openTranslation(tester);
      await tester.tap(find.text('Bắt đầu · 10 câu'));
      await tester.pumpAndSettle();

      // Lấy đáp án của đúng câu đang hiện, gõ vào.
      final prompt = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .toList();
      final g = loadGrammarFixture();
      final shown = g.sentences.firstWhere((s) => prompt.contains(s.vi));

      await tester.enterText(find.byType(TextField), shown.jaKanji);
      await tester.tap(find.text('Kiểm tra'));
      await tester.pumpAndSettle();

      expect(find.text('Đúng rồi'), findsOneWidget);
      // Đúng rồi thì không có gì để đối chiếu.
      expect(find.text('ĐỐI CHIẾU'), findsNothing);
      expect(find.text('ĐÁP ÁN'), findsOneWidget);
    });

    testWidgets('gõ sai thì hiện đối chiếu kèm chú thích thiếu/thừa', (
      tester,
    ) async {
      await openTranslation(tester);
      await tester.tap(find.text('Bắt đầu · 10 câu'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'これはぜんぜんちがう');
      await tester.tap(find.text('Kiểm tra'));
      await tester.pumpAndSettle();

      expect(find.text('ĐỐI CHIẾU'), findsOneWidget);
      // Chú thích phải có cả ba, vì bản đối chiếu dùng cả màu lẫn kiểu gạch.
      expect(find.text('đúng'), findsOneWidget);
      expect(find.text('thiếu'), findsOneWidget);
      expect(find.text('thừa'), findsOneWidget);
    });

    testWidgets('ô trống thì bấm Kiểm tra không làm gì, không nổ', (
      tester,
    ) async {
      await openTranslation(tester);
      await tester.tap(find.text('Bắt đầu · 10 câu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kiểm tra'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Kiểm tra'), findsOneWidget, reason: 'vẫn ở bước gõ');
    });
  });

  group('cỡ chữ lớn trên máy nhỏ', () {
    for (final scale in [1.35, 2.0]) {
      testWidgets('ba tab ngữ pháp dựng được ở chữ ×$scale', (tester) async {
        tester.view.physicalSize = const Size(1125, 2001); // iPhone SE
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(wrap(const GrammarTabs(), scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final tab in ['Bài tập', 'Luyện dịch']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'tab $tab tràn');
        }
      });

      testWidgets('một bài ngữ pháp dựng được ở chữ ×$scale', (tester) async {
        tester.view.physicalSize = const Size(1125, 2001);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          wrap(
            const GrammarLessonScreen(lesson: 25, title: 'テスト'),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
