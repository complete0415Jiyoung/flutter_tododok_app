// lib/typing/presentation/word_practice/widgets/word_progress_widget.dart

import 'package:flutter/material.dart';
import '../word_practice_state.dart';

class WordProgressWidget extends StatelessWidget {
  final WordPracticeState state;

  const WordProgressWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.wordSequence.isEmpty
        ? 0.0
        : state.currentWordIndex / state.wordSequence.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '게임 진행상황',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${state.currentWordIndex} / ${state.wordSequence.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 진행률 바
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width:
                    MediaQuery.of(context).size.width *
                    progress *
                    0.85, // 패딩 고려
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 상세 통계
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(
                context,
                '정답',
                state.correctWordsCount,
                Colors.green,
                Icons.check_circle,
              ),
              _buildProgressItem(
                context,
                '오답',
                state.incorrectWordsCount,
                Colors.red,
                Icons.error,
              ),
              _buildProgressItem(
                context,
                '건너뜀',
                state.skippedWordsCount,
                Colors.grey,
                Icons.skip_next,
              ),
              _buildProgressItem(
                context,
                '남은 단어',
                state.wordSequence.length - state.currentWordIndex,
                Colors.blue,
                Icons.pending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
