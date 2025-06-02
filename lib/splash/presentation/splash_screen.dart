// lib/splash/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import '../../shared/styles/app_colors_style.dart';
import '../../shared/styles/app_dimensions.dart';
import 'splash_state.dart';
import 'splash_action.dart';

class SplashScreen extends StatefulWidget {
  final SplashState state;
  final void Function(SplashAction action) onAction;

  const SplashScreen({super.key, required this.state, required this.onAction});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppDimensions.animationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.primary,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: AppDimensions.spacing32),
        _buildAppName(),
        const SizedBox(height: AppDimensions.spacing8),
        _buildAppSubtitle(),
        const SizedBox(height: AppDimensions.spacing48),
        _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColorsStyle.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.keyboard,
        size: 64,
        color: AppColorsStyle.primary,
      ),
    );
  }

  Widget _buildAppName() {
    return const Text(
      '토도독',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColorsStyle.white,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildAppSubtitle() {
    return const Text(
      'TODODOK',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColorsStyle.white,
        letterSpacing: 4.0,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return widget.state.isInitialized
        ? const Icon(Icons.check_circle, color: AppColorsStyle.white, size: 24)
        : const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColorsStyle.white,
              strokeWidth: 2.0,
            ),
          );
  }
}
