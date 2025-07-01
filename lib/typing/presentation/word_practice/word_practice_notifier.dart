// lib/typing/presentation/word_practice/word_practice_notifier.dart
import 'dart:async';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/usecase/get_sentences_use_case.dart';
import '../../domain/usecase/save_typing_result_use_case.dart';
import '../../domain/model/typing_result.dart';
import '../../domain/model/sentence.dart';
import '../../module/typing_di.dart';
import 'word_practice_state.dart';
import 'word_practice_action.dart';

part 'word_practice_notifier.g.dart';

@riverpod
class WordPracticeNotifier extends _$WordPracticeNotifier {
  late final GetSentencesUseCase _getSentencesUseCase;
  late final SaveTypingResultUseCase _saveTypingResultUseCase;

  Timer? _gameTimer;
  final Random _random = Random();

  @override
  WordPracticeState build() {
    _getSentencesUseCase = ref.watch(getSentencesUseCaseProvider);
    _saveTypingResultUseCase = ref.watch(saveTypingResultUseCaseProvider);

    return const WordPracticeState();
  }

  @override
  void dispose() {
    _stopTimer();
  }

  Future<void> onAction(WordPracticeAction action) async {
    switch (action) {
      case Initialize(:final language):
        await _initialize(language);
      case InitializeWithSentence(:final language, :final sentenceId):
        await _initializeWithSentence(language, sentenceId);
      case InitializeWithRandom(:final language):
        await _initializeWithRandom(language);
      case StartGame():
        _startGame();
      case PauseGame():
        _pauseGame();
      case ResumeGame():
        _resumeGame();
      case RestartGame():
        _restartGame();
      case EndGame():
        _endGame();
      case UpdateInput(:final input):
        _updateInput(input);
      case SubmitCurrentWord():
        _submitCurrentWord();
      case SkipCurrentWord():
        _skipCurrentWord();
      case ClearInput():
        _clearInput();
      case MoveToNextWord():
        _moveToNextWord();
      case MoveToPreviousWord():
        _moveToPreviousWord();
      case CompleteCurrentWord(:final isCorrect, :final timeTaken):
        _completeCurrentWord(isCorrect, timeTaken);
      case ShowHint():
        _showHint();
      case HideHint():
        _hideHint();
      case UseHint():
        _useHint();
      case UpdateStatistics():
        _updateStatistics();
      case CalculateWpm():
        _calculateWpm();
      case CalculateAccuracy():
        _calculateAccuracy();
      case LoadWordSequence(:final sentenceText, :final sentenceId):
        _loadWordSequence(sentenceText, sentenceId);
      case GenerateNewSequence():
        await _generateNewSequence();
      case CompleteSequence():
        _completeSequence();
      case ChangeLanguage(:final language):
        await _changeLanguage(language);
      case SetTargetWordCount(:final count):
        _setTargetWordCount(count);
      case HandleError(:final errorMessage):
        _handleError(errorMessage);
      case ClearError():
        _clearError();
      case CheckGameCompletion():
        _checkGameCompletion();
      case ValidateInput():
        _validateInput();
      case StartTimer():
        _startTimer();
      case StopTimer():
        _stopTimer();
      case UpdateTimer():
        _updateTimer();
      case NavigateToResult():
      case NavigateToHome():
      case NavigateToSentenceSelection():
        // 네비게이션은 Root에서 처리
        break;
    }
  }

  Future<void> _initialize(String language) async {
    try {
      state = state.copyWith(
        language: language,
        availableSentences: const AsyncLoading(),
      );

      final sentencesResult = await _getSentencesUseCase.execute(
        'word',
        language,
      );
      state = state.copyWith(availableSentences: sentencesResult);
    } catch (e) {
      state = state.copyWith(
        availableSentences: AsyncError(e, StackTrace.current),
      );
    }
  }

  Future<void> _initializeWithSentence(
    String language,
    String sentenceId,
  ) async {
    await _initialize(language);

    final sentences = state.availableSentences.valueOrNull;
    if (sentences != null) {
      final sentence = sentences.firstWhere(
        (s) => s.id == sentenceId,
        orElse: () => sentences.first,
      );
      _loadWordSequence(sentence.content, sentence.id);
    }
  }

  Future<void> _initializeWithRandom(String language) async {
    await _initialize(language);

    final sentences = state.availableSentences.valueOrNull;
    if (sentences != null && sentences.isNotEmpty) {
      final randomSentence = sentences[_random.nextInt(sentences.length)];
      _loadWordSequence(randomSentence.content, randomSentence.id);
    }
  }

  void _startGame() {
    if (state.wordSequence.isEmpty) return;

    state = state.copyWith(
      isGameRunning: true,
      isGameOver: false,
      isPaused: false,
      gameStartTime: DateTime.now(),
      currentWordIndex: 0,
      currentWordInput: '',
      correctWordsCount: 0,
      incorrectWordsCount: 0,
      skippedWordsCount: 0,
      totalCharactersTyped: 0,
      wpm: 0.0,
      typingSpeed: 0.0, // 새로운 분당 타수 초기화
      accuracy: 0.0,
      score: 0,
      hintsUsed: 0,
      hintsRemaining: 3,
      showHint: false,
    );

    _startTimer();
  }

  void _pauseGame() {
    if (!state.isGameRunning || state.isPaused) return;

    state = state.copyWith(isPaused: true);
    _stopTimer();
  }

  void _resumeGame() {
    if (!state.isGameRunning || !state.isPaused) return;

    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  void _restartGame() {
    _stopTimer();
    _startGame();
  }

  void _endGame() {
    _stopTimer();

    state = state.copyWith(
      isGameRunning: false,
      isGameOver: true,
      isPaused: false,
    );

    // 최종 통계 계산
    _updateStatistics();

    // 결과 자동 저장
    _saveResult();
  }

  void _updateInput(String input) {
    if (!state.isGameRunning || state.isPaused || state.isGameOver) return;

    state = state.copyWith(currentWordInput: input);
  }

  void _submitCurrentWord() {
    if (state.currentWord == null) return;

    final isCorrect = state.currentWordInput.trim() == state.currentWord!.text;
    final timeTaken = state.elapsedSeconds; // 간단한 계산

    _completeCurrentWord(isCorrect, timeTaken);
  }

  void _skipCurrentWord() {
    if (state.currentWord == null) return;

    state = state.copyWith(
      skippedWordsCount: state.skippedWordsCount + 1,
      currentWordInput: '',
    );

    _moveToNextWord();
  }

  void _clearInput() {
    state = state.copyWith(currentWordInput: '');
  }

  void _moveToNextWord() {
    if (state.currentWordIndex < state.wordSequence.length - 1) {
      state = state.copyWith(
        currentWordIndex: state.currentWordIndex + 1,
        currentWordInput: '',
        showHint: false,
      );
    } else {
      _completeSequence();
    }
  }

  void _moveToPreviousWord() {
    if (state.currentWordIndex > 0) {
      state = state.copyWith(
        currentWordIndex: state.currentWordIndex - 1,
        currentWordInput: '',
        showHint: false,
      );
    }
  }

  void _completeCurrentWord(bool isCorrect, double timeTaken) {
    if (state.currentWord == null) return;

    state = state.copyWith(
      correctWordsCount: isCorrect
          ? state.correctWordsCount + 1
          : state.correctWordsCount,
      incorrectWordsCount: !isCorrect
          ? state.incorrectWordsCount + 1
          : state.incorrectWordsCount,
      totalCharactersTyped:
          state.totalCharactersTyped + state.currentWordInput.length,
      score: isCorrect
          ? state.score +
                _calculateWordScore(state.currentWord!.text.length, timeTaken)
          : state.score,
    );

    _updateStatistics();
    _moveToNextWord();
  }

  int _calculateWordScore(int wordLength, double timeTaken) {
    // 단어 길이와 입력 시간을 고려한 점수 계산
    final baseScore = wordLength * 10;
    final timeBonus = timeTaken < 2.0
        ? 20
        : timeTaken < 5.0
        ? 10
        : 0;
    return baseScore + timeBonus;
  }

  void _showHint() {
    if (state.hintsRemaining > 0) {
      state = state.copyWith(showHint: true);
    }
  }

  void _hideHint() {
    state = state.copyWith(showHint: false);
  }

  void _useHint() {
    if (state.hintsRemaining > 0) {
      state = state.copyWith(
        hintsUsed: state.hintsUsed + 1,
        hintsRemaining: state.hintsRemaining - 1,
        showHint: true,
      );
    }
  }

  void _updateStatistics() {
    _calculateWpm();
    _calculateAccuracy();
  }

  void _calculateWpm() {
    final elapsedMinutes = state.elapsedSeconds / 60.0;
    if (elapsedMinutes > 0) {
      // 분당 타수 계산 (실제로는 CPM)
      final totalCharactersTyped = state.totalCharactersTyped;
      final typingSpeed = totalCharactersTyped / elapsedMinutes;

      // 기존 WPM 계산 (호환성 유지 - 단어 기준)
      final wordsPerMinute = state.correctWordsCount / elapsedMinutes;

      state = state.copyWith(
        typingSpeed: typingSpeed, // 새로운 분당 타수 필드
        wpm: wordsPerMinute, // 기존 WPM 유지 (단어 기준)
      );
    }
  }

  void _calculateAccuracy() {
    final totalAttempts = state.correctWordsCount + state.incorrectWordsCount;
    if (totalAttempts > 0) {
      final accuracy = (state.correctWordsCount / totalAttempts) * 100;
      state = state.copyWith(accuracy: accuracy);
    }
  }

  void _loadWordSequence(String sentenceText, String sentenceId) {
    final words = sentenceText
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();

    final wordSequence = words.asMap().entries.map((entry) {
      return PracticeWord(text: entry.value.trim(), position: entry.key);
    }).toList();

    // 목표 단어 수만큼만 사용
    final limitedSequence = wordSequence.take(state.targetWordCount).toList();

    state = state.copyWith(
      wordSequence: limitedSequence,
      currentSentenceText: sentenceText,
      currentSentenceId: sentenceId,
      currentWordIndex: 0,
      currentWordInput: '',
    );
  }

  Future<void> _generateNewSequence() async {
    final sentences = state.availableSentences.valueOrNull;
    if (sentences != null && sentences.isNotEmpty) {
      final randomSentence = sentences[_random.nextInt(sentences.length)];
      _loadWordSequence(randomSentence.content, randomSentence.id);
    } else {
      // 문장이 없으면 새로 로드
      final sentencesResult = await _getSentencesUseCase.execute(
        'word',
        state.language,
      );
      sentencesResult.when(
        data: (sentences) {
          if (sentences.isNotEmpty) {
            final randomSentence = sentences[_random.nextInt(sentences.length)];
            _loadWordSequence(randomSentence.content, randomSentence.id);
          }
        },
        loading: () {},
        error: (error, stackTrace) {},
      );
    }
  }

  void _completeSequence() {
    _endGame();
  }

  Future<void> _changeLanguage(String language) async {
    await _initialize(language);
  }

  void _setTargetWordCount(int count) {
    state = state.copyWith(targetWordCount: count);
  }

  void _handleError(String errorMessage) {
    // 에러 처리 로직
  }

  void _clearError() {
    // 에러 클리어 로직
  }

  void _checkGameCompletion() {
    if (state.isSequenceCompleted) {
      _completeSequence();
    }
  }

  void _validateInput() {
    // 입력 검증 로직은 state의 getter에서 처리됨
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(); // elapsedSeconds getter 업데이트를 위한 state 갱신
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _updateTimer() {
    // 타이머 업데이트는 _startTimer에서 자동으로 처리됨
  }

  Future<void> _saveResult() async {
    try {
      final result = TypingResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // TODO: 실제 사용자 ID로 교체
        type: 'practice',
        mode: 'word',
        sentenceId: state.currentSentenceId,
        sentenceContent: state.currentSentenceText,
        typingSpeed: state.typingSpeed, // 새로운 분당 타수 필드 사용
        accuracy: state.accuracy,
        typoCount: state.incorrectWordsCount,
        totalCharacters: state.totalCharactersTyped,
        correctCharacters:
            state.totalCharactersTyped - state.incorrectWordsCount,
        duration: state.elapsedSeconds,
        language: state.language,
        createdAt: DateTime.now(),
      );

      await _saveTypingResultUseCase.execute(result);
    } catch (e) {
      // 결과 저장 실패 처리
    }
  }
}
