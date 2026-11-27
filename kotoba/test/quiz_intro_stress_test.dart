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
import 'package:mnn_flashcard/ui/quiz_verdict_panel.dart';
import 'package:mnn_flashcard/ui/quiz_write_panel.dart';
import 'package:mnn_flashcard/ui/kanji_tabs.dart';
import 'package:mnn_flashcard/ui/kanji_word_row.dart';
import 'package:mnn_flashcard/ui/root_tabs.dart';
import 'package:mnn_flashcard/ui/summary_screen.dart';
import 'package:mnn_flashcard/quiz/quiz_session.dart';
import 'package:mnn_flashcard/ui/word_row.dart';

/// Ép các điều kiện của máy thật mà khung test mặc định không có:
/// cỡ chữ hệ thống phóng to, màn hình nhỏ, chế độ tối.
///
/// Ban đầu file này chỉ phủ màn mời chọn bài của Luyện tập. Mở rộng ra các
/// màn còn lại — trang chủ, bộ chọn bài, danh sách phiên học, tấm gõ/tấm chấm
/// điểm, cài đặt — vì cùng một họ lỗi (Column không cuộn được / kích thước cố
/// định) có thể nằm ở bất cứ đâu, không riêng màn intro.
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
    ProgressStore? progress,
    SettingsStore? settings,
  }) {
    return AppScope(
      vocabulary: vocab,
      kanji: kanji,
      kanjiWords: loadKanjiWordsFixture(),
      grammar: loadGrammarFixture(),
      progress: progress ?? ProgressStore.inMemory(),
      settings: settings ?? SettingsStore.inMemory(),
      speech: SpeechService(),
      child: MaterialApp(
        theme: buildTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: child,
        ),
      ),
    );
  }

  final sizes = {
    'iPhone SE 375×667': const Size(1125, 2001),
    'iPhone 15  393×852': const Size(1179, 2556),
    'iPhone Max 430×932': const Size(1290, 2796),
  };
  const scales = [1.0, 1.35, 2.0];
  const brightnesses = [Brightness.light, Brightness.dark];

  /// Chạy `body` qua đủ 3 cỡ máy × 3 cỡ chữ × 2 chế độ sáng/tối — 18 tổ hợp
  /// cho mỗi màn. Gộp thành một hàm để không chép lại vòng lặp ba tầng ở mỗi
  /// màn hình mới thêm vào.
  void stress(
    String label,
    Future<void> Function(WidgetTester tester, Brightness b, double scale) body,
  ) {
    for (final entry in sizes.entries) {
      for (final scale in scales) {
        for (final b in brightnesses) {
          testWidgets('$label · ${entry.key} · chữ ×$scale · ${b.name}', (
            tester,
          ) async {
            tester.view.physicalSize = entry.value;
            tester.view.devicePixelRatio = 3.0;
            addTearDown(tester.view.reset);
            await body(tester, b, scale);
          });
        }
      }
    }
  }

  /// Từ tab Luyện tập: mở bộ chọn bài, chọn Bài 1, bắt đầu phiên.
  ///
  /// Ở cỡ chữ ×2.0 trên máy nhỏ, nút "Chọn bài" nằm ngoài khung nhìn ban đầu
  /// — màn mời chọn bài cuộn được (đúng như thiết kế), nhưng phải cuộn tới
  /// mới chạm được nút. `ensureVisible` mô phỏng đúng thao tác đó thay vì
  /// chạm mù vào toạ độ hiện tại.
  Future<void> startQuizSession(WidgetTester tester) async {
    await tester.tap(find.text('Luyện tập').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bài 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Luyện tập 1 bài'));
    await tester.pumpAndSettle();
  }

  // ---- Luyện tập: màn mời chọn bài ----
  stress('Luyện tập · màn mời chọn bài', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Luyện tập').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Chọn bài để bắt đầu'), findsOneWidget);
  });

  // ---- Trang chủ: trạng thái trống ----
  stress('Trang chủ · trống', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Chưa có từ nào ở đây'), findsOneWidget);
  });

  // ---- Trang chủ: danh sách có từ — chạm tới dòng cao cố định 72dp ----
  stress('Trang chủ · danh sách có từ', (tester, b, scale) async {
    final progress = ProgressStore.inMemory();
    progress.starAll(vocab.words.take(12).map((w) => w.id));
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale, progress: progress),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(WordRow), findsWidgets);
  });

  // ---- Trang chủ: kết quả tìm kiếm ----
  stress('Trang chủ · tìm kiếm', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'học');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('kết quả'), findsOneWidget);
  });

  // ---- Bộ chọn bài (bottom sheet dùng chung Trang chủ / Luyện tập) ----
  stress('Bộ chọn bài', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Luyện tập').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Chọn bài'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('CHỌN BÀI ĐỂ LUYỆN TẬP'), findsOneWidget);
    expect(find.text('Bài 1'), findsOneWidget);
  });

  // ---- Luyện tập: danh sách trong phiên (dòng cao cố định + itemExtent) ----
  stress('Luyện tập · danh sách phiên', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();
    await startQuizSession(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(WordRow), findsWidgets);
  });

  // ---- Tấm nền trượt lên: chế độ Viết ----
  stress('Luyện tập · tấm gõ (viết)', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();
    await startQuizSession(tester);

    await tester.tap(find.byType(WordRow).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(WritePanel), findsOneWidget);
  });

  // ---- Tấm nền trượt lên: chấm điểm (verdict) ----
  stress('Luyện tập · tấm chấm điểm', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();
    await startQuizSession(tester);

    await tester.tap(find.byType(WordRow).first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byType(WritePanel),
        matching: find.byType(TextField),
      ),
      'traLoiThu',
    );
    await tester.tap(find.text('Trả lời'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(QuizVerdictPanel), findsOneWidget);
  });

  // ---- Cài đặt ----
  stress('Cài đặt', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cài đặt').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Nhóm đầu tiên phải thấy ngay, không phải cuộn.
    expect(find.text('HỌC TẬP'), findsOneWidget);

    // Mọi nhóm còn lại đều phải CUỘN TỚI. Trước đây 'DỮ LIỆU' được kiểm không
    // cuộn vì nó tình cờ nằm trong khung nhìn đầu; thêm một nhóm phía trên là
    // nó rơi ra ngoài và test đỏ, dù màn hình chẳng có gì sai. Kiểm theo kiểu
    // cuộn tới thì thứ tự nhóm đổi vẫn không làm test giả vỡ.
    for (final group in ['DỮ LIỆU', 'CHẤM ĐIỂM', 'CÁCH NHẬP', 'SAO LƯU']) {
      await tester.scrollUntilVisible(
        find.text(group),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(group), findsOneWidget, reason: 'thiếu nhóm $group');
    }
  });

  // ---- Tổng kết: trạng thái thoát giữa chừng ----
  //
  // Đây là trạng thái xấu nhất của màn tổng kết: cả BỐN nhãn cùng hiện
  // (đúng · sai · bỏ qua · chưa làm) nên hàng chú giải dài nhất có thể. Trước
  // đây nó là Row và tràn 276px ở cỡ chữ ×2.0 khi mới có ba nhãn; giờ thêm
  // nhãn thứ tư nên phải khoá lại bằng test, không tin vào Wrap là đủ.
  //
  // Phiên 50 từ, làm 3, thoát — đúng cảnh người dùng gặp bug: 47 từ còn lại
  // phải hiện ở nhãn "chưa làm" chứ không được biến mất.
  stress('Tổng kết · thoát giữa chừng, đủ 4 nhãn', (tester, b, scale) async {
    final session = QuizSession(
      words: vocab.byLessons({1}).take(50).toList(),
      lessons: {1},
      shuffle: false,
    );
    session.submit(correct: true, submitted: 'a');
    session.advance();
    session.submit(correct: false, submitted: 'sai');
    session.advance();
    session.skip();
    session.advance();

    await tester.pumpWidget(
      wrap(
        SummaryScreen(session: session, onReviewWrong: () {}),
        brightness: b,
        scale: scale,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('chưa làm'), findsOneWidget);
    expect(
      session.correctCount +
          session.wrongCount +
          session.skippedCount +
          session.pendingCount,
      session.total,
    );
  });

  // ---- Kanji · màn Thành phần ----
  //
  // Đây là màn có nhiều thứ đá nhau nhất ở cỡ chữ lớn: mặt chữ khoá không
  // scale, nhưng nhãn và số thì vẫn scale, mà hàng lại có ba cột. Bản đầu em
  // đặt cứng chiều cao hàng 74px và test này bắt ngay — cột giữa tràn 16px,
  // cột phải tràn 42px ở ×2.0.
  // ---- Kanji · danh sách 448 từ ----
  //
  // Mỗi dòng có mặt chữ KHOÁ không scale nằm cạnh kana và nghĩa CÓ scale. Chỗ
  // khoá cạnh chỗ scale là chỗ dễ đá nhau nhất khi cỡ chữ hệ thống phóng to.
  stress('Kanji · Từ vựng', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const KanjiTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(KanjiWordRow), findsWidgets);
  });

  // ---- Kanji · năm tab dưới đáy ----
  //
  // Năm tab thì mỗi nhãn chỉ còn một phần năm bề rộng. Nhãn tab đã kẹp ở ×1.3
  // nên không được tràn dù hệ thống đặt ×2.0.
  stress('Kanji · thanh năm tab', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const RootTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kanji').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Từ vựng'), findsWidgets);
  });

  stress('Kanji · Kiểm tra', (tester, b, scale) async {
    await tester.pumpWidget(
      wrap(const KanjiTabs(), brightness: b, scale: scale),
    );
    await tester.pumpAndSettle();

    DefaultTabController.of(
      tester.element(find.byType(TabBarView)),
    ).animateTo(1);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hai dạng câu hỏi của đề thi'), findsOneWidget);

    // Vào hẳn phiên làm bài — đây mới là chỗ chuỗi đề to đá với phương án.
    //
    // Nút "Bắt đầu" nằm cuối ListView của màn chuẩn bị. Trên iPhone SE nó ở
    // ngoài viewport nên ListView CHƯA DỰNG nó — phải cuộn cho tới khi xuất
    // hiện, ensureVisible không dùng được vì nó đòi widget tồn tại trước.
    await tester.scrollUntilVisible(
      find.text('Bắt đầu · 10 câu'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(TabBarView),
            matching: find.byType(Scrollable),
          )
          .last,
      maxScrolls: 12,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bắt đầu · 10 câu'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
