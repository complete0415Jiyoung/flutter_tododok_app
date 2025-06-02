// lib/splash/presentation/splash_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'splash_state.freezed.dart';

@freezed
class SplashState with _$SplashState {
  const SplashState({
    this.isInitialized = false,
    this.isAnimationCompleted = false,
  });

  @override
  final bool isInitialized;
  @override
  final bool isAnimationCompleted;
}
