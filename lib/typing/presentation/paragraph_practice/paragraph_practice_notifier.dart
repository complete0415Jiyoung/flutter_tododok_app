// lib/typing/presentation/paragraph_practice/paragraph_practice_notifier.dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return const ParagraphPracticeState();
  }

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
      // 🔥 새로 추가: 다음 줄로 이동 처리
      case MoveToNextLine():
        _moveToNextLine();
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
    final asyncSentences = state.availableSentences;
    if (!asyncSentences.hasValue) return;

    final sentences = asyncSentences.value!;
    final selectedSentence = sentences.firstWhere(
      (sentence) => sentence.id == sentenceId,
      orElse: () => sentences.first,
    );

    final lines = _splitSentenceIntoLines(selectedSentence.content);

    state = state.copyWith(
      currentSentence: selectedSentence,
      sentenceLines: lines,
      currentLineIndex: 0,
      // 선택 시 기존 입력 초기화
      userInput: '',
    );
  }

  Future<void> _selectRandomSentence() async {
    final randomSentenceResult = await _getRandomSentenceUseCase.execute(
      'paragraph',
      state.language ?? 'ko',
    );

    randomSentenceResult.when(
      data: (sentence) {
        final lines = _splitSentenceIntoLines(sentence.content);
        state = state.copyWith(
          currentSentence: sentence,
          sentenceLines: lines,
          currentLineIndex: 0,
          userInput: '',
        );
      },
      loading: () {},
      error: (error, stackTrace) {
        // 에러 처리는 필요시 추가
      },
    );
  }

  void _startPractice() {
    if (state.currentSentence == null) return;

    final now = DateTime.now();
    state = state.copyWith(
      isStarted: true,
      isPaused: false,
      isCompleted: false,
      startTime: now,
      userInput: '',
      characterInputs: [],
      correctCharacters: 0,
      incorrectCharacters: 0,
      currentLineIndex: 0,
    );

    _startStatsTimer();
  }

  void _pausePractice() {
    _stopStatsTimer();
    state = state.copyWith(isPaused: true);
  }

  void _resumePractice() {
    state = state.copyWith(isPaused: false);
    _startStatsTimer();
  }

  void _restartPractice() {
    _stopStatsTimer();

    state = state.copyWith(
      isStarted: false,
      isPaused: false,
      isCompleted: false,
      userInput: '',
      characterInputs: [],
      correctCharacters: 0,
      incorrectCharacters: 0,
      currentLineIndex: 0,
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

  // 🔥 새로 추가: 다음 줄로 이동하는 메서드
  void _moveToNextLine() {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;

    final newLineIndex = state.currentLineIndex + 1;

    // 마지막 줄을 넘어가지 않도록 체크
    if (newLineIndex < state.sentenceLines.length) {
      state = state.copyWith(currentLineIndex: newLineIndex);
    } else {
      // 모든 줄이 완료된 경우 연습 완료 처리
      _completePractice();
    }
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

    // 현재 줄 인덱스는 자동으로 계산하지 않고 moveToNextLine에서만 업데이트
    // 대신 입력이 변경되었을 때 줄 인덱스 검증
    final calculatedLineIndex = _calculateCurrentLineIndex(
      input,
      state.sentenceLines,
    );

    // 계산된 줄 인덱스가 현재와 다르면 동기화
    if (calculatedLineIndex != state.currentLineIndex) {
      state = state.copyWith(
        userInput: input,
        currentLineIndex: calculatedLineIndex,
      );
    } else {
      state = state.copyWith(userInput: input);
    }

    // 새로 입력된 글자가 있는지 확인
    if (input.length > previousInput.length) {
      final newCharIndex = input.length - 1;
      final inputChar = input[newCharIndex];
      final targetChar = targetText[newCharIndex];

      _processCharacterInput(inputChar, targetChar, newCharIndex);
    }

    // 전체 입력 완료 확인
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
        : Duration.zero;

    final isCorrect = inputChar == targetChar;

    // 통계 업데이트
    if (isCorrect) {
      state = state.copyWith(correctCharacters: state.correctCharacters + 1);
    } else {
      state = state.copyWith(
        incorrectCharacters: state.incorrectCharacters + 1,
      );
    }

    // 입력 기록 저장
    final characterInput = TypingCharacterInput(
      targetCharacter: targetChar, // ✅ 올바른 필드명
      actualInput: inputChar, // ✅ 올바른 필드명
      isCorrect: isCorrect, // ✅ 맞음
      timestamp: now, // ✅ 맞음
      inputDuration: inputTime, // ✅ 올바른 필드명
    );

    state = state.copyWith(
      characterInputs: [...state.characterInputs, characterInput],
    );

    _lastInputTime = now;
  }

  void _handleBackspace() {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;

    final currentInput = state.userInput;
    if (currentInput.isEmpty) return;

    // 마지막 글자 제거
    final newInput = currentInput.substring(0, currentInput.length - 1);

    // 삭제된 글자가 올바른 입력이었는지 확인하여 통계 조정
    if (state.characterInputs.isNotEmpty) {
      final lastInput = state.characterInputs.last;

      int newCorrectCount = state.correctCharacters;
      int newIncorrectCount = state.incorrectCharacters;

      if (lastInput.isCorrect) {
        newCorrectCount = (newCorrectCount - 1)
            .clamp(0, double.infinity)
            .toInt();
      } else {
        newIncorrectCount = (newIncorrectCount - 1)
            .clamp(0, double.infinity)
            .toInt();
      }

      state = state.copyWith(
        userInput: newInput,
        correctCharacters: newCorrectCount,
        incorrectCharacters: newIncorrectCount,
        characterInputs: state.characterInputs.sublist(
          0,
          state.characterInputs.length - 1,
        ),
      );
    } else {
      state = state.copyWith(userInput: newInput);
    }
  }

  void _inputCharacter(String character) {
    if (!state.isStarted || state.isPaused || state.isCompleted) return;

    final currentInput = state.userInput;
    final newInput = currentInput + character;

    _updateInput(newInput);
  }

  void _startStatsTimer() {
    _stopStatsTimer();
    _statsTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _updateStats(),
    );
  }

  void _stopStatsTimer() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  void _updateStats() {
    _calculateRealTimeStats();
  }

  void _calculateRealTimeStats() {
    final elapsedSeconds = state.elapsedSeconds;
    if (elapsedSeconds <= 0) return;

    final totalChars = state.userInput.length;
    final correctChars = state.correctCharacters;

    // 분당 타수 계산 (CPM - Characters Per Minute)
    final typingSpeed = (totalChars / elapsedSeconds) * 60.0;

    // 정확도 계산
    final accuracy = totalChars > 0
        ? (correctChars / totalChars) * 100.0
        : 100.0;

    state = state.copyWith(typingSpeed: typingSpeed, accuracy: accuracy);
  }

  Future<void> _changeLanguage(String language) async {
    state = state.copyWith(language: language);
    await _loadSentences(language);
  }

  Future<void> _saveResult() async {
    final currentSentence = state.currentSentence;
    if (currentSentence == null || !state.isCompleted) return;

    final result = TypingResult(
      id: '', // Firestore에서 자동 생성
      userId: '', // UseCase에서 설정
      type: 'practice',
      mode: 'paragraph',
      sentenceId: currentSentence.id,
      sentenceContent: currentSentence.content,
      typingSpeed: state.typingSpeed,
      accuracy: state.accuracy,
      typoCount: state.incorrectCharacters,
      totalCharacters: state.userInput.length,
      correctCharacters: state.correctCharacters,
      duration: state.elapsedSeconds,
      language: state.language ?? 'ko',
      createdAt: DateTime.now(),
    );

    final saveResult = await _saveTypingResultUseCase.execute(result);

    saveResult.when(
      data: (savedResult) {
        // 저장 성공 처리
      },
      loading: () {},
      error: (error, stackTrace) {
        // 에러 처리 (필요시 상태에 반영)
      },
    );
  }
}
