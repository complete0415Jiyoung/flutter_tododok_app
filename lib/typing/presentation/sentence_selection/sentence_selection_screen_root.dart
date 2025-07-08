// lib/typing/presentation/sentence_selection/sentence_selection_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'sentence_selection_notifier.dart';
import 'sentence_selection_screen.dart';
import 'sentence_selection_action.dart';
import '../../domain/enum/typing_enums.dart';

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
  late final PracticeMode practiceMode;
  late final Language language;

  @override
  void initState() {
    super.initState();

    // String을 enum으로 변환
    practiceMode = PracticeMode.fromValue(widget.mode);
    language = Language.fromCode(widget.language);

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
      mode: practiceMode,
      language: language,
      onSentenceSelected: (sentence) {
        // 선택된 문장으로 연습 시작
        _navigateToTypingScreen(sentence.id);
      },
      onRandomSelect: () async {
        // 랜덤 문장 선택 후 연습 시작
        await notifier.onAction(
          SentenceSelectionAction.getRandomSentence(
            widget.mode,
            widget.language,
          ),
        );

        final selectedSentence = ref
            .read(sentenceSelectionNotifierProvider)
            .selectedSentence;
        if (selectedSentence != null) {
          _navigateToTypingScreen(selectedSentence.id);
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

  void _navigateToTypingScreen(String sentenceId) {
    if (practiceMode.isWord) {
      context.push(
        '/typing/word?language=${language.code}&sentenceId=$sentenceId',
      );
    } else {
      context.push(
        '/typing/paragraph?language=${language.code}&sentenceId=$sentenceId',
      );
    }
  }
}
