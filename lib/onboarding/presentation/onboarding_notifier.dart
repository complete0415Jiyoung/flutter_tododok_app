// lib/onboarding/presentation/onboarding_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'onboarding_state.dart';
import 'onboarding_action.dart';

part 'onboarding_notifier.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  static const int totalPages = 3; // 온보딩 페이지 총 개수

  @override
  OnboardingState build() {
    return const OnboardingState(
      currentPageIndex: 0,
      isLastPage: false,
      isCompleted: false,
    );
  }

  Future<void> onAction(OnboardingAction action) async {
    switch (action) {
      case NextPage():
        _nextPage();
      case PreviousPage():
        _previousPage();
      case SkipOnboarding():
        _skipOnboarding();
      case CompleteOnboarding():
        _completeOnboarding();
    }
  }

  void _nextPage() {
    final newIndex = state.currentPageIndex + 1;
    if (newIndex < totalPages) {
      state = state.copyWith(
        currentPageIndex: newIndex,
        isLastPage: newIndex == totalPages - 1,
      );
    }
  }

  void _previousPage() {
    final newIndex = state.currentPageIndex - 1;
    if (newIndex >= 0) {
      state = state.copyWith(currentPageIndex: newIndex, isLastPage: false);
    }
  }

  void _skipOnboarding() {
    state = state.copyWith(isCompleted: true);
  }

  void _completeOnboarding() {
    state = state.copyWith(isCompleted: true);
  }
}
