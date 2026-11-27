import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ký tự nào hiện lên màn hình mà font đóng gói không có glyph thì CanvasKit
/// tải Noto từ fonts.gstatic.com lúc chạy (hỏng khi offline, chớp ô vuông khi
/// online) — đúng thứ bản web phải tránh.
///
/// Không đọc cmap của TTF trong Dart (nặng): `tools/font-coverage.txt` là
/// danh sách mã Unicode do `tools/check-font-coverage.py --write` sinh từ
/// chính các TTF (subset-fonts.py tự gọi). Thêm chuỗi có ký tự lạ thì test
/// này đỏ; sửa bằng cách đổi ký tự hoặc thêm vào ALWAYS của subset-fonts.py
/// rồi chạy lại script. Logic quét khớp với check-font-coverage.py.
void main() {
  final stringRe = RegExp(r'''\x27(?:\\.|[^\x27\\\n])*\x27|"(?:\\.|[^"\\\n])*"''');
  final escapeRe = RegExp(
    r'\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})|\\x([0-9a-fA-F]{2})',
  );

  String decode(String lit) => lit.replaceAllMapped(
    escapeRe,
    (m) => String.fromCharCode(
      int.parse((m[1] ?? m[2] ?? m[3])!, radix: 16),
    ),
  );

  test('mọi ký tự trong assets/*.json và chuỗi lib/ có trong font đóng gói', () {
    final covered = File('tools/font-coverage.txt')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty)
        .map((l) => int.parse(l, radix: 16))
        .toSet();
    expect(covered.length, greaterThan(1000), reason: 'danh sách phủ rỗng?');

    final missing = <int, String>{};
    void scan(String text, String where) {
      for (final r in text.runes) {
        if (r >= 0x20 && !covered.contains(r)) missing.putIfAbsent(r, () => where);
      }
    }

    for (final f in Directory('assets').listSync()) {
      if (f is File && f.path.endsWith('.json')) {
        scan(f.readAsStringSync(), f.path);
      }
    }
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      for (final line in f.readAsLinesSync()) {
        if (line.contains('RegExp(')) continue; // chỉ để so khớp, không hiển thị
        for (final m in stringRe.allMatches(line)) {
          scan(decode(m[0]!), f.path);
        }
      }
    }

    expect(
      missing.entries
          .map((e) => 'U+${e.key.toRadixString(16).toUpperCase()} '
              '"${String.fromCharCode(e.key)}"  ${e.value}')
          .toList(),
      isEmpty,
      reason: 'ký tự thiếu glyph — xem tools/subset-fonts.py',
    );
  });
}
