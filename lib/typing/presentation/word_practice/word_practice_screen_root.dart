// lib/typing/presentation/word_practice/word_practice_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'word_practice_notifier.dart';
import 'word_practice_screen.dart';
import 'word_practice_action.dart';

class WordPracticeScreenRoot extends ConsumerStatefulWidget {
  final String? language;

  const WordPracticeScreenRoot({super.key, this.language});

  @override
  ConsumerState<WordPracticeScreenRoot> createState() =>
      _WordPracticeScreenRootState();
}

class _WordPracticeScreenRootState
    extends ConsumerState<WordPracticeScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성된 후 초기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language = widget.language ?? 'ko';
      ref
          .read(wordPracticeNotifierProvider.notifier)
          .onAction(WordPracticeAction.initialize(language));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordPracticeNotifierProvider);
    final notifier = ref.watch(wordPracticeNotifierProvider.notifier);

    // 게임 오버 시 결과 저장 완료 후 결과 화면으로 이동할 수 있도록 리스너 추가
    ref.listen(wordPracticeNotifierProvider, (previous, next) {
      // 게임이 방금 끝났을 때의 처리 (필요시)
      if (previous?.isGameOver == false && next.isGameOver == true) {
        // 게임 오버 시 추가 처리 (예: 효과음, 진동 등)
      }
    });

    return PopScope(
      // 뒤로가기 버튼 눌렀을 때 게임이 실행 중이면 일시정지
      canPop: !state.isGameRunning,
      onPopInvoked: (didPop) {
        if (!didPop && state.isGameRunning) {
          notifier.onAction(const WordPracticeAction.pauseGame());
        }
      },
      child: WordPracticeScreen(
        state: state,
        onAction: (action) async {
          switch (action) {
            case NavigateToResult():
              // TODO: 결과 화면으로 이동 (게임 결과 포함)
              final queryParams = {
                'score': state.score.toString(),
                'level': state.level.toString(),
                'wpm': state.wpm.toStringAsFixed(1),
                'accuracy': state.accuracy.toStringAsFixed(1),
                'correctWords': state.correctWordsCount.toString(),
                'gameTime': state.elapsedSeconds.toStringAsFixed(1),
              };
              await context.push(
                Uri(
                  path: '/typing/result',
                  queryParameters: queryParams,
                ).toString(),
              );
            case NavigateToHome():
              // 홈으로 돌아가기 (게임 정리)
              context.go('/home');
            case StartGame():
            case PauseGame():
            case ResumeGame():
            case EndGame():
            case RestartGame():
            case SpawnWord():
            case UpdateFallingWords():
            case UpdateInput():
            case SubmitInput():
            case WordMatched():
            case WordMissed():
            case LevelUp():
            case ChangeLanguage():
            case Initialize():
              // 모든 게임 로직은 notifier에게 위임
              await notifier.onAction(action);
          }
        },
      ),
    );
  }
}
