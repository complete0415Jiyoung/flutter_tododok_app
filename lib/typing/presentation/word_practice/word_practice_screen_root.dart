// lib/typing/presentation/word_practice/word_practice_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'word_practice_notifier.dart';
import 'word_practice_screen.dart';
import 'word_practice_action.dart';

class WordPracticeScreenRoot extends ConsumerStatefulWidget {
  final String? language;
  final String? sentenceId;
  final bool? random;

  const WordPracticeScreenRoot({
    super.key,
    this.language,
    this.sentenceId,
    this.random,
  });

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
      final notifier = ref.read(wordPracticeNotifierProvider.notifier);

      // 파라미터에 따른 초기화 분기
      if (widget.sentenceId != null) {
        // 특정 문장으로 초기화
        notifier.onAction(
          WordPracticeAction.initializeWithSentence(
            language,
            widget.sentenceId!,
          ),
        );
      } else if (widget.random == true) {
        // 랜덤 문장으로 초기화
        notifier.onAction(WordPracticeAction.initializeWithRandom(language));
      } else {
        // 기본 초기화
        notifier.onAction(WordPracticeAction.initialize(language));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordPracticeNotifierProvider);
    final notifier = ref.watch(wordPracticeNotifierProvider.notifier);

    // 게임 상태 변화 리스너
    ref.listen(wordPracticeNotifierProvider, (previous, next) {
      // 게임이 완료되었을 때의 처리
      if (previous?.isGameOver == false && next.isGameOver == true) {
        // 게임 완료 시 햅틱 피드백이나 사운드 효과 등을 여기서 처리할 수 있음
        // HapticFeedback.notificationFeedback();
      }

      // 힌트 사용 시 처리
      if (previous?.hintsUsed != next.hintsUsed &&
          next.hintsUsed > (previous?.hintsUsed ?? 0)) {
        // 힌트 사용 시 효과
        // HapticFeedback.lightImpact();
      }
    });

    return PopScope(
      // 시스템 뒤로가기 버튼(제스처)만 제한하고, 앱바 뒤로가기는 허용
      canPop: true, // 항상 true로 설정하여 앱바 뒤로가기 허용
      onPopInvokedWithResult: (didPop, result) {
        // 게임이 실행 중이고 시스템 뒤로가기로 나갈 때만 처리
        if (didPop && state.isGameRunning && !state.isPaused) {
          // 게임 종료 처리 (선택사항)
          notifier.onAction(const WordPracticeAction.endGame());
        }
      },
      child: WordPracticeScreen(
        state: state,
        onAction: (action) async {
          switch (action) {
            case NavigateToResult():
              // 결과 화면으로 이동 (게임 결과 포함)
              final queryParams = {
                'type': 'practice',
                'mode': 'word',
                'typingSpeed': state.wpm.toStringAsFixed(0), // WPM 사용
                'accuracy': state.accuracy.toStringAsFixed(1),
                'duration': state.elapsedSeconds.toStringAsFixed(1),
                'language': state.language,
                'sentenceLength': state.wordSequence.length.toString(),
                'typos': state.incorrectWordsCount.toString(),
                'score': state.score.toString(),
                'correctWords': state.correctWordsCount.toString(),
                'totalWords': state.wordSequence.length.toString(),
                'hintsUsed': state.hintsUsed.toString(),
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

            case NavigateToSentenceSelection():
              // 문장 선택 화면으로 이동
              await context.push(
                '/typing/sentence-selection?mode=word&language=${state.language}',
              );

            // 모든 게임 로직은 notifier에게 위임
            case Initialize():
            case InitializeWithSentence():
            case InitializeWithRandom():
            case StartGame():
            case PauseGame():
            case ResumeGame():
            case RestartGame():
            case EndGame():
            case UpdateInput():
            case SubmitCurrentWord():
            case SkipCurrentWord():
            case ClearInput():
            case MoveToNextWord():
            case MoveToPreviousWord():
            case CompleteCurrentWord():
            case ShowHint():
            case HideHint():
            case UseHint():
            case UpdateStatistics():
            case CalculateWpm():
            case CalculateAccuracy():
            case LoadWordSequence():
            case GenerateNewSequence():
            case CompleteSequence():
            case ChangeLanguage():
            case SetTargetWordCount():
            case HandleError():
            case ClearError():
            case CheckGameCompletion():
            case ValidateInput():
            case StartTimer():
            case StopTimer():
            case UpdateTimer():
              // 모든 게임 로직은 notifier에게 위임
              await notifier.onAction(action);
          }
        },
      ),
    );
  }
}
