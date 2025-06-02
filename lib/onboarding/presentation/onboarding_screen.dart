// lib/onboarding/presentation/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../../shared/styles/app_colors_style.dart';
import '../../shared/styles/app_text_style.dart';
import '../../shared/styles/app_dimensions.dart';
import 'onboarding_state.dart';
import 'onboarding_action.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingState state;
  final void Function(OnboardingAction action) onAction;

  const OnboardingScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void didUpdateWidget(OnboardingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태 변화에 따라 페이지 이동
    if (widget.state.currentPageIndex != oldWidget.state.currentPageIndex) {
      _pageController.animateToPage(
        widget.state.currentPageIndex,
        duration: AppDimensions.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildPageView()),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.state.currentPageIndex > 0)
            TextButton(
              onPressed: () =>
                  widget.onAction(const OnboardingAction.previousPage()),
              child: const Text('이전'),
            )
          else
            const SizedBox(width: 48),
          _buildPageIndicator(),
          TextButton(
            onPressed: () =>
                widget.onAction(const OnboardingAction.skipOnboarding()),
            child: const Text('건너뛰기'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == widget.state.currentPageIndex
                ? AppColorsStyle.primary
                : AppColorsStyle.gray300,
          ),
        );
      }),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        // 페이지 변경 시 상태 업데이트는 하지 않고,
        // 사용자가 스와이프할 때만 처리
      },
      children: [
        _buildOnboardingPage(
          icon: Icons.keyboard,
          title: '재미있는 타자 연습',
          description: '게임처럼 즐기면서\n타자 실력을 향상시켜보세요',
        ),
        _buildOnboardingPage(
          icon: Icons.group,
          title: '친구와 함께 대결',
          description: '친구에게 도전장을 보내고\n타자 실력을 겨뤄보세요',
        ),
        _buildOnboardingPage(
          icon: Icons.analytics,
          title: '성장하는 나의 기록',
          description: '꾸준한 연습으로\n실력 향상을 확인해보세요',
        ),
      ],
    );
  }

  Widget _buildOnboardingPage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColorsStyle.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: AppColorsStyle.primary),
          ),
          const SizedBox(height: AppDimensions.spacing48),
          Text(
            title,
            style: AppTextStyle.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            description,
            style: AppTextStyle.bodyLarge.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (widget.state.isLastPage) {
              widget.onAction(const OnboardingAction.completeOnboarding());
            } else {
              widget.onAction(const OnboardingAction.nextPage());
            }
          },
          child: Text(
            widget.state.isLastPage ? '시작하기' : '다음',
            style: AppTextStyle.buttonLarge,
          ),
        ),
      ),
    );
  }
}
