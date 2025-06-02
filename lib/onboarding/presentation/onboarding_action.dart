// lib/onboarding/presentation/onboarding_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_action.freezed.dart';

@freezed
sealed class OnboardingAction with _$OnboardingAction {
  const factory OnboardingAction.nextPage() = NextPage;
  const factory OnboardingAction.previousPage() = PreviousPage;
  const factory OnboardingAction.skipOnboarding() = SkipOnboarding;
  const factory OnboardingAction.completeOnboarding() = CompleteOnboarding;
}
