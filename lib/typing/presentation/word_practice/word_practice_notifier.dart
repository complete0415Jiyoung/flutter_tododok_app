// lib/typing/presentation/word_practice/word_practice_notifier.dart
import 'dart:async';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecase/get_sentences_use_case.dart';
import '../../domain/usecase/save_typing_result_use_case.dart';
import '../../domain/model/typing_result.dart';
import '../../module/typing_di.dart';
import 'word_practice_state.dart';
import 'word_practice_action.dart';

part 'word_practice_notifier.g.dart';

@riverpod
class WordPracticeNotifier extends _$WordPracticeNotifier {
  late final GetSentencesUseCase _getSentencesUseCase;
  late final SaveTypingResultUseCase _saveTypingResultUseCase;

  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();
  List<String> _wordPool = [];

  @override
  WordPracticeState build() {
    _getSentencesUseCase = ref.watch(getSentencesUseCaseProvider);
    _saveTypingResultUseCase = ref.watch(saveTypingResultUseCaseProvider);

    return const WordPracticeState();
  }

  @override
  void dispose() {
    _stopTimers();
  }

  Future<void> onAction(WordPracticeAction action) async {
    switch (action) {
      case Initialize(:final language):
        await _initialize(language);
      case StartGame():
        _startGame();
      case PauseGame():
        _pauseGame();
      case ResumeGame():
        _resumeGame();
      case EndGame():
        _endGame();
      case RestartGame():
        _restartGame();
      case SpawnWord():
        _spawnWord();
      case UpdateFallingWords(:final deltaTime):
        _updateFallingWords(deltaTime);
      case UpdateInput(:final input):
        _updateInput(input);
      case SubmitInput():
        _submitInput();
      case WordMatched(:final wordId):
        _wordMatched(wordId);
      case WordMissed(:final wordId):
        _wordMissed(wordId);
      case LevelUp():
        _levelUp();
      case ChangeLanguage(:final language):
        await _changeLanguage(language);
      case NavigateToResult():
      case NavigateToHome():
        // 네비게이션은 Root에서 처리
        break;
    }
  }

  Future<void> _initialize(String language) async {
    state = state.copyWith(language: language);
    await _loadWordPool(language);
  }

  Future<void> _loadWordPool(String language) async {
    state = state.copyWith(availableSentences: const AsyncLoading());

    final sentenceResult = await _getSentencesUseCase.execute('word', language);

    sentenceResult.when(
      data: (sentences) {
        // 모든 문장에서 단어들을 추출하여 단어 풀 생성
        _wordPool = sentences
            .expand((sentence) => sentence.content.split(' '))
            .where((word) => word.trim().isNotEmpty)
            .toList();

        state = state.copyWith(availableSentences: AsyncData(sentences));
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

  void _startGame() {
    if (state.isGameRunning || _wordPool.isEmpty) return;

    state = state.copyWith(
      isGameRunning: true,
      isGameOver: false,
      gameStartTime: DateTime.now(),
      score: 0,
      lives: 3,
      level: 1,
      correctWordsCount: 0,
      missedWordsCount: 0,
      totalWordsSpawned: 0,
      fallingWords: [],
      userInput: '',
      gameSpeed: 1.0,
    );

    _startGameLoop();
    _startWordSpawning();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      // 60 FPS로 게임 업데이트
      const deltaTime = 0.016; // 16ms = 0.016초
      onAction(const WordPracticeAction.updateFallingWords(deltaTime));
    });
  }

  void _startWordSpawning() {
    // 레벨에 따른 단어 생성 주기 조정 (더 천천히 시작)
    int spawnIntervalMs;
    if (state.level == 1) {
      spawnIntervalMs = 4000; // 레벨 1: 4초마다 생성 (천천히 시작)
    } else if (state.level == 2) {
      spawnIntervalMs = 3000; // 레벨 2: 3초마다
    } else if (state.level == 3) {
      spawnIntervalMs = 2500; // 레벨 3: 2.5초마다
    } else if (state.level <= 5) {
      spawnIntervalMs = 2000 - ((state.level - 3) * 200); // 레벨 4-5: 2초~1.6초
    } else {
      spawnIntervalMs = (1600 - ((state.level - 5) * 100)).clamp(
        800,
        1600,
      ); // 최소 0.8초
    }

    final spawnInterval = Duration(milliseconds: spawnIntervalMs);

    _spawnTimer = Timer.periodic(spawnInterval, (timer) {
      if (state.isGameRunning) {
        onAction(const WordPracticeAction.spawnWord());
      }
    });
  }

  void _spawnWord() {
    if (_wordPool.isEmpty || !state.isGameRunning) return;

    // 랜덤 단어 선택
    final word = _wordPool[_random.nextInt(_wordPool.length)];

    // 레벨에 따른 떨어지는 속도 조정 (CPM 기준)
    double baseSpeed;
    if (state.level == 1) {
      baseSpeed = 0.03; // 레벨 1: 매우 천천히
    } else if (state.level == 2) {
      baseSpeed = 0.04; // 레벨 2: 조금 더 빠르게
    } else if (state.level == 3) {
      baseSpeed = 0.05; // 레벨 3: 보통 속도
    } else {
      baseSpeed = 0.05 + ((state.level - 3) * 0.01); // 레벨 4+: 점진적 증가
    }

    // CPM 보너스 (200 CPM 이상일 때만 적용)
    double cpmBonus = state.cpm > 200 ? (state.cpm - 200) * 0.0002 : 0;

    final finalSpeed = (baseSpeed + cpmBonus).clamp(0.02, 0.15); // 최대 속도 제한

    // 새로운 떨어지는 단어 생성
    final fallingWord = FallingWord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: word,
      x: _random.nextDouble() * 0.8 + 0.1,
      y: 0.0,
      speed: finalSpeed,
    );

    final newFallingWords = [...state.fallingWords, fallingWord];
    state = state.copyWith(
      fallingWords: newFallingWords,
      totalWordsSpawned: state.totalWordsSpawned + 1,
    );
  }

  void _updateFallingWords(double deltaTime) {
    if (!state.isGameRunning) return;

    final updatedWords = <FallingWord>[];
    final wordsToRemove = <String>[];

    for (final word in state.fallingWords) {
      final newY = word.getNextY(deltaTime);

      if (newY >= 1.0) {
        // 화면 하단에 도달한 단어는 제거하고 생명 감소
        wordsToRemove.add(word.id);
      } else {
        // 위치 업데이트
        updatedWords.add(word.copyWith(y: newY));
      }
    }

    // 상태 업데이트
    state = state.copyWith(fallingWords: updatedWords);

    // 놓친 단어들 처리
    for (final wordId in wordsToRemove) {
      onAction(WordPracticeAction.wordMissed(wordId));
    }
  }

  void _updateInput(String input) {
    // 게임이 진행 중일 때만 입력 허용
    if (!state.isGameRunning) return;

    state = state.copyWith(userInput: input);

    // 입력과 일치하는 단어가 있는지 실시간 확인
    _checkPartialMatches(input);
  }

  void _checkPartialMatches(String input) {
    if (input.isEmpty) return;

    final updatedWords = state.fallingWords.map((word) {
      final isMatching = word.text.toLowerCase().startsWith(
        input.toLowerCase(),
      );
      return word.copyWith(isMatched: isMatching);
    }).toList();

    state = state.copyWith(fallingWords: updatedWords);
  }

  void _submitInput() {
    final input = state.userInput.trim().toLowerCase();
    if (input.isEmpty || !state.isGameRunning) return;

    // 정확히 일치하는 단어 찾기
    final matchedWord = state.fallingWords.firstWhere(
      (word) => word.text.toLowerCase() == input,
      orElse: () => const FallingWord(id: '', text: '', x: 0, y: 0, speed: 0),
    );

    if (matchedWord.id.isNotEmpty) {
      // 단어 매칭 성공
      onAction(WordPracticeAction.wordMatched(matchedWord.id));
    }

    // 입력 초기화
    state = state.copyWith(userInput: '');
  }

  void _wordMatched(String wordId) {
    // 매칭된 단어 찾기
    final matchedWord = state.fallingWords.firstWhere(
      (word) => word.id == wordId,
      orElse: () => const FallingWord(id: '', text: '', x: 0, y: 0, speed: 0),
    );

    // 매칭된 단어 제거
    final updatedWords = state.fallingWords
        .where((word) => word.id != wordId)
        .toList();

    // 글자 수 계산
    final characterCount = matchedWord.text.length;

    // 점수 및 통계 업데이트
    final baseScore = characterCount * 2; // 글자당 2점
    final levelBonus = state.level * 5;
    final speedBonus = (state.gameSpeed * 5).round();
    final cpmBonus = (state.cpm / 20).round(); // CPM 보너스
    final totalScore = baseScore + levelBonus + speedBonus + cpmBonus;

    state = state.copyWith(
      fallingWords: updatedWords,
      score: state.score + totalScore,
      correctWordsCount: state.correctWordsCount + 1,
      totalCharactersTyped: state.totalCharactersTyped + characterCount,
    );

    // 실시간 통계 계산
    _calculateRealTimeStats();

    // 동적 레벨업 체크
    _checkLevelUp();
  }

  void _calculateRealTimeStats() {
    final elapsedMinutes = state.elapsedSeconds / 60.0;

    // CPM 계산 (분당 글자 수)
    final cpm = elapsedMinutes > 0
        ? state.totalCharactersTyped / elapsedMinutes
        : 0.0;

    // 정확도 계산
    final accuracy = state.totalWordsSpawned > 0
        ? (state.correctWordsCount / state.totalWordsSpawned) * 100
        : 0.0;

    state = state.copyWith(cpm: cpm, accuracy: accuracy);
  }

  void _checkLevelUp() {
    final currentCpm = state.cpm;
    final correctWords = state.correctWordsCount;

    // 레벨업 조건들 (CPM 기준으로 조정)
    bool shouldLevelUp = false;

    if (state.level == 1 && correctWords >= 3) {
      // 레벨 1: 3단어만 입력하면 레벨업
      shouldLevelUp = true;
    } else if (state.level == 2 && (correctWords >= 8 || currentCpm >= 100)) {
      // 레벨 2: 8단어 또는 100 CPM 달성
      shouldLevelUp = true;
    } else if (state.level == 3 && (correctWords >= 15 || currentCpm >= 180)) {
      // 레벨 3: 15단어 또는 180 CPM 달성
      shouldLevelUp = true;
    } else if (state.level == 4 && (correctWords >= 25 || currentCpm >= 250)) {
      // 레벨 4: 25단어 또는 250 CPM 달성
      shouldLevelUp = true;
    } else if (state.level >= 5) {
      // 레벨 5 이상: CPM 기반으로만 레벨업
      final requiredCpm = 250 + (state.level - 4) * 50; // 300, 350, 400 CPM...
      final requiredWords = state.level * 15; // 75, 90, 105 단어...

      if (currentCpm >= requiredCpm || correctWords >= requiredWords) {
        shouldLevelUp = true;
      }
    }

    if (shouldLevelUp) {
      onAction(const WordPracticeAction.levelUp());
    }
  }

  void _levelUp() {
    final newLevel = state.level + 1;

    // 레벨에 따른 게임 속도 조정 (더 점진적으로)
    double newGameSpeed;
    if (newLevel <= 3) {
      newGameSpeed = 1.0 + (newLevel * 0.2); // 1.2, 1.4, 1.6
    } else if (newLevel <= 6) {
      newGameSpeed = 1.6 + ((newLevel - 3) * 0.3); // 1.9, 2.2, 2.5
    } else {
      newGameSpeed = 2.5 + ((newLevel - 6) * 0.2); // 2.7, 2.9, 3.1...
    }

    state = state.copyWith(level: newLevel, gameSpeed: newGameSpeed);

    // 단어 생성 주기와 속도도 업데이트
    _updateGameDifficulty();
  }

  void _updateGameDifficulty() {
    // 기존 타이머 정리
    _spawnTimer?.cancel();

    // 새로운 속도로 단어 생성 시작
    _startWordSpawning();
  }

  void _wordMissed(String wordId) {
    // 놓친 단어 제거
    final updatedWords = state.fallingWords
        .where((word) => word.id != wordId)
        .toList();

    final newLives = state.lives - 1;
    final newMissedCount = state.missedWordsCount + 1;

    state = state.copyWith(
      fallingWords: updatedWords,
      lives: newLives,
      missedWordsCount: newMissedCount,
    );

    // 실시간 통계 계산
    _calculateRealTimeStats();

    // 생명이 0이 되면 게임 오버
    if (newLives <= 0) {
      _endGame();
    }
  }

  void _pauseGame() {
    if (!state.isGameRunning) return;

    state = state.copyWith(isGameRunning: false);
    _stopTimers();
  }

  void _resumeGame() {
    if (state.isGameRunning || state.isGameOver) return;

    state = state.copyWith(isGameRunning: true);
    _startGameLoop();
    _startWordSpawning();
  }

  void _endGame() {
    state = state.copyWith(isGameRunning: false, isGameOver: true);

    _stopTimers();
    _saveGameResult();
  }

  void _restartGame() {
    _stopTimers();
    _startGame();
  }

  void _stopTimers() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _gameTimer = null;
    _spawnTimer = null;
  }

  Future<void> _saveGameResult() async {
    if (state.gameStartTime == null) return;

    final result = TypingResult(
      id: '', // Repository에서 생성됨
      userId: 'mock_user_id', // TODO: 실제 사용자 ID로 교체
      type: 'practice',
      mode: 'word',
      sentenceId: 'word_game_${DateTime.now().millisecondsSinceEpoch}',
      sentenceContent: 'Word falling game - ${state.correctWordsCount} words',
      wpm: state.wpm,
      accuracy: state.accuracy,
      typoCount: state.missedWordsCount,
      totalCharacters: state.totalWordsSpawned * 5, // 평균 단어 길이 추정
      correctCharacters: state.correctWordsCount * 5,
      duration: state.elapsedSeconds,
      language: state.language,
      createdAt: DateTime.now(),
    );

    await _saveTypingResultUseCase.execute(result);
  }

  Future<void> _changeLanguage(String language) async {
    _stopTimers();
    state = state.copyWith(
      language: language,
      isGameRunning: false,
      isGameOver: false,
      fallingWords: [],
    );
    await _loadWordPool(language);
  }
}
