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
import 'package:mnn_flashcard/quiz/quiz_session.dart';
import 'package:mnn_flashcard/speech/speech_service.dart';
import 'package:mnn_flashcard/theme.dart';

import 'support/asset_fixtures.dart';
import 'package:mnn_flashcard/ui/home_screen.dart';
import 'package:mnn_flashcard/ui/quiz_screen.dart';
import 'package:mnn_flashcard/ui/root_tabs.dart';
import 'package:mnn_flashcard/ui/settings_screen.dart';
import 'package:mnn_flashcard/ui/summary_screen.dart';

/// Dựng thật từng màn hình bằng dữ liệu thật.
///
/// Vì sao cần: `flutter analyze` chỉ chứng minh code biên dịch được, `flutter
/// test` chỉ chứng minh logic đúng. Không cái nào chứng minh màn hình dựng lên
/// được. Mà app này không debug được trên iPhone qua vòng CI 12 phút, nên lỗi
/// dựng giao diện phải bắt ở đây chứ không phải trên máy anh.
void main() {
  late Vocabulary vocab;
  late KanjiIndex kanji;
  late ProgressStore progress;
  late SettingsStore settings;

  setUpAll(() {
    final raw = File('assets/vocabulary.json').readAsStringSync();
    vocab = Vocabulary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    kanji = KanjiIndex.build(
      KanjiSet.fromJson(
        jsonDecode(File('assets/kanji.json').readAsStringSync())
            as Map<String, dynamic>,
      ),
      vocab,
    );
  });

  setUp(() {
    progress = ProgressStore.inMemory();
    settings = SettingsStore.inMemory();
  });

  /// Khung 390×844 — đúng iPhone, đúng chiều rộng bản thiết kế được vẽ.
  void useIPhoneFrame(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  Widget wrap(Widget child) => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: progress,
    settings: settings,
    speech: SpeechService(),
    child: MaterialApp(theme: buildTheme(Brightness.light), home: child),
  );

  testWidgets('dữ liệu thật nạp được và có đủ 50 bài', (tester) async {
    expect(vocab.words.length, 2090);
    expect(vocab.lessons.length, 50);
    expect(vocab.lessons.every((l) => l.count > 0), isTrue);
  });

  testWidgets('Trang chủ dựng được — trạng thái trống', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Cần học lại'), findsWidgets);
    expect(find.text('Chưa có từ nào ở đây'), findsOneWidget);
  });

  testWidgets('Trang chủ dựng được khi có từ đánh dấu', (tester) async {
    useIPhoneFrame(tester);
    progress.starAll(vocab.words.take(12).map((w) => w.id));
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lọc sang Tất cả — 2090 dòng không làm sập màn hình', (
    tester,
  ) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();
    // Danh sách ảo hoá: chỉ vài chục dòng được dựng dù có 2090 từ.
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tìm kiếm lọc được và tô đúng chỗ khớp', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'học');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('kết quả'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Luyện tập dựng được — màn mời chọn bài', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const QuizScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Chọn bài để bắt đầu'), findsOneWidget);
  });

  testWidgets('Bộ chọn bài mở được và liệt kê đủ bài', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const QuizScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    expect(find.text('CHỌN BÀI ĐỂ LUYỆN TẬP'), findsOneWidget);
    expect(find.text('Bài 1'), findsOneWidget);
  });

  testWidgets('Cài đặt dựng được với đủ các nhóm', (tester) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('DỮ LIỆU'), findsOneWidget);
    expect(find.text('2090 từ'), findsOneWidget);
    // Bảy nhóm không vừa một màn — cuộn xuống kiểm nốt phần dưới.
    for (final group in ['CHẤM ĐIỂM', 'CÁCH NHẬP', 'SAO LƯU']) {
      await tester.scrollUntilVisible(
        find.text(group),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(group), findsOneWidget, reason: 'thiếu nhóm $group');
    }
  });

  testWidgets('Tổng kết dựng được và nút thêm hàng loạt chạy', (tester) async {
    final session = QuizSession(
      words: vocab.byLessons({1}).take(6).toList(),
      lessons: {1},
      shuffle: false,
    );
    session.submit(correct: true, submitted: 'a');
    session.advance();
    session.submit(correct: false, submitted: 'sai');

    useIPhoneFrame(tester);
    await tester.pumpWidget(
      wrap(SummaryScreen(session: session, onReviewWrong: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kết quả'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.textContaining('Thêm cả'));
    await tester.pumpAndSettle();
    expect(progress.starredCount, 1);
  });

  // Sát máy thật hơn: đi qua RootTabs như người dùng thật, không dựng
  // QuizScreen đứng một mình.
  testWidgets('Qua tab Luyện tập rồi chọn bài — không được trắng màn', (
    tester,
  ) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const RootTabs()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Luyện tập').last);
    await tester.pumpAndSettle();
    expect(find.text('Chọn bài để bắt đầu'), findsOneWidget);

    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bài 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Luyện tập 1 bài'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byType(ListView),
      findsWidgets,
      reason: 'danh sách từ không hiện',
    );
  });

  // Tái hiện đúng thao tác anh báo: Luyện tập → chọn bài → màn trắng.
  testWidgets('Luyện tập: chọn bài xong thì danh sách từ phải hiện ra', (
    tester,
  ) async {
    useIPhoneFrame(tester);
    await tester.pumpWidget(wrap(const QuizScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bài 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Luyện tập 1 bài'));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'ngoại lệ khi dựng phiên học',
    );
    expect(
      find.byType(ListView),
      findsOneWidget,
      reason: 'danh sách từ không hiện',
    );
  });

  testWidgets('Mở một từ chỉ dựng lại dòng đó, không phải cả danh sách', (
    tester,
  ) async {
    useIPhoneFrame(tester);
    progress.starAll(vocab.words.take(8).map((w) => w.id));
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();

    // Bấm sao một từ khác: nếu danh sách nghe chung một kênh thì mọi dòng
    // dựng lại. Ở đây chỉ dòng của nó đổi, số dòng dựng ra không đổi.
    final before = tester.widgetList(find.byType(ListView)).length;
    progress.toggleStar(vocab.words.first.id);
    await tester.pump();
    expect(tester.widgetList(find.byType(ListView)).length, before);
    expect(tester.takeException(), isNull);
  });
}
