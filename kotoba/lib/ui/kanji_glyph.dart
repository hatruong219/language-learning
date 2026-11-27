import 'package:flutter/material.dart';

import '../theme.dart';

/// Mặt chữ Hán, KHÔNG theo cỡ chữ hệ thống.
///
/// Đây là ràng buộc nặng nhất của phần Kanji. Mặt chữ là HÌNH để nhận dạng, không
/// phải chữ để đọc — người học cần nó luôn đủ lớn và luôn cùng một kích cỡ. Để nó
/// scale theo hệ thống thì ở cỡ chữ ×2.0 một glyph 29px thành 58px, hàng vỡ, và
/// bản release CẮT ÂM THẦM phần tràn: không vạch vàng, không lỗi, chỉ mất chữ.
/// Đúng họ lỗi đã làm màn mời chọn bài tràn 258px lần trước.
class KanjiGlyph extends StatelessWidget {
  const KanjiGlyph({
    super.key,
    required this.char,
    this.size = 29,
    this.box,
    this.highlight = false,
  });

  final String char;
  final double size;

  /// Cạnh ô vuông chứa glyph. Bỏ trống thì tự lấy theo [size].
  final double? box;

  /// Tô nền chàm nhạt — dùng cho mảnh mà bản thân cũng là một chữ trong bộ.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final edge = box ?? size * 1.55;
    return SizedBox.square(
      dimension: edge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlight ? c.aiWash : c.sunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight ? c.ai.withValues(alpha: 0.25) : c.line,
          ),
        ),
        child: Center(
          child: MediaQuery.withNoTextScaling(
            child: Text(
              char,
              style: TextStyle(
                fontSize: size,
                height: 1.1,
                color: c.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ba trạng thái của ô nghĩa, vẽ KHÁC NHAU có chủ ý.
///
/// Trộn ba thứ này vào một kiểu chữ là nói dối người học: "chưa có nghĩa" và
/// "bộ thủ này không mang nghĩa" trông giống nhau thì họ tưởng dữ liệu hỏng ở cả
/// hai chỗ, trong khi một chỗ là khuyết thật, chỗ kia là sự thật đã xác nhận.
enum MeaningKind {
  /// Có nghĩa tiếng Việt.
  present,

  /// KHÔNG có, và đó là khuyết dữ liệu thật — cần điền qua trang quản trị.
  missing,

  /// KHÔNG có, và đó là sự thật đã xác nhận: 亠 chỉ có tên, ハ là ký hiệu hình.
  stated,
}

class MeaningText extends StatelessWidget {
  const MeaningText({super.key, required this.kind, this.text, this.trailing});

  final MeaningKind kind;

  /// Nội dung khi [kind] là present hoặc stated.
  final String? text;

  /// Đuôi thêm vào cùng dòng, ví dụ "dạng của bộ 丿".
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final body = switch (kind) {
      MeaningKind.present => Text(
        text ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.3),
      ),
      // Gạch chân chấm: dấu hiệu quy ước cho chỗ còn thiếu, khác hẳn chữ nghiêng
      // của câu khẳng định bên dưới.
      MeaningKind.stated => Text(
        text ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: c.inkFaint,
          height: 1.3,
          fontStyle: FontStyle.italic,
        ),
      ),
      MeaningKind.missing => Text(
        'Chưa có nghĩa tiếng Việt',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: c.inkFaint,
          height: 1.3,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: c.inkFaint,
        ),
      ),
    };
    if (trailing == null) return body;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [body, trailing!],
    );
  }
}

/// Nhãn loại nhỏ cạnh tên: "chữ", "bộ thủ", "hình nét".
///
/// Kẹp cỡ chữ ở ×1.4. Đây là NHÃN PHÂN LOẠI, không phải nội dung để đọc — ở ×2.0
/// nó thành 21px cộng cả lề và đẩy hàng tràn 1px trên iPhone Max. Cùng lý do đã
/// kẹp nhãn tab dưới đáy ở ×1.3: chỗ nào bề rộng chia cứng thì nhãn không được
/// phóng tự do, còn nội dung thật vẫn phóng bình thường.
class KindTag extends StatelessWidget {
  const KindTag({super.key, required this.label, this.emphasise = false});

  final String label;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: _body(c),
    );
  }

  Widget _body(Palette c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: emphasise ? c.aiWash : c.sunken,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: emphasise ? c.ai : c.inkFaint,
        ),
      ),
    );
  }
}
