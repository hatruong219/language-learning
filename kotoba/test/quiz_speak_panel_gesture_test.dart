import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/app_scope.dart';
import 'package:mnn_flashcard/data/kanji.dart';
import 'package:mnn_flashcard/data/kanji_index.dart';
import 'package:mnn_flashcard/data/progress_store.dart';
import 'package:mnn_flashcard/data/settings_store.dart';
import 'package:mnn_flashcard/data/vocabulary.dart';
import 'package:mnn_flashcard/quiz/quiz_session.dart';
import 'package:mnn_flashcard/speech/mic_recorder.dart';
import 'package:mnn_flashcard/speech/speech_service.dart';
import 'package:mnn_flashcard/theme.dart';
import 'package:mnn_flashcard/ui/quiz_speak_panel.dart';

import 'support/asset_fixtures.dart';

class _FakeMic implements MicRecorder {
  int starts = 0;
  final _ctrl = StreamController<double>.broadcast();
  @override
  Future<void> start() async => starts++;
  @override
  Stream<double> levels(Duration every) => _ctrl.stream;
  @override
  Future<Uint8List?> stop() async => null;
  @override
  Future<void> cancel() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  late Vocabulary vocab;
  late KanjiIndex kanji;
  late _FakeMic mic;

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

  setUp(() {
    mic = _FakeMic();
    QuizSpeakPanelState.resetGestureUnlock();
  });

  Widget panel() => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: ProgressStore.inMemory(),
    settings: SettingsStore.inMemory(),
    speech: SpeechService(recorder: mic),
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: QuizSpeakPanel(
          key: UniqueKey(),
          item: QuizItem(vocab.words.first),
          onSubmit: (_) {},
          onSkip: () {},
          onSwitchToWrite: () {},
        ),
      ),
    ),
  );

  testWidgets('lần ghi đầu chỉ bắt đầu khi bấm, các lần sau tự nghe', (
    tester,
  ) async {
    await tester.pumpWidget(panel());
    await tester.pump();
    expect(mic.starts, 0, reason: 'chưa có cú chạm thì không được mở mic');
    expect(find.byKey(const Key('tap-to-speak')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tap-to-speak')));
    await tester.pump();
    expect(mic.starts, 1);
    expect(find.byKey(const Key('tap-to-speak')), findsNothing);
    expect(find.text('Dừng'), findsOneWidget);

    // Câu hỏi kế tiếp (panel dựng mới): đã mở khoá nên tự nghe.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(panel());
    await tester.pump();
    await tester.pump();
    expect(mic.starts, 2);
    expect(find.byKey(const Key('tap-to-speak')), findsNothing);
  });
}
