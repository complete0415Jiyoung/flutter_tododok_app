// lib/typing/presentation/sentence_selection/sentence_selection_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecase/get_sentences_use_case.dart';
import '../../domain/usecase/get_random_sentence_use_case.dart';
import '../../domain/model/sentence.dart';
import '../../module/typing_di.dart';
import 'sentence_selection_state.dart';
import 'sentence_selection_action.dart';

part 'sentence_selection_notifier.g.dart';

@riverpod
class SentenceSelectionNotifier extends _$SentenceSelectionNotifier {
  late final GetSentencesUseCase _getSentencesUseCase;
  late final GetRandomSentenceUseCase _getRandomSentenceUseCase;

  @override
  SentenceSelectionState build() {
    _getSentencesUseCase = ref.watch(getSentencesUseCaseProvider);
    _getRandomSentenceUseCase = ref.watch(getRandomSentenceUseCaseProvider);

    return const SentenceSelectionState();
  }

  Future<void> onAction(SentenceSelectionAction action) async {
    switch (action) {
      case Initialize(:final mode, :final language):
        await _initialize(mode, language);
      case LoadSentences(:final mode, :final language):
        await _loadSentences(mode, language);
      case SelectSentence(:final sentence):
        _selectSentence(sentence);
      case GetRandomSentence(:final mode, :final language):
        await _getRandomSentence(mode, language);
      case ChangeLanguage(:final language):
        await _changeLanguage(language);
    }
  }

  Future<void> _initialize(String mode, String language) async {
    state = state.copyWith(mode: mode, language: language, isLoading: true);

    await _loadSentences(mode, language);
  }

  Future<void> _loadSentences(String mode, String language) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      sentences: const AsyncLoading(),
    );

    final result = await _getSentencesUseCase.execute(mode, language);

    result.when(
      data: (sentences) {
        state = state.copyWith(
          sentences: AsyncData(sentences),
          isLoading: false,
        );
      },
      loading: () {
        state = state.copyWith(
          sentences: const AsyncLoading(),
          isLoading: true,
        );
      },
      error: (error, stackTrace) {
        state = state.copyWith(
          sentences: AsyncError(error, stackTrace),
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _selectSentence(Sentence sentence) {
    state = state.copyWith(selectedSentence: sentence);
  }

  Future<void> _getRandomSentence(String mode, String language) async {
    final result = await _getRandomSentenceUseCase.execute(mode, language);

    result.when(
      data: (sentence) {
        state = state.copyWith(selectedSentence: sentence);
      },
      loading: () {},
      error: (error, stackTrace) {
        state = state.copyWith(
          errorMessage: '랜덤 문장을 가져올 수 없습니다: ${error.toString()}',
        );
      },
    );
  }

  Future<void> _changeLanguage(String language) async {
    state = state.copyWith(language: language);
    await _loadSentences(state.mode, language);
  }
}
