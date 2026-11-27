import 'package:flutter/material.dart';

/// Bảng màu lấy từ 藍染 (aizome) — chàm nhuộm truyền thống Nhật.
/// Xám ngả lạnh về phía chàm chứ không phải xám trung tính vô chủ.
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.paper,
    required this.card,
    required this.sunken,
    required this.line,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.ai,
    required this.aiWash,
    required this.kincha,
    required this.kinchaWash,
    required this.matcha,
    required this.matchaWash,
    required this.shu,
    required this.shuWash,
    required this.edge,
    required this.onAi,
    required this.raise,
  });

  final Color paper, card, sunken, line;
  final Color ink, inkSoft, inkFaint;

  /// Chàm — màu tương tác.
  final Color ai, aiWash;

  /// Hổ phách — đánh dấu "cần học lại".
  final Color kincha, kinchaWash;

  /// Xanh trà — đúng. Đỏ chu — chưa khớp.
  final Color matcha, matchaWash, shu, shuWash;

  /// Viền thẻ. Nền sáng nhạt hơn [line] vì bóng đổ đã vẽ ra mép thẻ — viền
  /// đậm cộng bóng thì thẻ trông "dán băng keo". Nền tối không có bóng thấy
  /// được nên viền vẫn là thứ tách thẻ khỏi nền.
  final Color edge;

  /// Chữ/icon đặt trên nền chàm [ai]. Nền tối dùng chàm sáng (#7AA5EC) nên
  /// chữ trắng chỉ đạt ~2.4:1 — dưới chuẩn WCAG AA. Đổi sang mực đậm (~8:1).
  final Color onAi;

  /// Bóng đổ mềm hai lớp: một lớp sát (mép), một lớp loang (độ nổi). Màu
  /// bóng ngả chàm như cả bảng màu, không dùng đen trần.
  final List<BoxShadow> raise;

  static const light = Palette(
    paper: Color(0xFFF4F6FA),
    card: Color(0xFFFFFFFF),
    sunken: Color(0xFFE8ECF3),
    line: Color(0xFFDCE1EB),
    ink: Color(0xFF14171D),
    inkSoft: Color(0xFF4A5163),
    inkFaint: Color(0xFF878FA3),
    ai: Color(0xFF2D5BA9),
    aiWash: Color(0xFFE7EDF9),
    kincha: Color(0xFFB0791A),
    kinchaWash: Color(0xFFFBF0DA),
    matcha: Color(0xFF1B7A44),
    matchaWash: Color(0xFFE2F3E8),
    shu: Color(0xFFB93A29),
    shuWash: Color(0xFFFBE7E4),
    edge: Color(0xFFE4E8F0),
    onAi: Color(0xFFFFFFFF),
    raise: [
      BoxShadow(color: Color(0x0D1B2A4A), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0F1B2A4A), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  static const dark = Palette(
    paper: Color(0xFF0F1116),
    card: Color(0xFF191D25),
    sunken: Color(0xFF232833),
    line: Color(0xFF2E3542),
    ink: Color(0xFFEDEFF4),
    inkSoft: Color(0xFFAEB6C6),
    inkFaint: Color(0xFF737C8F),
    ai: Color(0xFF7AA5EC),
    aiWash: Color(0xFF1B2740),
    kincha: Color(0xFFDFA83E),
    kinchaWash: Color(0xFF2E2717),
    matcha: Color(0xFF4FBF80),
    matchaWash: Color(0xFF14291D),
    shu: Color(0xFFE8705C),
    shuWash: Color(0xFF2C1917),
    edge: Color(0xFF2A303C),
    onAi: Color(0xFF0D1A30),
    raise: [
      BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) =>
      t < 0.5 ? this : (other as Palette? ?? this);
}

/// Lấy bảng màu ở bất kỳ đâu trong cây widget.
extension PaletteOf on BuildContext {
  Palette get c => Theme.of(this).extension<Palette>()!;
}

/// Bán kính bo góc chuẩn. Trước đây mỗi thẻ một số (11, 12, 14) — lệch vài
/// điểm ảnh không ai gọi tên được nhưng ai cũng thấy "không đều".
abstract final class Radii {
  static const row = 12.0;
  static const card = 16.0;
  static const control = 12.0;
  static const sheet = 24.0;
}

extension PaletteSurfaces on Palette {
  /// Nền thẻ chuẩn: nền card, viền mảnh, bóng mềm. Mọi thẻ/dòng nổi trên nền
  /// giấy đều dùng hàm này để độ nổi đồng nhất ở cả sáng lẫn tối.
  BoxDecoration cardBox({double radius = Radii.card}) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: edge),
    boxShadow: raise,
  );
}
