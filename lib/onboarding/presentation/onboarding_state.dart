// lib/onboarding/presentation/onboarding_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState({
    required this.currentPageIndex,
    required this.isLastPage,
    required this.isCompleted,
  });

  @override
  final int currentPageIndex;
  @override
  final bool isLastPage;
  @override
  final bool isCompleted;

  // 기본값이 필요하면 factory constructor 사용
  factory OnboardingState.initial() => const OnboardingState(
    currentPageIndex: 0,
    isLastPage: false,
    isCompleted: false,
  );
}
