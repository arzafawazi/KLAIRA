import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi Klaira (font Plus Jakarta Sans).
///
/// Setiap gaya teks di Figma dipetakan ke slot [TextTheme] Material 3
/// sehingga bisa dipanggil lewat `Theme.of(context).textTheme`:
///
/// | Figma           | TextTheme        | Ukuran / tinggi baris |
/// |-----------------|------------------|-----------------------|
/// | Display         | `displaySmall`   | 32 / 40 · ExtraBold   |
/// | Heading/H1      | `headlineSmall`  | 24 / 32 · Bold        |
/// | Heading/H2      | `titleLarge`     | 20 / 28 · Bold        |
/// | Heading/H3      | `titleMedium`    | 16 / 24 · SemiBold    |
/// | Body/Large      | `bodyLarge`      | 16 / 24 · Regular     |
/// | Body/Default    | `bodyMedium`     | 14 / 21 · Regular     |
/// | Body/Strong     | `titleSmall`     | 14 / 21 · SemiBold    |
/// | Label/Button    | `labelLarge`     | 15 / 20 · SemiBold    |
/// | Body/Medium     | `labelMedium`    | 14 / 21 · Medium      |
/// | Caption         | `bodySmall`      | 12 / 16 · Medium      |
/// | Overline        | `labelSmall`     | 11 / 14 · Bold · caps |
abstract final class AppTypography {
  static const fontFamily = 'PlusJakartaSans';

  /// Cadangan untuk glyph yang tidak ada di Plus Jakarta Sans (mis. huruf Yunani μ).
  static const fontFamilyFallback = ['Roboto', 'sans-serif'];

  static TextStyle _s(double size, double height, FontWeight weight,
          {double spacing = 0, Color color = AppColors.ink900}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: spacing,
        color: color,
      );

  static final TextTheme textTheme = TextTheme(
    displaySmall: _s(32, 40, FontWeight.w800, spacing: -0.5),
    headlineSmall: _s(24, 32, FontWeight.w700, spacing: -0.3),
    titleLarge: _s(20, 28, FontWeight.w700, spacing: -0.2),
    titleMedium: _s(16, 24, FontWeight.w600),
    titleSmall: _s(14, 21, FontWeight.w600),
    bodyLarge: _s(16, 24, FontWeight.w400, color: AppColors.ink700),
    bodyMedium: _s(14, 21, FontWeight.w400, color: AppColors.ink700),
    bodySmall: _s(12, 16, FontWeight.w500, color: AppColors.ink500),
    labelLarge: _s(15, 20, FontWeight.w600),
    labelMedium: _s(14, 21, FontWeight.w500),
    labelSmall: _s(11, 14, FontWeight.w700, spacing: 0.8, color: AppColors.ink500),
  );
}
