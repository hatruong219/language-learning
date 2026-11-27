import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Chữ hiện lên màn hình phải nói giọng TRUNG TÍNH.
///
/// App có nhiều người dùng, nên mọi nhãn và thông báo đều xưng hô kiểu "anh",
/// "em", "bạn" là sai — mỗi người đọc thấy một kiểu khiên cưỡng khác nhau.
/// Viết theo lối mô tả: "Từ đã đánh dấu", không phải "Từ anh đã đánh dấu".
///
/// Đây là lỗi đã mắc HAI LẦN. Lần đầu sửa tay toàn bộ nhãn, rồi vài tuần sau
/// thêm nhãn mới lại lọt tiếp — nên khoá bằng test thay vì trông vào trí nhớ.
///
/// Test này chỉ soi CHUỖI trong mã, không soi chú thích: chú thích viết cho
/// người sửa code, xưng hô thoải mái.
void main() {
  /// Đại từ nhân xưng, bắt theo ranh giới từ.
  ///
  /// Cần ranh giới vì "anh" nằm trong "nhanh", "thành", "xanh", "ảnh", "cạnh";
  /// "em" nằm trong "xem", "thêm", "đếm", "kèm".
  final pronoun = RegExp(
    r'(?<![\wÀ-ỹ])(anh|em|bạn|mình|tôi)(?![\wÀ-ỹ])',
    caseSensitive: false,
  );

  /// Chuỗi nháy đơn hoặc nháy kép nằm trong mã.
  final literal = RegExp(
    '''r?'((?:[^'\\\\\\n]|\\\\.){2,300})'|r?"((?:[^"\\\\\\n]|\\\\.){2,300})"''',
  );

  test('không nhãn nào xưng hô với người dùng', () {
    final offenders = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//')) continue;
        // Cắt phần chú thích cuối dòng.
        final code = line.split('//').first;
        for (final m in literal.allMatches(code)) {
          final text = m.group(1) ?? m.group(2) ?? '';
          if (pronoun.hasMatch(text)) {
            offenders.add('${file.path}:${i + 1}  →  "$text"');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Chuỗi hiển thị đang xưng hô với người dùng. Viết theo lối mô tả:\n'
          '${offenders.join('\n')}',
    );
  });
}
