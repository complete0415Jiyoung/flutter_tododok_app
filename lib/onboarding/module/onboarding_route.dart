// lib/onboarding/module/onboarding_route.dart
import 'package:go_router/go_router.dart';
import '../presentation/onboarding_screen_root.dart';

final onboardingRoutes = [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => const OnboardingScreenRoot(),
  ),
];
