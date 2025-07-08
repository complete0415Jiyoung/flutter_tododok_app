// lib/typing/presentation/paragraph_practice/paragraph_practice_notifier.dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecase/get_sentences_use_case.dart';
import '../../domain/usecase/get_random_sentence_use_case.dart';
import '../../domain/usecase/save_typing_result_use_case.dart';
import '../../domain/model/typing_result.dart';
import '../../domain/model/typing_character_input.dart';
import '../../module/typing_di.dart';
import 'paragraph_practice_state.dart';
import 'paragraph_practice_action.dart';

part 'paragraph_practice_notifier.g.dart';

@riverpod
class ParagraphPracticeNotifier extends _$ParagraphPracticeNotifier {
  late final GetSentencesUseCase _getSentencesUseCase;
  late final GetRandomSentenceUseCase _getRandomSentenceUseCase;
  late final SaveTypingResultUseCase _saveTypingResultUseCase;

  Timer? _statsTimer;
  DateTime? _lastInputTime;

  @override
  ParagraphPracticeState build() {
    _getSentencesUseCase = ref.watch(getSentencesUseCaseProvider);
    _getRandomSentenceUseCase = ref.watch(getRandomSentenceUseCaseProvider);
    _saveTypingResultUseCase = ref.watch(saveTypingResultUseCaseProvider);

    // 🔥 수정: .initial() 제거하고 기본 생성자 사용
    return const ParagraphPracticeState();
  }

  // 🔥 수정: dispose 메서드 제거 (Riverpod 2.x에서는 자동 처리)

  Future<void> onAction(ParagraphPracticeAction action) async {
    switch (action) {
      case Initialize(:final language):
        await _initialize(language);
      case SelectSentence(:final sentenceId):
        await _selectSentence(sentenceId);
      case SelectRandomSentence():
        await _selectRandomSentence();
      case StartPractice():
        _startPractice();
      case PausePractice():
        _pausePractice();
      case ResumePractice():
        _resumePractice();
      case RestartPractice():
        _restartPractice();
      case CompletePractice():
        _completePractice();
      case UpdateInput(:final input):
        _updateInput(input);
      case HandleBackspace():
        _handleBackspace();
      case InputCharacter(:final character):
        _inputCharacter(character);
      case UpdateStats():
        _updateStats();
      case ChangeLanguage(:final language):
        await _changeLanguage(language);
      case SaveResult():
        await _saveResult();
      case NavigateToResult():
      case NavigateToHome():
      case CreateChallenge():
      case PracticeAnotherSentence():
        // 네비게이션 액션들은 Root에서 처리
        break;
    }
  }

  /// 문장을 20자씩 분할하는 함수
  List<String> _splitSentenceIntoLines(
    String sentence, {
    int charsPerLine = 20,
  }) {
    if (sentence.isEmpty) return [];

    final List<String> lines = [];
    for (int i = 0; i < sentence.length; i += charsPerLine) {
      final end = (i + charsPerLine > sentence.length)
          ? sentence.length
          : i + charsPerLine;
      lines.add(sentence.substring(i, end));
    }
    return lines;
  }

  /// 현재 입력 위치에 해당하는 줄 인덱스 계산
  int _calculateCurrentLineIndex(String userInput, List<String> lines) {
    if (lines.isEmpty || userInput.isEmpty) return 0;

    int totalChars = 0;
    for (int i = 0; i < lines.length; i++) {
      totalChars += lines[i].length;
      if (userInput.length <= totalChars) {
        return i;
      }
    }
    return lines.length - 1;
  }

  Future<void> _initialize(String language) async {
    state = state.copyWith(language: language);
    await _loadSentences(language);
  }

  Future<void> _loadSentences(String language) async {
    state = state.copyWith(availableSentences: const AsyncLoading());

    final sentenceResult = await _getSentencesUseCase.execute(
      'paragraph',
      language,
    );

    sentenceResult.when(
      data: (sentences) {
        state = state.copyWith(availableSentences: AsyncData(sentences));

        // 첫 번째 문장을 자동으로 선택하고 분할
        if (sentences.isNotEmpty) {
          final firstSentence = sentences.first;
          final lines = _splitSentenceIntoLines(firstSentence.content);

          state = state.copyWith(
            currentSentence: firstSentence,
            sentenceLines: lines,
            currentLineIndex: 0,
          );
        }
      },
      loading: () {
        state = state.copyWith(availableSentences: const AsyncLoading());
      },
      error: (error, stackTrace) {
        state = state.copyWith(
          availableSentences: AsyncError(error, stackTrace),
        );
      },
    );
  }

  Future<void> _selectSentence(String sentenceId) async {
    final sentences = state.availableSentences.value;
    if (sentences == null) return;

    final selectedSentence = sentences.firstWhere(
      (s) => s.id == sentenceId,
      orElse: () => sentences.first,
    );

    // 선택된 문장을 20자씩 분할
    final lines = _splitSentenceIntoLines(selectedSentence.content);

    state = state.copyWith(
      currentSentence: selectedSentence,
      sentenceLines: lines,
      currentLineIndex: 0,
      // 연습 상태 초기화
      isStarted: false,
      isCompleted: false,
      isPaused: false,
      userInput: '',
      currentCharIndex: 0,
      correctCharacters: 0,
      incorrectCharacters: 0,
      totalTypos: 0,
      wpm: 0.0,
      typingSpeed: 0.0,
      accuracy: 0.0,
      characterInputs: const [],
      startTime: null,
      endTime: null,
    );
  }

  Future<void> _selectRandomSentence() async {
    final randomResult = await _getRandomSentenceUseCase.execute(
      'paragraph',
      state.language,
    );

    randomResult.when(
      data: (sentence) {
        // 랜덤 문장을 20자씩 분할
        final lines = _splitSentenceIntoLines(sentence.content);

        state = state.copyWith(
          currentSentence: sentence,
          sentenceLines: lines,
          currentLineIndex: 0,
          // 연습 상태 초기화
          isStarted: false,
          isCompleted: false,
          isPaused: false,
          userInput: '',
          currentCharIndex: 0,
          correctCharacters: 0,
          incorrectCharacters: 0,
          totalTypos: 0,
          wpm: 0.0,
          typingSpeed: 0.0,
          accuracy: 0.0,
          characterInputs: const [],
          startTime: null,
          endTime: null,
        );
      },
      loading: () {},
      error: (error, stackTrace) {
        // 에러 시 기존 문장 유지
      },
    );
  }

  void _startPractice() {
    if (!state.canStart) return;

    state = state.copyWith(
      isStarted: true,
      isPaused: false,
      startTime: DateTime.now(),
      userInput: '',
      currentCharIndex: 0,
      currentLineIndex: 0,
      correctCharacters: 0,
      incorrectCharacters: 0,
      totalTypos: 0,
      wpm: 0.0,
      typingSpeed: 0.0,
      accuracy: 0.0,
      characterInputs: const [],
    );

    _startStatsTimer();
    _lastInputTime = DateTime.now();
  }

  void _pausePractice() {
    if (!state.canPause) return;

    state = state.copyWith(isPaused: true);
    _stopStatsTimer();
  }

  void _resumePractice() {
    if (!state.canResume) return;

    state = state.copyWith(isPaused: false);
    _startStatsTimer();
    _lastInputTime = DateTime.now();
  }

  void _restartPractice() {
    if (!state.canRestart) return;

    _stopStatsTimer();

    state = state.copyWith(
      isStarted: false,
      isCompleted: false,
      isPaused: false,
      userInput: '',
      currentCharIndex: 0,
      currentLineIndex: 0,
      correctCharacters: 0,
      incorrectCharacters: 0,
      totalTypos: 0,
      wpm: 0.0,
      typingSpeed: 0.0,
      accuracy: 0.0,
      characterInputs: const [],
      startTime: null,
      endTime: null,
    );
  }

  void _completePractice() {
    if (state.isCompleted) return;

    _stopStatsTimer();

    state = state.copyWith(
      isCompleted: true,
      isStarted: false,
      isPaused: false,
      endTime: DateTime.now(),
    );

    // 최종 통계 계산
    _updateStats();

    // 결과 자동 저장
    onAction(const ParagraphPracticeAction.saveResult());
  }

  void _updateInput(String input) {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;

    final currentSentence = state.currentSentence;
    if (currentSentence == null) return;

    final targetText = currentSentence.content;
    final previousInput = state.userInput;

    // 입력이 목표 텍스트보다 길면 제한
    if (input.length > targetText.length) {
      input = input.substring(0, targetText.length);
    }

    // 현재 줄 인덱스 계산
    final newLineIndex = _calculateCurrentLineIndex(input, state.sentenceLines);

    state = state.copyWith(userInput: input, currentLineIndex: newLineIndex);

    // 새로 입력된 글자가 있는지 확인
    if (input.length > previousInput.length) {
      final newCharIndex = input.length - 1;
      final inputChar = input[newCharIndex];
      final targetChar = targetText[newCharIndex];

      _processCharacterInput(inputChar, targetChar, newCharIndex);
    }

    // 입력 완료 확인
    if (input.length == targetText.length) {
      _completePractice();
    }
  }

  void _processCharacterInput(
    String inputChar,
    String targetChar,
    int charIndex,
  ) {
    final now = DateTime.now();
    final inputTime = _lastInputTime != null
        ? now.difference(_lastInputTime!)
        : const Duration(milliseconds: 0);

    final isCorrect = inputChar == targetChar;

    // 통계 업데이트
    if (isCorrect) {
      state = state.copyWith(correctCharacters: state.correctCharacters + 1);
    } else {
      state = state.copyWith(
        incorrectCharacters: state.incorrectCharacters + 1,
        totalTypos: state.totalTypos + 1,
      );
    }

    // TypingCharacterInput 생성
    final characterInput = TypingCharacterInput(
      targetCharacter: targetChar,
      actualInput: inputChar,
      isCorrect: isCorrect,
      timestamp: now,
      inputDuration: inputTime,
    );

    state = state.copyWith(
      characterInputs: [...state.characterInputs, characterInput],
    );

    _lastInputTime = now;
    _updateStats();
  }

  void _handleBackspace() {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;
    // 백스페이스 처리는 _updateInput에서 자동으로 처리됨
  }

  void _inputCharacter(String character) {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;
    // 개별 글자 입력 처리
    final newInput = state.userInput + character;
    _updateInput(newInput);
  }

  void _updateStats() {
    if (state.startTime == null) return;

    // 경과 시간 계산 (분 단위)
    final elapsedSeconds = state.elapsedSeconds;
    final elapsedMinutes = elapsedSeconds / 60.0;

    if (elapsedMinutes <= 0) return;

    // 분당 타수 계산 (새로운 메인 지표)
    final typingSpeed = state.correctCharacters / elapsedMinutes;

    // 기존 WPM 계산 (호환성 유지용 - 5글자 = 1단어 가정)
    final wpm = typingSpeed / 5.0;

    // 정확도 계산
    final totalAttempts = state.correctCharacters + state.incorrectCharacters;
    final accuracy = totalAttempts > 0
        ? (state.correctCharacters / totalAttempts) * 100.0
        : 0.0;

    // 상태 업데이트
    state = state.copyWith(
      typingSpeed: typingSpeed,
      wpm: wpm,
      accuracy: accuracy,
    );
  }

  Future<void> _changeLanguage(String language) async {
    _stopStatsTimer();

    state = state.copyWith(
      language: language,
      isStarted: false,
      isCompleted: false,
      isPaused: false,
      currentSentence: null,
      sentenceLines: const [],
      currentLineIndex: 0,
      userInput: '',
      currentCharIndex: 0,
      correctCharacters: 0,
      incorrectCharacters: 0,
      totalTypos: 0,
      wpm: 0.0,
      typingSpeed: 0.0,
      accuracy: 0.0,
      characterInputs: const [],
      startTime: null,
      endTime: null,
    );

    await _loadSentences(language);
  }

  Future<void> _saveResult() async {
    if (!state.isCompleted || state.currentSentence == null) return;

    final result = TypingResult(
      id: '', // Repository에서 생성됨
      userId: 'mock_user_id', // TODO: 실제 사용자 ID로 교체
      type: 'practice',
      mode: 'paragraph',
      sentenceId: state.currentSentence!.id,
      sentenceContent: state.currentSentence!.content,
      typingSpeed: state.typingSpeed,
      accuracy: state.accuracy,
      typoCount: state.totalTypos,
      totalCharacters: state.totalSentenceLength,
      correctCharacters: state.correctCharacters,
      duration: state.elapsedSeconds,
      language: state.language,
      createdAt: DateTime.now(),
    );

    await _saveTypingResultUseCase.execute(result);
  }

  void _startStatsTimer() {
    _stopStatsTimer();

    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isStarted && !state.isPaused && !state.isCompleted) {
        _updateStats();
      }
    });
  }

  void _stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }
}
