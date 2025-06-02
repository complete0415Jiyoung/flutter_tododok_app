/// 토도독 앱의 간격 및 크기 시스템을 정의하는 클래스
abstract class AppDimensions {
  // === Spacing System (간격) ===
  // 8의 배수 기반 간격 시스템
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // === Semantic Spacing (의미 기반 간격) ===
  static const double paddingXS = spacing4; // 매우 작은 여백
  static const double paddingSM = spacing8; // 작은 여백
  static const double paddingMD = spacing16; // 중간 여백
  static const double paddingLG = spacing24; // 큰 여백
  static const double paddingXL = spacing32; // 매우 큰 여백
  static const double paddingXXL = spacing48; // 최대 여백

  static const double marginXS = spacing4;
  static const double marginSM = spacing8;
  static const double marginMD = spacing16;
  static const double marginLG = spacing24;
  static const double marginXL = spacing32;
  static const double marginXXL = spacing48;

  // === Border Radius (둥근 모서리) ===
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 999.0; // 완전히 둥근 모서리

  // === Border Width (테두리 두께) ===
  static const double borderThin = 0.5;
  static const double borderNormal = 1.0;
  static const double borderThick = 2.0;
  static const double borderFocus = 3.0; // 포커스 상태

  // === Elevation (그림자 깊이) ===
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation16 = 16.0;

  // === Icon Sizes (아이콘 크기) ===
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // === Button Sizes (버튼 크기) ===
  static const double buttonHeightSM = 32.0;
  static const double buttonHeightMD = 40.0;
  static const double buttonHeightLG = 48.0;
  static const double buttonHeightXL = 56.0;

  static const double buttonMinWidth = 64.0;
  static const double buttonPaddingHorizontal = spacing16;
  static const double buttonPaddingVertical = spacing12;

  // === Input Field Sizes (입력 필드 크기) ===
  static const double inputHeight = 48.0;
  static const double inputHeightLarge = 56.0;
  static const double inputPadding = spacing16;
  static const double inputRadius = radiusMD;

  // === Card Sizes (카드 크기) ===
  static const double cardPadding = spacing16;
  static const double cardPaddingLarge = spacing20;
  static const double cardRadius = radiusLG;
  static const double cardElevation = elevation2;

  // === App Bar Sizes (앱바 크기) ===
  static const double appBarHeight = 56.0;
  static const double appBarElevation = elevation0;

  // === Bottom Navigation (하단 네비게이션) ===
  static const double bottomNavHeight = 56.0;
  static const double bottomNavElevation = elevation8;

  // === Modal & Dialog Sizes (모달/다이얼로그 크기) ===
  static const double modalRadius = radiusXL;
  static const double modalPadding = spacing24;
  static const double modalMaxWidth = 400.0;

  static const double dialogRadius = radiusLG;
  static const double dialogPadding = spacing20;
  static const double dialogElevation = elevation16;

  // === Typing Practice Specific (타자 연습 전용) ===
  static const double typingContainerPadding = spacing20;
  static const double typingTextLineHeight = 48.0;
  static const double typingKeyboardHeight = 280.0;
  static const double typingStatsCardPadding = spacing16;
  static const double typingStatsCardRadius = radiusLG;

  // === Challenge Card Specific (도전장 카드 전용) ===
  static const double challengeCardPadding = spacing16;
  static const double challengeCardRadius = radiusLG;
  static const double challengeCardElevation = elevation2;
  static const double challengeCodeInputHeight = 64.0;

  // === List Item Sizes (리스트 아이템 크기) ===
  static const double listItemHeight = 56.0;
  static const double listItemPadding = spacing16;
  static const double listItemVerticalPadding = spacing12;

  // === Divider (구분선) ===
  static const double dividerThickness = 0.5;
  static const double dividerIndent = spacing16;

  // === Loading & Progress (로딩 및 진행률) ===
  static const double progressBarHeight = 4.0;
  static const double loadingIndicatorSize = 20.0;
  static const double loadingIndicatorSizeLarge = 32.0;

  // === Screen Breakpoints (화면 크기 기준점) ===
  static const double screenXS = 320.0; // 작은 폰
  static const double screenSM = 375.0; // 일반 폰
  static const double screenMD = 414.0; // 큰 폰
  static const double screenLG = 768.0; // 태블릿
  static const double screenXL = 1024.0; // 데스크톱

  // === Safe Area Padding (안전 영역 여백) ===
  static const double safeAreaBottom = 34.0; // iPhone 홈 인디케이터
  static const double safeAreaTop = 44.0; // iPhone 노치

  // === Animation Duration (애니메이션 지속 시간) ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationExtra = Duration(milliseconds: 500);
}
