import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Khoá hồi quy cho bản web: `dart:io` và `path_provider` không chạy trên
/// trình duyệt. Một import lọt vào `lib/` là bản web hỏng lúc build hoặc lúc
/// chạy, mà test trên VM vẫn xanh — nên phải canh bằng test riêng.
void main() {
  test('lib/ không import dart:io hay path_provider', () {
    final banned = RegExp(
      r'''^\s*(import|export)\s+['"](dart:io|package:path_provider/)''',
      multiLine: true,
    );
    final offenders = <String>[];
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (banned.hasMatch(e.readAsStringSync())) offenders.add(e.path);
    }
    expect(offenders, isEmpty, reason: 'file dùng API không có trên web');
  });
}
