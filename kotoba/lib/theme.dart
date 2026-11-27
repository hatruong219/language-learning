import 'package:flutter/material.dart';

import 'palette.dart';

// Bảng màu + bán kính tách sang palette.dart cho file này gọn; export lại để
// mọi chỗ đang import theme.dart không phải sửa.
export 'palette.dart';

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
    // iOS/macOS giữ kiểu Cupertino (vuốt mép trái để quay lại — người dùng
    // iPhone quen tay). Nơi khác dùng mờ-trượt nhẹ thay vì phóng to kiểu
    // Android cũ, nhìn liền mạch hơn trên web.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
      },
    ),
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
        foregroundColor: p.onAi,
        disabledBackgroundColor: p.sunken,
        disabledForegroundColor: p.inkFaint,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control + 2),
        ),
        textStyle: const TextStyle(
          fontFamily: bundledFontFamily,
          fontFamilyFallback: bundledFontFallback,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.inkSoft,
        backgroundColor: p.card,
        side: BorderSide(color: p.line),
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control),
        ),
        textStyle: const TextStyle(
          fontFamily: bundledFontFamily,
          fontFamilyFallback: bundledFontFallback,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control),
        ),
        textStyle: const TextStyle(
          fontFamily: bundledFontFamily,
          fontFamilyFallback: bundledFontFallback,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.sheet),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.ai,
      linearTrackColor: p.sunken,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(
        fontFamily: bundledFontFamily,
        fontFamilyFallback: bundledFontFallback,
        color: p.paper,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
  );
}
