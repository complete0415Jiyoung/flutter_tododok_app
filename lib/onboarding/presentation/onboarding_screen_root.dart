// lib/onboarding/presentation/onboarding_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_notifier.dart';
import 'onboarding_screen.dart';
import 'onboarding_action.dart';

class OnboardingScreenRoot extends ConsumerWidget {
  const OnboardingScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.watch(onboardingNotifierProvider.notifier);

    // 온보딩 완료 시 홈 화면으로 이동
    ref.listen(onboardingNotifierProvider, (previous, next) {
      if (next.isCompleted) {
        context.go('/home');
      }
    });

    return OnboardingScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case SkipOnboarding():
          case CompleteOnboarding():
            // 온보딩 완료 처리는 notifier에서 하고,
            // 실제 화면 이동은 listen에서 처리
            await notifier.onAction(action);
          default:
            await notifier.onAction(action);
        }
      },
    );
  }
}
