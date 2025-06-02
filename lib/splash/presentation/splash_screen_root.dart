// lib/splash/presentation/splash_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'splash_notifier.dart';
import 'splash_screen.dart';
import 'splash_action.dart';

class SplashScreenRoot extends ConsumerWidget {
  const SplashScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splashNotifierProvider);
    final notifier = ref.watch(splashNotifierProvider.notifier);

    // 초기화 완료 후 온보딩으로 이동
    ref.listen(splashNotifierProvider, (previous, next) {
      if (next.isInitialized && !next.isAnimationCompleted) {
        // 애니메이션 완료 후 온보딩으로 이동
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go('/onboarding');
          }
        });
      }
    });

    return SplashScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case NavigateToOnboarding():
            await context.push('/onboarding');
          default:
            await notifier.onAction(action);
        }
      },
    );
  }
}
