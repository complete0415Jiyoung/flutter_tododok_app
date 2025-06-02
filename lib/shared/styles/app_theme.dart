import 'package:flutter/material.dart';
import 'app_colors_style.dart';
import 'app_text_style.dart';
import 'app_dimensions.dart';

/// 토도독 앱의 통합 테마 시스템
class AppTheme {
  const AppTheme._();

  /// 라이트 테마
  static ThemeData get light => ThemeData(
    useMaterial3: true,

    // === Color Scheme ===
    colorScheme: const ColorScheme.light(
      primary: AppColorsStyle.primary,
      onPrimary: AppColorsStyle.onPrimary,
      primaryContainer: AppColorsStyle.primaryContainer,
      secondary: AppColorsStyle.secondary,
      onSecondary: AppColorsStyle.onSecondary,
      secondaryContainer: AppColorsStyle.secondaryContainer,
      surface: AppColorsStyle.surface,
      onSurface: AppColorsStyle.onSurface,
      error: AppColorsStyle.error,
      onError: AppColorsStyle.onPrimary,
      outline: AppColorsStyle.border,
    ),

    // === Text Theme ===
    textTheme: const TextTheme(
      displayLarge: AppTextStyle.heading1,
      displayMedium: AppTextStyle.heading2,
      displaySmall: AppTextStyle.heading3,
      headlineLarge: AppTextStyle.heading3,
      headlineMedium: AppTextStyle.heading4,
      headlineSmall: AppTextStyle.heading5,
      titleLarge: AppTextStyle.heading4,
      titleMedium: AppTextStyle.heading5,
      titleSmall: AppTextStyle.labelLarge,
      bodyLarge: AppTextStyle.bodyLarge,
      bodyMedium: AppTextStyle.bodyMedium,
      bodySmall: AppTextStyle.bodySmall,
      labelLarge: AppTextStyle.labelLarge,
      labelMedium: AppTextStyle.labelMedium,
      labelSmall: AppTextStyle.labelSmall,
    ),

    // === App Bar Theme ===
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsStyle.surface,
      foregroundColor: AppColorsStyle.textPrimary,
      elevation: AppDimensions.appBarElevation,
      centerTitle: true,
      titleTextStyle: AppTextStyle.heading4,
      toolbarHeight: AppDimensions.appBarHeight,
      surfaceTintColor: Colors.transparent,
    ),

    // === Button Themes ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsStyle.buttonPrimary,
        foregroundColor: AppColorsStyle.textOnPrimary,
        textStyle: AppTextStyle.buttonMedium,
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightMD,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.buttonPaddingHorizontal,
          vertical: AppDimensions.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        elevation: AppDimensions.elevation2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsStyle.primary,
        textStyle: AppTextStyle.buttonMedium,
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightMD,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.buttonPaddingHorizontal,
          vertical: AppDimensions.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        side: const BorderSide(
          color: AppColorsStyle.border,
          width: AppDimensions.borderNormal,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsStyle.primary,
        textStyle: AppTextStyle.buttonMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.buttonPaddingHorizontal,
          vertical: AppDimensions.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    ),

    // === Input Decoration Theme ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsStyle.containerBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(
          color: AppColorsStyle.border,
          width: AppDimensions.borderNormal,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(
          color: AppColorsStyle.border,
          width: AppDimensions.borderNormal,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(
          color: AppColorsStyle.primary,
          width: AppDimensions.borderFocus,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
        borderSide: const BorderSide(
          color: AppColorsStyle.error,
          width: AppDimensions.borderNormal,
        ),
      ),
      contentPadding: const EdgeInsets.all(AppDimensions.inputPadding),
      labelStyle: AppTextStyle.labelMedium,
      hintStyle: AppTextStyle.bodyMedium.withColor(AppColorsStyle.textTertiary),
    ),

    // === Card Theme ===
    cardTheme: CardThemeData(
      color: AppColorsStyle.cardBackground,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      margin: const EdgeInsets.all(AppDimensions.spacing8),
    ),

    // === List Tile Theme ===
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPadding,
        vertical: AppDimensions.listItemVerticalPadding,
      ),
      titleTextStyle: AppTextStyle.bodyLarge,
      subtitleTextStyle: AppTextStyle.bodyMedium.withColor(
        AppColorsStyle.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
    ),

    // === Divider Theme ===
    dividerTheme: const DividerThemeData(
      color: AppColorsStyle.divider,
      thickness: AppDimensions.dividerThickness,
      indent: AppDimensions.dividerIndent,
      endIndent: AppDimensions.dividerIndent,
    ),

    // === Progress Indicator Theme ===
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColorsStyle.primary,
      linearTrackColor: AppColorsStyle.containerBackground,
    ),

    // === Bottom Navigation Bar Theme ===
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColorsStyle.surface,
      selectedItemColor: AppColorsStyle.primary,
      unselectedItemColor: AppColorsStyle.textTertiary,
      selectedLabelStyle: AppTextStyle.labelSmall.withColor(
        AppColorsStyle.primary,
      ),
      unselectedLabelStyle: AppTextStyle.labelSmall.withColor(
        AppColorsStyle.textTertiary,
      ),
      elevation: AppDimensions.bottomNavElevation,
      type: BottomNavigationBarType.fixed,
    ),

    // === Dialog Theme ===
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsStyle.surface,
      elevation: AppDimensions.dialogElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
      ),
      titleTextStyle: AppTextStyle.heading4,
      contentTextStyle: AppTextStyle.bodyMedium,
    ),

    // === Switch Theme ===
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsStyle.primary;
        }
        return AppColorsStyle.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsStyle.primaryContainer;
        }
        return AppColorsStyle.containerBackground;
      }),
    ),

    // === Checkbox Theme ===
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(AppColorsStyle.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsStyle.primary;
        }
        return AppColorsStyle.containerBackground;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
    ),

    // === Floating Action Button Theme ===
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorsStyle.primary,
      foregroundColor: AppColorsStyle.textOnPrimary,
      elevation: AppDimensions.elevation4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      ),
    ),

    // === Chip Theme ===
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsStyle.containerBackground,
      selectedColor: AppColorsStyle.primaryContainer,
      deleteIconColor: AppColorsStyle.textTertiary,
      labelStyle: AppTextStyle.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      side: const BorderSide(
        color: AppColorsStyle.border,
        width: AppDimensions.borderThin,
      ),
    ),
  );

  /// 다크 테마 (기본 구조만)
  static ThemeData get dark => light.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: AppColorsStyle.primaryLight,
      onPrimary: AppColorsStyle.black,
      surface: AppColorsStyle.darkSurface,
      onSurface: AppColorsStyle.darkOnSurface,
      error: AppColorsStyle.error,
    ),
  );
}
