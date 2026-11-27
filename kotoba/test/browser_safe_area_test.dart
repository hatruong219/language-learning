import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/browser_safe_area.dart';

// Thanh vuốt Home của iPhone: env(safe-area-inset-bottom) = 34px.
const _iphoneHome = EdgeInsets.only(bottom: 34);

Widget _app(EdgeInsets Function() read, {EdgeInsets? flutterPadding}) {
  Widget app = MaterialApp(
    builder: (context, child) => BrowserSafeArea(read: read, child: child!),
    home: Scaffold(
      body: const SizedBox.expand(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'A'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'B'),
        ],
      ),
    ),
  );
  if (flutterPadding != null) {
    app = MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        padding: flutterPadding,
        viewPadding: flutterPadding,
      ),
      child: app,
    );
  }
  return app;
}

void main() {
  testWidgets('browser inset reaches MediaQuery and lifts the tab bar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(() => EdgeInsets.zero));
    final barFlat = tester.getSize(find.byType(BottomNavigationBar)).height;

    // Dựng lại từ đầu: inset được đọc khi widget khởi tạo.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(() => _iphoneHome));
    final barSafe = tester.getSize(find.byType(BottomNavigationBar)).height;
    expect(barSafe - barFlat, 34, reason: 'tab bar must grow by the inset');
  });

  testWidgets('takes the larger value when Flutter already reports one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(() => _iphoneHome,
          flutterPadding: const EdgeInsets.only(bottom: 40)),
    );
    final ctx = tester.element(find.byType(BottomNavigationBar));
    expect(MediaQuery.viewPaddingOf(ctx).bottom, 40);
  });

  testWidgets('re-reads the inset when window metrics change', (
    tester,
  ) async {
    var current = EdgeInsets.zero;
    await tester.pumpWidget(_app(() => current));
    final ctx = tester.element(find.byType(BottomNavigationBar));
    expect(MediaQuery.viewPaddingOf(ctx).bottom, 0);

    current = _iphoneHome;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();
    final ctx2 = tester.element(find.byType(BottomNavigationBar));
    expect(MediaQuery.viewPaddingOf(ctx2).bottom, 34);
  });
}
