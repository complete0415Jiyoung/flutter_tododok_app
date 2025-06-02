// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// 토도독 앱의 색상 시스템을 정의하는 클래스
class AppColorsStyle {
  const AppColorsStyle._();

  // === Primary Colors (메인 컬러 - 보라색 계열) ===
  static const Color primary = Color(0xFF8472FF); // purple100
  static const Color primaryLight = Color(0xFF9747FF); // purple300
  static const Color primaryDark = Color(0xFF322F49); // purple900
  static const Color primaryContainer = Color(0xFFC9C5E2); // purple200

  // === Secondary Colors (보조 컬러 - 회색 계열) ===
  static const Color secondary = Color(0xFF9A9B9E); // gray400
  static const Color secondaryLight = Color(0xFFD9D9D9); // gray4
  static const Color secondaryDark = Color(0xFF333333); // gray800
  static const Color secondaryContainer = Color(0xFFF7F7F9); // gray50

  // === Surface Colors (배경/표면) ===
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7F9); // gray50
  static const Color surfaceTint = Color(0xFFF7F7F9);
  static const Color background = Color(0xFFFFFFFF);

  // === Text Colors (텍스트) ===
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F1F1F); // gray900
  static const Color onSurfaceVariant = Color(0xFF333333); // gray800
  static const Color onBackground = Color(0xFF1F1F1F); // gray900

  // === Text Color Aliases (텍스트 색상 별칭) ===
  static const Color textPrimary = Color(0xFF1F1F1F); // gray900
  static const Color textSecondary = Color(0xFF333333); // gray800
  static const Color textTertiary = Color(0xFF9A9B9E); // gray400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === Gray Scale (회색 계열) ===
  static const Color gray4 = Color(0xFFD9D9D9);
  static const Color gray50 = Color(0xFFF7F7F9);
  static const Color gray300 = Color(0xFF9D9D9D);
  static const Color gray400 = Color(0xFF9A9B9E);
  static const Color gray800 = Color(0xFF333333);
  static const Color gray900 = Color(0xFF1F1F1F);

  // === Purple Scale (보라색 계열) ===
  static const Color purple100 = Color(0xFF8472FF);
  static const Color purple200 = Color(0xFFC9C5E2);
  static const Color purple300 = Color(0xFF9747FF);
  static const Color purple500 = Color(0xFF9B51E0);
  static const Color purple900 = Color(0xFF322F49);

  // === Semantic Colors (의미 있는 색상) ===
  static const Color success = Color(0xFF4CAF50); // 성공 (초록)
  static const Color warning = Color(0xFFFEE500); // 경고 (노랑)
  static const Color error = Color(0xFFF62424); // 오류 (빨강)
  static const Color info = Color(0xFF8472FF); // 정보 (보라)

  // === Typing Practice Colors (타자 연습 전용) ===
  static const Color typingCorrect = Color(0xFF4CAF50); // 정확한 입력 (초록)
  static const Color typingIncorrect = Color(0xFFF62424); // 틀린 입력 (빨강)
  static const Color typingCurrent = Color(0xFF8472FF); // 현재 입력 위치 (보라)
  static const Color typingPending = Color(0xFF9A9B9E); // 아직 입력하지 않은 글자 (회색)

  // === Challenge Colors (도전장 관련) ===
  static const Color challengeWin = Color(0xFFFEE500); // 승리 (노랑)
  static const Color challengeLose = Color(0xFF9A9B9E); // 패배 (회색)
  static const Color challengeDraw = Color(0xFFF8B3B8); // 무승부 (핑크)

  // === Border Colors (테두리) ===
  static const Color border = Color(0xFF9D9D9D); // gray300
  static const Color borderLight = Color(0xFFD9D9D9); // gray4
  static const Color borderDark = Color(0xFF333333); // gray800
  static const Color divider = Color(0xFFD9D9D9); // gray4

  // === Shadow Colors (그림자) ===
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x3F000000);

  // === Additional UI Colors ===
  static const Color containerBackground = Color(0xFFF7F7F9); // gray50
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color buttonPrimary = Color(0xFF8472FF); // purple100
  static const Color buttonSecondary = Color(0xFF9A9B9E); // gray400
  static const Color buttonDisabled = Color(0xFF9D9D9D); // gray300
  static const Color buttonDanger = Color(0xFFF62424); // red100

  // === Dark Theme Colors (다크 테마용) ===
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFE1E1E1);

  // === Basic Colors ===
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color white20 = Color(0x33FFFFFF);

  // 기존 색상들과의 호환성을 위한 별칭들
  static const Color correct = typingCorrect;
  static const Color incorrect = typingIncorrect;
  static const Color current = typingCurrent;
  static const Color pending = typingPending;
  static const Color win = challengeWin;
  static const Color lose = challengeLose;
  static const Color draw = challengeDraw;
}

/// Material 3 ColorScheme 확장
extension AppColorsStyleScheme on ColorScheme {
  /// 라이트 테마 ColorScheme
  static ColorScheme get light => const ColorScheme.light(
    primary: AppColorsStyle.primary,
    onPrimary: AppColorsStyle.onPrimary,
    primaryContainer: AppColorsStyle.primaryContainer,
    secondary: AppColorsStyle.secondary,
    onSecondary: AppColorsStyle.onSecondary,
    secondaryContainer: AppColorsStyle.secondaryContainer,
    surface: AppColorsStyle.surface,
    onSurface: AppColorsStyle.onSurface,
    surfaceVariant: AppColorsStyle.surfaceVariant,
    onSurfaceVariant: AppColorsStyle.onSurfaceVariant,
    background: AppColorsStyle.background,
    onBackground: AppColorsStyle.onBackground,
    error: AppColorsStyle.error,
    onError: AppColorsStyle.onPrimary,
    outline: AppColorsStyle.border,
    shadow: AppColorsStyle.shadow,
  );

  /// 다크 테마 ColorScheme
  static ColorScheme get dark => const ColorScheme.dark(
    primary: AppColorsStyle.primaryLight,
    onPrimary: AppColorsStyle.darkBackground,
    primaryContainer: AppColorsStyle.primaryDark,
    secondary: AppColorsStyle.secondaryLight,
    onSecondary: AppColorsStyle.darkBackground,
    secondaryContainer: AppColorsStyle.secondaryDark,
    surface: AppColorsStyle.darkSurface,
    onSurface: AppColorsStyle.darkOnSurface,
    background: AppColorsStyle.darkBackground,
    onBackground: AppColorsStyle.darkOnSurface,
    error: AppColorsStyle.error,
    onError: AppColorsStyle.darkBackground,
    outline: AppColorsStyle.borderDark,
    shadow: AppColorsStyle.shadowDark,
  );
}
