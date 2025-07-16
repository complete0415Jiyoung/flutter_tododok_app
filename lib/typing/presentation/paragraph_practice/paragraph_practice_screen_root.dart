// lib/typing/presentation/paragraph_practice/paragraph_practice_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'paragraph_practice_notifier.dart';
import 'paragraph_practice_screen.dart';
import 'paragraph_practice_action.dart';

class ParagraphPracticeScreenRoot extends ConsumerStatefulWidget {
  final String? language;
  final String? sentenceId;
  final bool? random;

  const ParagraphPracticeScreenRoot({
    super.key,
    this.language,
    this.sentenceId,
    this.random,
  });

  @override
  ConsumerState<ParagraphPracticeScreenRoot> createState() =>
      _ParagraphPracticeScreenRootState();
}

class _ParagraphPracticeScreenRootState
    extends ConsumerState<ParagraphPracticeScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성된 후 초기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language = widget.language ?? 'ko';
      final notifier = ref.read(paragraphPracticeNotifierProvider.notifier);

      notifier.onAction(ParagraphPracticeAction.initialize(language));

      // 특정 문장이 지정된 경우
      if (widget.sentenceId != null) {
        notifier.onAction(
          ParagraphPracticeAction.selectSentence(widget.sentenceId!),
        );
      }
      // 랜덤 문장 선택인 경우
      else if (widget.random == true) {
        notifier.onAction(const ParagraphPracticeAction.selectRandomSentence());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paragraphPracticeNotifierProvider);
    final notifier = ref.watch(paragraphPracticeNotifierProvider.notifier);

    // 연습 완료 시 결과 저장 완료 후 추가 처리할 수 있도록 리스너 추가
    ref.listen(paragraphPracticeNotifierProvider, (previous, next) {
      // 연습이 방금 완료되었을 때
      if (previous?.isCompleted == false && next.isCompleted == true) {
        // 완료 시 햅틱 피드백
        // HapticFeedback.lightImpact();
      }
    });

    return PopScope(
      // 뒤로가기 버튼 눌렀을 때 연습 중이면 일시정지
      canPop:
          !(state.isStarted ?? false) ||
          (state.isPaused ?? false) ||
          (state.isCompleted ?? false),
      onPopInvoked: (didPop) {
        if (!didPop &&
            (state.isStarted ?? false) &&
            !(state.isPaused ?? false) &&
            !(state.isCompleted ?? false)) {
          notifier.onAction(const ParagraphPracticeAction.pausePractice());
        }
      },
      child: ParagraphPracticeScreen(
        state: state,
        onAction: (action) async {
          switch (action) {
            case NavigateToResult():
              // 새로운 결과 화면으로 이동
              final queryParams = {
                'type': 'practice',
                'mode': 'paragraph',
                'typingSpeed': (state.typingSpeed ?? 0.0).toStringAsFixed(0),
                'accuracy': (state.accuracy ?? 0.0).toStringAsFixed(1),
                'duration': state.elapsedSeconds.toStringAsFixed(1),
                'language': state.language ?? 'ko',
                'sentenceLength': state.totalSentenceLength.toString(),
                'typos': state.incorrectCharacters
                    .toString(), // totalTypos 대신 incorrectCharacters 사용
              };
              await context.push(
                Uri(
                  path: '/typing/result',
                  queryParameters: queryParams,
                ).toString(),
              );

            case NavigateToHome():
              // 홈으로 돌아가기
              context.go('/home');

            case CreateChallenge():
              // 도전장 생성 화면으로 이동
              final challengeParams = {
                'sentenceId': state.currentSentence?.id ?? '',
                'mode': 'paragraph',
                'language': state.language ?? 'ko',
                'myTypingSpeed': (state.typingSpeed ?? 0.0).toStringAsFixed(1),
                'myAccuracy': (state.accuracy ?? 0.0).toStringAsFixed(1),
                'duration': state.elapsedSeconds.toStringAsFixed(1),
              };
              await context.push(
                Uri(
                  path: '/challenge/create',
                  queryParameters: challengeParams,
                ).toString(),
              );

            case PracticeAnotherSentence():
              // 문장 선택 화면으로 이동
              await context.push(
                '/typing/sentence-selection?mode=paragraph&language=${state.language ?? 'ko'}',
              );

            // 🔥 새로 추가: 다음 줄 이동 액션 처리
            case MoveToNextLine():
            case SaveResult():
            case Initialize():
            case SelectSentence():
            case SelectRandomSentence():
            case StartPractice():
            case PausePractice():
            case ResumePractice():
            case RestartPractice():
            case CompletePractice():
            case UpdateInput():
            case HandleBackspace():
            case InputCharacter():
            case UpdateStats():
            case ChangeLanguage():
              // 모든 연습 로직은 notifier에게 위임
              await notifier.onAction(action);
          }
        },
      ),
    );
  }
}
