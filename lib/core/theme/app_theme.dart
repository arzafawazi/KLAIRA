import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Tema Material 3 Klaira yang dibangun dari token design system.
abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary600,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.primary50,
      onPrimaryContainer: AppColors.primary700,
      secondary: AppColors.accent500,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.accent100,
      onSecondaryContainer: AppColors.accent600,
      tertiary: AppColors.primary500,
      onTertiary: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.surface,
      errorContainer: AppColors.dangerBg,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.ink900,
      onSurfaceVariant: AppColors.ink500,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.ink100,
      surfaceContainerHighest: AppColors.ink100,
      outline: AppColors.ink200,
      outlineVariant: AppColors.ink100,
      shadow: AppColors.ink900,
      inverseSurface: AppColors.ink900,
      onInverseSurface: AppColors.surface,
    );

    final text = AppTypography.textTheme;
    final buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.lgAll);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    const minButtonSize = Size(64, 52);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink900,
        titleTextStyle: text.titleMedium,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.ink200,
          disabledForegroundColor: AppColors.ink500,
          minimumSize: minButtonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primary50,
          foregroundColor: AppColors.primary700,
          side: const BorderSide(color: AppColors.primary100),
          minimumSize: minButtonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary600,
          minimumSize: const Size(48, 44),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.ink500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.ink200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.ink200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary600,
        side: const BorderSide(color: AppColors.ink200),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
        labelStyle: text.labelMedium?.copyWith(color: AppColors.ink700),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: AppColors.surface),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.titleSmall),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.ink200)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.surface : AppColors.ink100,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.ink900 : AppColors.ink500,
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary50,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.bodySmall?.copyWith(
            color: s.contains(WidgetState.selected) ? AppColors.primary600 : AppColors.ink500,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? AppColors.primary600 : AppColors.ink500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary600,
        foregroundColor: AppColors.surface,
        shape: CircleBorder(),
        elevation: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.surface : AppColors.ink300,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary600 : AppColors.ink100,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.ink100, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink900,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary600,
        linearTrackColor: AppColors.ink100,
      ),
    );
  }
}
