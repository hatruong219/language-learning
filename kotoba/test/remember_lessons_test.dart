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

import 'support/asset_fixtures.dart';
import 'package:mnn_flashcard/ui/quiz_screen.dart';

/// Mở Luyện tập lên phải vào thẳng bộ bài lần trước, không bắt chọn lại.
/// Thao tác chọn bài lặp lại mỗi ngày nên bắt làm lại là phiền thật.
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

  Widget wrap(SettingsStore settings) => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: ProgressStore.inMemory(),
    settings: settings,
    speech: SpeechService(),
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      home: const QuizScreen(),
    ),
  );

  testWidgets('chưa từng chọn bài thì hiện màn mời chọn', (tester) async {
    await tester.pumpWidget(wrap(SettingsStore.inMemory()));
    await tester.pumpAndSettle();
    expect(find.text('Chọn bài để bắt đầu'), findsOneWidget);
  });

  testWidgets('có bài đã lưu thì vào thẳng danh sách từ', (tester) async {
    final settings = SettingsStore.inMemory()..lastLessons = {1, 3};
    await tester.pumpWidget(wrap(settings));
    await tester.pumpAndSettle();

    expect(
      find.text('Chọn bài để bắt đầu'),
      findsNothing,
      reason: 'không được bắt chọn lại',
    );
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('Bài 1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bài đã lưu không còn hợp lệ thì quay về màn mời chọn', (
    tester,
  ) async {
    final settings = SettingsStore.inMemory()..lastLessons = {999};
    await tester.pumpWidget(wrap(settings));
    await tester.pumpAndSettle();
    expect(find.text('Chọn bài để bắt đầu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('ghi rồi đọc lại bộ bài giữ nguyên nội dung', () {
    final s = SettingsStore.inMemory()..lastLessons = {5, 2, 9};
    expect(s.lastLessons, {2, 5, 9});
    s.lastLessons = {};
    expect(s.lastLessons, isEmpty);
  });

  test('ghi lại đúng bộ cũ thì không coi là thay đổi', () {
    final s = SettingsStore.inMemory()..lastLessons = {1, 2};
    var notified = 0;
    s.addListener(() => notified++);
    s.lastLessons = {1, 2};
    expect(notified, 0, reason: 'nội dung y hệt, không cần báo đổi');
    s.lastLessons = {1, 2, 3};
    expect(notified, 1);
  });
}
