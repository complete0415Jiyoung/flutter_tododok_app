// lib/splash/presentation/splash_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_action.freezed.dart';

@freezed
sealed class SplashAction with _$SplashAction {
  const factory SplashAction.initialize() = Initialize;
  const factory SplashAction.navigateToOnboarding() = NavigateToOnboarding;
}
