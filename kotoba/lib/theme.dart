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
  });

  final Color paper, card, sunken, line;
  final Color ink, inkSoft, inkFaint;

  /// Chàm — màu tương tác.
  final Color ai, aiWash;

  /// Hổ phách — đánh dấu "cần học lại".
  final Color kincha, kinchaWash;

  /// Xanh trà — đúng. Đỏ chu — chưa khớp.
  final Color matcha, matchaWash, shu, shuWash;

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

/// Style do widget đặt RIÊNG (textStyle/labelStyle/titleTextStyle…) THAY chứ
/// không gộp với theme, nên mất family → engine rơi về 'Roboto' không có kana
/// và đi tải font Noto từ fonts.gstatic.com. Mọi style kiểu đó phải ghi lại
/// hai hằng này (test/font_inheritance_test.dart bắt chỗ sót).
const bundledFontFamily = 'NotoSans';
const bundledFontFallback = ['NotoSansJP'];

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.ai,
      brightness: brightness,
    ).copyWith(surface: p.paper, primary: p.ai),
    scaffoldBackgroundColor: p.paper,
    fontFamily: bundledFontFamily,
    fontFamilyFallback: bundledFontFallback,
  );

  return base.copyWith(
    extensions: [p],
    // Font đóng gói sẵn: NotoSans lo Latin + dấu Việt, NotoSansJP lo kana/kanji.
    // CanvasKit không dùng font hệ thống, thiếu glyph là đi tải từ Google.
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    dividerColor: p.line,
    splashFactory: InkSparkle.splashFactory,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: p.card,
      selectedItemColor: p.ai,
      unselectedItemColor: p.inkFaint,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: bundledFontFamily,
        fontFamilyFallback: bundledFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: bundledFontFamily,
        fontFamilyFallback: bundledFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.paper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: bundledFontFamily,
        fontFamilyFallback: bundledFontFallback,
        color: p.ink,
        fontSize: 27,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.ai,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: bundledFontFamily,
          fontFamilyFallback: bundledFontFallback,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(
        fontFamily: bundledFontFamily,
        fontFamilyFallback: bundledFontFallback,
        color: p.paper,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
