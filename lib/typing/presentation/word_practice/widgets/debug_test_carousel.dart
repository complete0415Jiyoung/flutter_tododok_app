// lib/typing/presentation/word_practice/widgets/debug_test_carousel.dart
// 문제 확인을 위한 간단한 테스트 버전

import 'package:flutter/material.dart';
import '../word_practice_state.dart';

class DebugTestCarousel extends StatelessWidget {
  final WordPracticeState state;

  const DebugTestCarousel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    print('DebugTestCarousel build() 호출됨');
    print('현재 단어: ${state.currentWord?.text}');
    print('단어 시퀀스 길이: ${state.wordSequence.length}');
    print('현재 인덱스: ${state.currentWordIndex}');

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1), // 디버그용 배경색
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('테스트 캐러셀', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // 현재 단어
          if (state.currentWord != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '현재: ${state.currentWord!.text}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 다음 단어들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 1; i <= 3; i++)
                if (state.currentWordIndex + i < state.wordSequence.length)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '다음$i: ${state.wordSequence[state.currentWordIndex + i].text}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
