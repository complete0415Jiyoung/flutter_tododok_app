// lib/typing/presentation/word_practice/word_practice_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/sentence.dart';

part 'word_practice_state.freezed.dart';

@freezed
class WordPracticeState with _$WordPracticeState {
  const WordPracticeState({
    this.availableSentences = const AsyncLoading(),
    this.wordSequence = const [],
    this.currentWordIndex = 0,
    this.currentWordInput = '',
    this.score = 0,
    this.level = 1,
    this.isGameRunning = false,
    this.isGameOver = false,
    this.isPaused = false,
    this.gameStartTime,
    this.language = 'ko',
    this.correctWordsCount = 0,
    this.incorrectWordsCount = 0,
    this.skippedWordsCount = 0,
    this.totalCharactersTyped = 0,
    this.wpm = 0,
    this.accuracy = 0,
    this.targetWordCount = 10,
    this.hintsUsed = 0,
    this.hintsRemaining = 3,
    this.showHint = false,
    this.currentSentenceText = '',
    this.currentSentenceId = '',
  });

  final AsyncValue<List<Sentence>> availableSentences;
  final List<PracticeWord> wordSequence;
  final int currentWordIndex;
  final String currentWordInput;
  final int score;
  final int level;
  final bool isGameRunning;
  final bool isGameOver;
  final bool isPaused;
  final DateTime? gameStartTime;
  final String language;
  final int correctWordsCount;
  final int incorrectWordsCount;
  final int skippedWordsCount;
  final int totalCharactersTyped;
  final double wpm;
  final double accuracy;
  final int targetWordCount; // 한 시퀀스당 목표 단어 수
  final int hintsUsed;
  final int hintsRemaining;
  final bool showHint;
  final String currentSentenceText;
  final String currentSentenceId;

  /// 현재 게임 진행 시간 (초)
  double get elapsedSeconds {
    if (gameStartTime == null) return 0.0;
    return DateTime.now().difference(gameStartTime!).inSeconds.toDouble();
  }

  /// 현재 단어 (입력해야 할 단어)
  PracticeWord? get currentWord {
    if (currentWordIndex < 0 || currentWordIndex >= wordSequence.length) {
      return null;
    }
    return wordSequence[currentWordIndex];
  }

  /// 다음 단어 (미리보기용)
  PracticeWord? get nextWord {
    final nextIndex = currentWordIndex + 1;
    if (nextIndex < 0 || nextIndex >= wordSequence.length) {
      return null;
    }
    return wordSequence[nextIndex];
  }

  /// 완료된 단어 리스트
  List<PracticeWord> get completedWords {
    return wordSequence.take(currentWordIndex).toList();
  }

  /// 남은 단어 리스트
  List<PracticeWord> get remainingWords {
    return wordSequence.skip(currentWordIndex + 1).toList();
  }

  /// 현재 시퀀스 완료 여부
  bool get isSequenceCompleted {
    return currentWordIndex >= wordSequence.length;
  }

  /// 전체 진행률 (0.0 ~ 1.0)
  double get progress {
    if (wordSequence.isEmpty) return 0.0;
    return currentWordIndex / wordSequence.length;
  }

  /// 현재 단어 입력 상태
  WordInputStatus get currentWordInputStatus {
    final current = currentWord;
    if (current == null) return WordInputStatus.none;

    if (currentWordInput.isEmpty) return WordInputStatus.empty;

    if (current.text.startsWith(currentWordInput)) {
      if (currentWordInput == current.text) {
        return WordInputStatus.complete;
      }
      return WordInputStatus.typing;
    }

    return WordInputStatus.error;
  }
}

/// 단어 시퀀스의 각 단어 데이터
@freezed
class PracticeWord with _$PracticeWord {
  const PracticeWord({
    required this.text,
    required this.position,
    this.status = WordStatus.pending,
    this.userInput = '',
    this.attempts = 0,
    this.completedAt,
    this.timeTaken = 0,
    this.wasSkipped = false,
    this.usedHint = false,
  });

  final String text;
  final int position; // 문장 내 위치
  final WordStatus status;
  final String userInput; // 사용자가 입력한 내용
  final int attempts; // 시도 횟수
  final DateTime? completedAt; // 완료 시간
  final double timeTaken; // 입력 소요 시간 (초)
  final bool wasSkipped; // 건너뛰기 여부
  final bool usedHint; // 힌트 사용 여부
}

/// 단어 상태
enum WordStatus {
  pending, // 아직 입력하지 않음
  current, // 현재 입력 중
  correct, // 올바르게 입력됨
  incorrect, // 잘못 입력됨
  skipped, // 건너뛰어짐
}

/// 현재 단어 입력 상태
enum WordInputStatus {
  none, // 단어가 없음
  empty, // 입력이 비어있음
  typing, // 올바르게 입력 중
  complete, // 입력 완료
  error, // 입력 오류
}
