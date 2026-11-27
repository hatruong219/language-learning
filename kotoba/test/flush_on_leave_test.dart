import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnn_flashcard/flush_on_leave.dart';

void main() {
  testWidgets('flush ở inactive, hidden, paused và detached', (tester) async {
    var calls = 0;
    final l = flushOnLeave(() => calls++);
    addTearDown(l.dispose);
    final b = tester.binding;

    b.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(calls, 1, reason: 'onInactive');
    b.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(calls, 2, reason: 'onHide');
    b.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(calls, 3, reason: 'onPause');
    b.handleAppLifecycleStateChanged(AppLifecycleState.detached);
    expect(calls, 4, reason: 'onDetach');
    b.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
}
