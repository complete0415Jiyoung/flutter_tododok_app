// lib/typing/presentation/word_practice/widgets/simple_progress_bar_widget.dart

import 'package:flutter/material.dart';
import '../word_practice_state.dart';

class SimpleProgressBarWidget extends StatelessWidget {
  final WordPracticeState state;

  const SimpleProgressBarWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.wordSequence.isEmpty
        ? 0.0
        : state.currentWordIndex / state.wordSequence.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       '게임 진행률',
          //       style: Theme.of(
          //         context,
          //       ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          //     ),
          //     Text(
          //       '${state.currentWordIndex} / ${state.wordSequence.length}',
          //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //         color: Theme.of(context).colorScheme.primary,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 8),

          // 진행률 바
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width:
                    MediaQuery.of(context).size.width * progress * 0.9, // 패딩 고려
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
