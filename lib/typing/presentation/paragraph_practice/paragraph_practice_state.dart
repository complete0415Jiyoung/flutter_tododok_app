// lib/typing/presentation/paragraph_practice/paragraph_practice_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/sentence.dart';
import '../../domain/model/typing_character_input.dart';

part 'paragraph_practice_state.freezed.dart';

@freezed
class ParagraphPracticeState with _$ParagraphPracticeState {
  const ParagraphPracticeState({
    this.availableSentences = const AsyncLoading(),
    this.currentSentence,
    this.sentenceLines = const [],
    this.currentLineIndex = 0,
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
    this.wpm = 0.0,
    this.typingSpeed = 0.0,
    this.accuracy = 0.0,
    this.characterInputs = const [],
  });

  /// 사용 가능한 문장들
  @override
  final AsyncValue<List<Sentence>> availableSentences;

  /// 현재 연습 중인 문장
  @override
  final Sentence? currentSentence;

  /// 20자씩 분할된 문장 줄들
  @override
  final List<String> sentenceLines;

  /// 현재 입력 중인 줄 인덱스
  @override
  final int currentLineIndex;

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

  /// 분당 타수 (새로운 메인 지표)
  @override
  final double typingSpeed;

  /// 현재 정확도 (0-100) - 실시간 계산된 값
  @override
  final double accuracy;

  /// 각 글자별 입력 기록들
  @override
  final List<TypingCharacterInput> characterInputs;

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
      ? (userInput.length / totalSentenceLength).clamp(0.0, 1.0)
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
    if (currentSentence == null ||
        userInput.length >= currentSentence!.content.length) {
      return null;
    }
    return currentSentence!.content[userInput.length];
  }

  /// 현재 줄의 텍스트
  String get currentLineText {
    if (currentLineIndex >= sentenceLines.length) return '';
    return sentenceLines[currentLineIndex];
  }

  /// 다음 줄의 텍스트 (미리보기용)
  String get nextLineText {
    if (currentLineIndex + 1 >= sentenceLines.length) return '연습 완료!';
    return sentenceLines[currentLineIndex + 1];
  }

  /// 현재 줄에서의 입력 위치 (줄 내에서의 상대적 위치)
  int get currentLinePosition {
    if (sentenceLines.isEmpty || currentLineIndex >= sentenceLines.length) {
      return 0;
    }

    // 현재 줄까지의 모든 문자 수 계산
    int totalCharsBeforeCurrentLine = 0;
    for (int i = 0; i < currentLineIndex; i++) {
      totalCharsBeforeCurrentLine += sentenceLines[i].length;
    }

    return userInput.length - totalCharsBeforeCurrentLine;
  }

  /// 전체 텍스트에서 현재 줄의 시작 위치
  int get currentLineStartPosition {
    if (sentenceLines.isEmpty || currentLineIndex >= sentenceLines.length) {
      return 0;
    }

    int position = 0;
    for (int i = 0; i < currentLineIndex; i++) {
      position += sentenceLines[i].length;
    }
    return position;
  }

  /// 현재 줄이 완료되었는지 확인
  bool get isCurrentLineCompleted {
    return currentLinePosition >= currentLineText.length;
  }

  /// 모든 줄이 완료되었는지 확인
  bool get areAllLinesCompleted {
    return currentLineIndex >= sentenceLines.length - 1 &&
        isCurrentLineCompleted;
  }

  /// 현재 줄의 사용자 입력만 추출
  String get currentLineUserInput {
    final lineStartPos = currentLineStartPosition;
    final lineEndPos = lineStartPos + currentLineText.length;

    if (userInput.length <= lineStartPos) {
      return '';
    }

    final endIndex = userInput.length < lineEndPos
        ? userInput.length
        : lineEndPos;
    return userInput.substring(lineStartPos, endIndex);
  }
}
