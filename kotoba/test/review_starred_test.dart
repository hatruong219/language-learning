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
import 'package:mnn_flashcard/ui/word_row.dart';

/// Ôn lại những từ đã đánh dấu.
///
/// Đây là mắt xích cuối của vòng học: sai → đánh dấu → nằm ở trang chủ → ÔN
/// LẠI. Trước đó đánh dấu xong chỉ xem lại được, không luyện lại được, nên vòng
/// đứt đúng chỗ quan trọng nhất.
void main() {
  group('tra từ theo id', () {
    late Vocabulary v;
    setUpAll(() {
      v = Vocabulary.fromJson(
        jsonDecode(File('assets/vocabulary.json').readAsStringSync())
            as Map<String, dynamic>,
      );
    });

    test('giữ ĐÚNG thứ tự giáo trình, không theo thứ tự id truyền vào', () {
      // Danh sách "cần học lại" phải đọc theo thứ tự bài như mọi danh sách
      // khác, không theo thứ tự người dùng tình cờ bấm sao.
      final picked = [
        v.words[40].id,
        v.words[3].id,
        v.words[900].id,
        v.words[12].id,
      ];
      final got = v.byIds(picked).map((w) => w.id).toList();
      expect(got, [
        v.words[3].id,
        v.words[12].id,
        v.words[40].id,
        v.words[900].id,
      ]);
    });

    test('id không có thật thì bỏ qua, không nổ', () {
      // Bản sao lưu cũ, hoặc khoá của nguồn dữ liệu khác (kw3 của chữ Hán).
      final got = v.byIds(['khong-co-that', v.words[0].id, 'kw3']);
      expect(got.map((w) => w.id), [v.words[0].id]);
    });

    test('rỗng thì trả rỗng', () => expect(v.byIds(const []), isEmpty));
  });

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

  Widget wrap(ProgressStore progress) => AppScope(
    vocabulary: vocab,
    kanji: kanji,
    kanjiWords: loadKanjiWordsFixture(),
    grammar: loadGrammarFixture(),
    progress: progress,
    settings: SettingsStore.inMemory(),
    speech: SpeechService(),
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      home: const QuizScreen(),
    ),
  );

  /// Mở bộ chọn bài từ màn mời chọn.
  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.text('Chọn bài'));
    await tester.pumpAndSettle();
  }

  testWidgets('"Cần học lại" là MỘT LỰA CHỌN trong bộ chọn bài', (
    tester,
  ) async {
    // Không phải nút riêng ở màn mời chọn, cũng không phải chip riêng trong
    // phiên. Đặt nút riêng ở màn mời chọn là sai thật: màn đó chỉ hiện khi CHƯA
    // có phiên nào, chọn bài một lần rồi thì không bao giờ quay lại đó nữa.
    final progress = ProgressStore.inMemory();
    progress.starAll(vocab.byLessons({1}).take(3).map((w) => w.id));

    await tester.pumpWidget(wrap(progress));
    await tester.pumpAndSettle();
    await openPicker(tester);

    expect(find.text('Cần học lại'), findsOneWidget);
    expect(find.text('3 từ'), findsWidgets);
    expect(find.text('Từ đã đánh dấu'), findsOneWidget);
  });

  testWidgets('chưa đánh dấu từ nào thì hàng đó mờ và bấm không ăn', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ProgressStore.inMemory()));
    await tester.pumpAndSettle();
    await openPicker(tester);

    expect(find.text('Cần học lại'), findsOneWidget);
    expect(find.text('Chưa đánh dấu từ nào'), findsOneWidget);

    await tester.tap(find.text('Cần học lại'));
    await tester.pumpAndSettle();
    // Vẫn ở bộ chọn, không vào phiên rỗng.
    expect(find.text('CHỌN BÀI ĐỂ LUYỆN TẬP'), findsOneWidget);
  });

  testWidgets('vào TỪ TRONG PHIÊN vẫn chọn được, không kẹt ở bài cũ', (
    tester,
  ) async {
    // Đây là lỗi thật đã gặp: nút chỉ nằm ở màn mời chọn bài, mà màn đó chỉ
    // hiện khi chưa có phiên nào — chọn Bài 4 rồi thì nút biến mất vĩnh viễn.
    final progress = ProgressStore.inMemory();
    final starred = vocab.byLessons({1}).take(3).toList();
    progress.starAll(starred.map((w) => w.id));

    await tester.pumpWidget(wrap(progress));
    await tester.pumpAndSettle();

    // Vào một phiên bài bình thường trước.
    await openPicker(tester);
    await tester.tap(find.text('Bài 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Luyện tập 1 bài'));
    await tester.pumpAndSettle();

    // Chip bài trong phiên mở lại được bộ chọn.
    await tester.tap(find.textContaining('Bài 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cần học lại'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Bấm vào PHẢI ra DANH SÁCH từ cần ôn kèm nút Bắt đầu — không nhảy thẳng
    // vào câu hỏi. Người học cần nhìn xem mình sắp ôn những gì.
    expect(find.textContaining('Cần học lại'), findsWidgets);
    expect(find.text('0 / 3'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.byType(WordRow), findsNWidgets(3));
    for (final w in starred) {
      expect(find.text(w.meaning), findsWidgets, reason: 'thiếu ${w.id}');
    }
  });

  testWidgets('gỡ hết sao giữa phiên thì phiên vẫn chạy, không rỗng đột ngột', (
    tester,
  ) async {
    // Phiên chụp danh sách từ lúc bắt đầu. Gỡ sao sau đó KHÔNG được làm phiên
    // co lại giữa chừng — đang làm câu 3/5 mà tổng nhảy về 0 thì mất hết điểm.
    final progress = ProgressStore.inMemory();
    final words = vocab.byLessons({1}).take(5).toList();
    progress.starAll(words.map((w) => w.id));

    await tester.pumpWidget(wrap(progress));
    await tester.pumpAndSettle();
    await openPicker(tester);
    await tester.tap(find.text('Cần học lại'));
    await tester.pumpAndSettle();

    for (final w in words) {
      progress.setStarred(w.id, false);
    }
    await tester.pumpAndSettle();

    expect(find.text('0 / 5'), findsOneWidget, reason: 'phiên phải giữ nguyên');
    expect(tester.takeException(), isNull);
  });
}
