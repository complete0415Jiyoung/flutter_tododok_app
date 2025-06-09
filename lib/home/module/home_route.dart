// lib/home/module/home_route.dart
import 'package:go_router/go_router.dart';
import '../presentation/home_screen_root.dart';

final homeRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const HomeScreenRoot()),
];
