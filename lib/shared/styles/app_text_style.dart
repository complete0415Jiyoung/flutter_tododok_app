import 'package:flutter/material.dart';
import 'app_colors_style.dart';

/// 토도독 앱의 타이포그래피 시스템을 정의하는 클래스
abstract class AppTextStyle {
  // === Font Family ===
  static const String _fontFamily = 'Pretendard'; // 기본 폰트
  static const String _monoFontFamily = 'SF Mono'; // 타자 연습용 고정폭 폰트

  // === Heading Styles (제목) ===
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle heading5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0,
    height: 1.4,
    color: AppColorsStyle.textPrimary,
  );

  // === Body Styles (본문) ===
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColorsStyle.textSecondary,
  );

  // === Label Styles (라벨) ===
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: AppColorsStyle.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    color: AppColorsStyle.textTertiary,
  );

  // === Button Styles (버튼) ===
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColorsStyle.textOnPrimary,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
    color: AppColorsStyle.textOnPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColorsStyle.textOnPrimary,
  );

  // === Typing Practice Styles (타자 연습 전용) ===
  static const TextStyle typingText = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    height: 1.6,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle typingTextLarge = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.2,
    height: 1.6,
    color: AppColorsStyle.textPrimary,
  );

  static const TextStyle typingCorrect = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    height: 1.6,
    color: AppColorsStyle.typingCorrect,
    backgroundColor: Color(0x1A4CAF50), // 연한 초록 배경
  );

  static const TextStyle typingIncorrect = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    height: 1.6,
    color: AppColorsStyle.typingIncorrect,
    backgroundColor: Color(0x1AF44336), // 연한 빨강 배경
  );

  static const TextStyle typingCurrent = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.6,
    color: AppColorsStyle.typingCurrent,
    backgroundColor: Color(0x1A2196F3), // 연한 파랑 배경
  );

  static const TextStyle typingPending = TextStyle(
    fontFamily: _monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    height: 1.6,
    color: AppColorsStyle.typingPending,
  );

  // === Number Styles (숫자/통계 표시용) ===
  static const TextStyle numberLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColorsStyle.primary,
  );

  static const TextStyle numberMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColorsStyle.primary,
  );

  static const TextStyle numberSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    color: AppColorsStyle.primary,
  );

  // === Caption Styles (작은 설명 텍스트) ===
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColorsStyle.textTertiary,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColorsStyle.textSecondary,
  );

  // === Challenge Result Styles (도전장 결과 표시용) ===
  static const TextStyle resultWin = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.2,
    color: AppColorsStyle.challengeWin,
  );

  static const TextStyle resultLose = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.2,
    color: AppColorsStyle.challengeLose,
  );

  static const TextStyle resultDraw = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.2,
    color: AppColorsStyle.challengeDraw,
  );
}

/// TextStyle 확장 메서드
extension AppTextStyleExtensions on TextStyle {
  /// 색상 변경
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 폰트 크기 변경
  TextStyle withSize(double fontSize) => copyWith(fontSize: fontSize);

  /// 폰트 굵기 변경
  TextStyle withWeight(FontWeight fontWeight) =>
      copyWith(fontWeight: fontWeight);

  /// 투명도 적용
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));

  /// 기본 색상별 변형
  TextStyle get primary => withColor(AppColorsStyle.primary);
  TextStyle get secondary => withColor(AppColorsStyle.secondary);
  TextStyle get success => withColor(AppColorsStyle.success);
  TextStyle get error => withColor(AppColorsStyle.error);
  TextStyle get warning => withColor(AppColorsStyle.warning);

  /// 텍스트 색상별 변형
  TextStyle get textPrimary => withColor(AppColorsStyle.textPrimary);
  TextStyle get textSecondary => withColor(AppColorsStyle.textSecondary);
  TextStyle get textTertiary => withColor(AppColorsStyle.textTertiary);
  TextStyle get onPrimary => withColor(AppColorsStyle.textOnPrimary);
}
