// lib/typing/presentation/sentence_selection/sentence_selection_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'sentence_selection_notifier.dart';
import 'sentence_selection_screen.dart';
import 'sentence_selection_action.dart';

class SentenceSelectionScreenRoot extends ConsumerStatefulWidget {
  final String mode;
  final String language;

  const SentenceSelectionScreenRoot({
    super.key,
    required this.mode,
    required this.language,
  });

  @override
  ConsumerState<SentenceSelectionScreenRoot> createState() =>
      _SentenceSelectionScreenRootState();
}

class _SentenceSelectionScreenRootState
    extends ConsumerState<SentenceSelectionScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성된 후 초기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(sentenceSelectionNotifierProvider.notifier)
          .onAction(
            SentenceSelectionAction.initialize(widget.mode, widget.language),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sentenceSelectionNotifierProvider);
    final notifier = ref.watch(sentenceSelectionNotifierProvider.notifier);

    return SentenceSelectionScreen(
      sentences: state.sentences,
      mode: state.mode,
      language: state.language,
      onSentenceSelected: (sentence) {
        // 선택된 문장으로 연습 시작
        if (state.mode == 'word') {
          context.push(
            '/typing/word?language=${state.language}&sentenceId=${sentence.id}',
          );
        } else {
          context.push(
            '/typing/paragraph?language=${state.language}&sentenceId=${sentence.id}',
          );
        }
      },
      onRandomSelect: () async {
        // 랜덤 문장 선택 후 연습 시작
        await notifier.onAction(
          SentenceSelectionAction.getRandomSentence(state.mode, state.language),
        );

        final selectedSentence = ref
            .read(sentenceSelectionNotifierProvider)
            .selectedSentence;
        if (selectedSentence != null) {
          if (state.mode == 'word') {
            context.push(
              '/typing/word?language=${state.language}&sentenceId=${selectedSentence.id}',
            );
          } else {
            context.push(
              '/typing/paragraph?language=${state.language}&sentenceId=${selectedSentence.id}',
            );
          }
        }
      },
      onLanguageChanged: (newLanguage) async {
        // 언어 변경
        await notifier.onAction(
          SentenceSelectionAction.changeLanguage(newLanguage),
        );
      },
    );
  }
}
