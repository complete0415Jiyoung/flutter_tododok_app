// lib/typing/presentation/word_practice/widgets/simple_circular_carousel.dart
// 더 간단하고 부드러운 버전

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../word_practice_state.dart';

class SimpleCircularCarousel extends StatefulWidget {
  final WordPracticeState state;

  const SimpleCircularCarousel({super.key, required this.state});

  @override
  State<SimpleCircularCarousel> createState() => _SimpleCircularCarouselState();
}

class _SimpleCircularCarouselState extends State<SimpleCircularCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 2 * math.pi / 6, // 60도 회전
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
  }

  @override
  void didUpdateWidget(SimpleCircularCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 단어가 변경되면 회전
    if (oldWidget.state.currentWordIndex != widget.state.currentWordIndex) {
      _controller.forward().then((_) {
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.state.wordSequence;
    if (words.isEmpty) return const SizedBox.shrink();

    final currentIndex = widget.state.currentWordIndex;

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 현재 단어
          _buildCurrentWord(),

          // 회전하는 다음 단어들
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 다음 3개 단어를 원형으로 배치
                  for (int i = 1; i <= 3; i++)
                    if (currentIndex + i < words.length)
                      _buildOrbitingWord(words[currentIndex + i].text, i, 3),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWord() {
    final currentWord = widget.state.currentWord;
    if (currentWord == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        currentWord.text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrbitingWord(String word, int position, int total) {
    // 원형 배치 계산
    final angle =
        (2 * math.pi / total) * (position - 1) + _rotationAnimation.value;
    final radius = 80.0;
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    // 거리에 따른 투명도와 크기 조절
    final opacity = 1.0 - (position * 0.2);
    final scale = 1.0 - (position * 0.15);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              word,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
