// lib/splash/presentation/splash_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'splash_state.dart';
import 'splash_action.dart';

part 'splash_notifier.g.dart';

@riverpod
class SplashNotifier extends _$SplashNotifier {
  @override
  SplashState build() {
    // 앱 시작 시 초기화 자동 실행
    _initialize();
    return const SplashState();
  }

  Future<void> onAction(SplashAction action) async {
    switch (action) {
      case Initialize():
        await _initialize();
      case NavigateToOnboarding():
        _completeAnimation();
    }
  }

  Future<void> _initialize() async {
    // Firebase 초기화, 앱 설정 등의 작업 수행
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(isInitialized: true);
  }

  void _completeAnimation() {
    state = state.copyWith(isAnimationCompleted: true);
  }
}
