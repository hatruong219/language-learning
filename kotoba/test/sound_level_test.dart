import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/theme.dart';
import 'package:mnn_flashcard/ui/quiz_speak_stages.dart';

/// iOS gửi mức âm thanh về dưới dạng decibel — LUÔN là số âm.
/// Bản trước lấy abs() của nó nên im lặng ra số lớn hơn nói to, cả hai vượt
/// trần, sóng phẳng lì. Bộ kiểm này khoá lại phép quy đổi cho đúng chiều.
void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: buildTheme(Brightness.light),
    home: Scaffold(body: child),
  );

  /// Chiều cao cột sóng cao nhất đang vẽ.
  double tallestBar(WidgetTester tester) {
    final boxes = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .where((w) => w.constraints?.maxWidth == 4)
        .map((w) => w.constraints!.maxHeight);
    return boxes.isEmpty ? 0 : boxes.reduce((a, b) => a > b ? a : b);
  }

  testWidgets('nói to vẽ cột CAO HƠN im lặng', (tester) async {
    await tester.pumpWidget(
      wrap(ListeningStage(levels: const [-55, -52, -58], onStop: () {})),
    );
    await tester.pump();
    final quiet = tallestBar(tester);

    await tester.pumpWidget(
      wrap(ListeningStage(levels: const [-12, -8, -15], onStop: () {})),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final loud = tallestBar(tester);

    expect(
      loud,
      greaterThan(quiet),
      reason: 'nói to (-10dB) phải cao hơn im lặng (-55dB)',
    );
  });

  testWidgets('im lặng không làm cột dính trần', (tester) async {
    await tester.pumpWidget(
      wrap(ListeningStage(levels: const [-60, -58, -62], onStop: () {})),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tallestBar(tester),
      lessThan(10),
      reason: 'im lặng thì cột phải gần như phẳng',
    );
  });

  testWidgets('hiện chữ ngay khi đang nghe', (tester) async {
    await tester.pumpWidget(
      wrap(
        ListeningStage(levels: const [-15], onStop: () {}, partialText: 'がくせい'),
      ),
    );
    await tester.pump();
    expect(
      find.text('がくせい'),
      findsOneWidget,
      reason:
          'không hiện thì nhìn vào chỉ thấy vòng tròn, không biết máy hiểu gì',
    );
  });

  testWidgets('chưa nghe được gì thì nhắc đọc to lên', (tester) async {
    await tester.pumpWidget(
      wrap(ListeningStage(levels: const [-58], onStop: () {})),
    );
    await tester.pump();
    expect(find.text('Đọc to từ này'), findsOneWidget);
    expect(find.textContaining('tự dừng'), findsOneWidget);
  });
}
