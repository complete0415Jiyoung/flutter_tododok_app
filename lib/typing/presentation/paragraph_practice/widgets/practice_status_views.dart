// lib/typing/presentation/paragraph_practice/widgets/practice_status_views.dart
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors_style.dart';
import '../../../../shared/styles/app_text_style.dart';
import '../../../../shared/styles/app_dimensions.dart';

class PracticeStatusViews {
  const PracticeStatusViews._();

  /// 로딩 화면
  static Widget loading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('문장을 불러오는 중...'),
        ],
      ),
    );
  }

  /// 에러 화면
  static Widget error() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColorsStyle.error,
          ),
          const SizedBox(height: 16),
          Text(
            '문제가 발생했습니다',
            style: AppTextStyle.heading3.copyWith(
              color: AppColorsStyle.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다시 시도해주세요',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColorsStyle.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 일시정지 화면
  static Widget paused({
    required VoidCallback onResume,
    required VoidCallback onRestart,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        margin: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColorsStyle.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: const [
            BoxShadow(
              color: AppColorsStyle.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle,
              size: 64,
              color: AppColorsStyle.primary,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Text('연습 일시정지', style: AppTextStyle.heading3),
            const SizedBox(height: AppDimensions.spacing24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(onPressed: onResume, child: const Text('계속하기')),
                const SizedBox(width: AppDimensions.spacing16),
                OutlinedButton(
                  onPressed: onRestart,
                  child: const Text('다시 시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 완료 화면
  static Widget completed({
    required VoidCallback onViewResult,
    required VoidCallback onRestart,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        margin: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColorsStyle.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: const [
            BoxShadow(
              color: AppColorsStyle.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColorsStyle.success,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Text('연습 완료!', style: AppTextStyle.heading3),
            const SizedBox(height: AppDimensions.spacing24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: onViewResult,
                  child: const Text('결과 보기'),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                OutlinedButton(
                  onPressed: onRestart,
                  child: const Text('다시 시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
