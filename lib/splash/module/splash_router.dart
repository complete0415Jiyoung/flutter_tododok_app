// lib/splash/module/splash_route.dart
import 'package:go_router/go_router.dart';
import '../presentation/splash_screen_root.dart';

final splashRoutes = [
  GoRoute(
    path: '/splash',
    builder: (context, state) => const SplashScreenRoot(),
  ),
];
