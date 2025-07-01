// lib/typing/presentation/paragraph_practice/paragraph_practice_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/sentence.dart';

part 'paragraph_practice_state.freezed.dart';

@freezed
class ParagraphPracticeState with _$ParagraphPracticeState {
  const ParagraphPracticeState({
    this.availableSentences = const AsyncLoading(),
    this.currentSentence,
    this.userInput = '',
    this.currentCharIndex = 0,
    this.isStarted = false,
    this.isCompleted = false,
    this.isPaused = false,
    this.startTime,
    this.endTime,
    this.language = 'ko',
    this.correctCharacters = 0,
    this.incorrectCharacters = 0,
    this.totalTypos = 0,
    this.wpm = 0.0, // 기존 필드 유지
    this.typingSpeed = 0.0, // 새 필드 추가 - 분당 타수
    this.accuracy = 0.0,
    this.cpm = 0.0,
    this.characterStats = const [],
  });

  /// 사용 가능한 문장들
  @override
  final AsyncValue<List<Sentence>> availableSentences;

  /// 현재 연습 중인 문장
  @override
  final Sentence? currentSentence;

  /// 사용자 현재 입력
  @override
  final String userInput;

  /// 현재 입력해야 할 글자 인덱스
  @override
  final int currentCharIndex;

  /// 연습 시작 여부
  @override
  final bool isStarted;

  /// 연습 완료 여부
  @override
  final bool isCompleted;

  /// 일시정지 여부
  @override
  final bool isPaused;

  @override
  final double typingSpeed;

  /// 연습 시작 시간
  @override
  final DateTime? startTime;

  /// 연습 완료 시간
  @override
  final DateTime? endTime;

  /// 선택된 언어
  @override
  final String language;

  /// 올바르게 입력한 글자 수
  @override
  final int correctCharacters;

  /// 틀리게 입력한 글자 수
  @override
  final int incorrectCharacters;

  /// 총 오타 수 (백스페이스로 수정한 것도 포함)
  @override
  final int totalTypos;

  /// 현재 WPM (Words Per Minute) - 실시간 계산된 값
  @override
  final double wpm;

  /// 현재 정확도 (0-100) - 실시간 계산된 값
  @override
  final double accuracy;

  /// 현재 CPM (Characters Per Minute) - 실시간 계산된 값
  @override
  final double cpm;

  /// 각 글자별 입력 통계 (정확/오타/시간)
  @override
  final List<CharacterStat> characterStats;

  /// 연습 진행 시간 (초)
  double get elapsedSeconds {
    if (startTime == null) return 0.0;
    final end = isCompleted ? endTime : DateTime.now();
    if (end == null) return 0.0;
    return end.difference(startTime!).inMilliseconds / 1000.0;
  }

  /// 총 입력한 글자 수
  int get totalCharacters => correctCharacters + incorrectCharacters;

  /// 전체 문장 길이
  int get totalSentenceLength => currentSentence?.content.length ?? 0;

  /// 진행률 (0.0 ~ 1.0)
  double get progress => totalSentenceLength > 0
      ? (currentCharIndex / totalSentenceLength).clamp(0.0, 1.0)
      : 0.0;

  /// 진행률 퍼센트 (0 ~ 100)
  double get progressPercent => progress * 100;

  /// 연습 시작 가능 여부
  bool get canStart => !isStarted && !isCompleted && currentSentence != null;

  /// 연습 일시정지 가능 여부
  bool get canPause => isStarted && !isCompleted && !isPaused;

  /// 연습 재개 가능 여부
  bool get canResume => isStarted && !isCompleted && isPaused;

  /// 연습 재시작 가능 여부
  bool get canRestart => isStarted || isCompleted;

  /// 현재 입력해야 할 글자
  String? get currentTargetChar {
    if (currentSentence == null || currentCharIndex >= totalSentenceLength) {
      return null;
    }
    return currentSentence!.content[currentCharIndex];
  }

  /// 이미 입력 완료된 부분
  String get completedText {
    if (currentSentence == null) return '';
    final endIndex = currentCharIndex.clamp(0, totalSentenceLength);
    return currentSentence!.content.substring(0, endIndex);
  }

  /// 아직 입력하지 않은 부분
  String get remainingText {
    if (currentSentence == null) return '';
    final startIndex = currentCharIndex.clamp(0, totalSentenceLength);
    return currentSentence!.content.substring(startIndex);
  }

  /// 현재 입력된 마지막 글자가 정확한지
  bool get isLastCharCorrect {
    if (userInput.isEmpty || currentSentence == null) return true;
    if (userInput.length > totalSentenceLength) return false;

    final lastInputIndex = userInput.length - 1;
    final targetChar = currentSentence!.content[lastInputIndex];
    final inputChar = userInput[lastInputIndex];
    return targetChar == inputChar;
  }

  /// 우수한 정확도인지 (90% 이상)
  bool get isGoodAccuracy => accuracy >= 90.0;

  /// 완벽한 타자인지 (100% 정확도)
  bool get isFastSpeed => typingSpeed >= 300.0;

  /// 타자 수준 평가
  String get typingLevel {
    if (typingSpeed < 100) return '초급';
    if (typingSpeed < 200) return '중급';
    if (typingSpeed < 300) return '고급';
    if (typingSpeed < 400) return '상급';
    return '전문가';
  }

  /// 남은 글자 수
  int get remainingCharacters => totalSentenceLength - currentCharIndex;

  /// 예상 완료 시간 (현재 속도 기준, 초)
  double get estimatedTimeToComplete {
    if (cpm <= 0 || remainingCharacters <= 0) return 0.0;
    return (remainingCharacters / cpm) * 60.0;
  }
}

/// 각 글자별 입력 통계
@freezed
class CharacterStat with _$CharacterStat {
  const CharacterStat({
    required this.character,
    required this.inputTime,
    required this.isCorrect,
    required this.attempts,
  });

  /// 입력한 글자
  @override
  final String character;

  /// 입력 시간 (밀리초)
  @override
  final int inputTime;

  /// 정확한 입력 여부
  @override
  final bool isCorrect;

  /// 시도 횟수 (백스페이스 후 재입력 포함)
  @override
  final int attempts;

  /// 입력 속도 (이 글자를 입력하는데 걸린 시간, 초)
  double get inputDuration => inputTime / 1000.0;

  /// 빠른 입력인지 (0.5초 이하)
  bool get isFastInput => inputDuration <= 0.5;

  /// 느린 입력인지 (2초 이상)
  bool get isSlowInput => inputDuration >= 2.0;
}
