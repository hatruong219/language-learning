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
import 'package:mnn_flashcard/ui/stats_screen.dart';

import 'support/asset_fixtures.dart';

/// Màn Thống kê.
void main() {
  late Vocabulary vocab;
  late KanjiIndex kanji;
  late List<Word> words;

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
    words = vocab.byLessons({1}).take(5).toList();
  });

  ProgressStore withRecords(Map<int, (int, int)> spec) {
    final p = ProgressStore.inMemory();
    for (final e in spec.entries) {
      final id = words[e.key].id;
      for (var i = 0; i < e.value.$1; i++) {
        p.record(id, correct: true);
      }
      for (var i = 0; i < e.value.$2; i++) {
        p.record(id, correct: false);
      }
    }
    return p;
  }

  Widget wrap(ProgressStore progress, {double scale = 1.0}) => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: progress,
    settings: SettingsStore.inMemory(),
    speech: SpeechService(),
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: const StatsScreen(),
      ),
    ),
  );

  testWidgets('chưa kiểm từ nào thì mời đi làm bài, không hiện bảng rỗng', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ProgressStore.inMemory()));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có số liệu'), findsOneWidget);
    expect(find.textContaining('Luyện tập'), findsOneWidget);
  });

  testWidgets('hiện tỉ lệ chung và ba con số tổng quan', (tester) async {
    // 8 đúng / 14 lượt = 57%.
    await tester.pumpWidget(
      wrap(withRecords({0: (3, 2), 1: (5, 0), 2: (0, 4)})),
    );
    await tester.pumpAndSettle();

    expect(find.text('57%'), findsOneWidget);
    expect(find.text('đúng trên 14 lượt'), findsOneWidget);
    expect(find.text('Từ đã kiểm'), findsOneWidget);
    expect(find.text('Còn sai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mỗi dòng nói cả số LƯỢT lẫn số SAI', (tester) async {
    // Chỉ nói tỉ lệ thì sai 1/1 lượt trông như thảm hoạ, mà thật ra mới gặp
    // đúng một lần.
    await tester.pumpWidget(wrap(withRecords({0: (3, 2)})));
    await tester.pumpAndSettle();

    expect(find.text('5 lượt'), findsOneWidget);
    expect(find.text('sai 2'), findsOneWidget);
    expect(find.text('60%'), findsWidgets);
  });

  testWidgets('từ chưa sai lần nào được ghi rõ, không để trống', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(withRecords({0: (4, 0)})));
    await tester.pumpAndSettle();
    expect(find.text('chưa sai'), findsOneWidget);
  });

  testWidgets('sai nhiều nhất nằm trên đầu danh sách', (tester) async {
    await tester.pumpWidget(wrap(withRecords({0: (9, 1), 1: (0, 6)})));
    await tester.pumpAndSettle();

    expect(find.text('sai 6'), findsOneWidget);
    final wrong6 = tester.getTopLeft(find.text('sai 6')).dy;
    final wrong1 = tester.getTopLeft(find.text('sai 1')).dy;
    expect(wrong6, lessThan(wrong1), reason: 'sai 6 phải nằm trên sai 1');
  });

  testWidgets('lọc "chỉ từ còn sai" bỏ đi những từ chưa sai', (tester) async {
    await tester.pumpWidget(wrap(withRecords({0: (3, 2), 1: (5, 0)})));
    await tester.pumpAndSettle();
    expect(find.text('2 từ'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('1 từ'), findsOneWidget);
    expect(find.text('chưa sai'), findsNothing);
  });

  testWidgets('đổi cách sắp xếp thì danh sách xếp lại', (tester) async {
    await tester.pumpWidget(wrap(withRecords({0: (9, 1), 1: (0, 6)})));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kiểm nhiều nhất'));
    await tester.pumpAndSettle();

    // 10 lượt phải lên trước 6 lượt.
    final ten = tester.getTopLeft(find.text('10 lượt')).dy;
    final six = tester.getTopLeft(find.text('6 lượt')).dy;
    expect(ten, lessThan(six));
  });

  testWidgets('bấm sao ngay trên màn này thì dòng đó đổi theo', (tester) async {
    final p = withRecords({0: (1, 3)});
    await tester.pumpWidget(wrap(p));
    await tester.pumpAndSettle();

    expect(p.isStarred(words[0].id), isFalse);
    await tester.tap(find.byIcon(Icons.star_outline_rounded));
    await tester.pumpAndSettle();

    expect(p.isStarred(words[0].id), isTrue);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
  });

  for (final scale in [1.35, 2.0]) {
    testWidgets('dựng được ở iPhone SE, chữ ×$scale', (tester) async {
      tester.view.physicalSize = const Size(1125, 2001);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrap(withRecords({0: (3, 2), 1: (5, 0), 2: (0, 4)}), scale: scale),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
