// lib/typing/presentation/word_practice/word_practice_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_practice_action.freezed.dart';

@freezed
sealed class WordPracticeAction with _$WordPracticeAction {
  // 초기화 액션들
  const factory WordPracticeAction.initialize(String language) = Initialize;
  const factory WordPracticeAction.initializeWithSentence(
    String language,
    String sentenceId,
  ) = InitializeWithSentence;
  const factory WordPracticeAction.initializeWithRandom(String language) =
      InitializeWithRandom;

  // 게임 제어 액션들
  const factory WordPracticeAction.startGame() = StartGame;
  const factory WordPracticeAction.pauseGame() = PauseGame;
  const factory WordPracticeAction.resumeGame() = ResumeGame;
  const factory WordPracticeAction.restartGame() = RestartGame;
  const factory WordPracticeAction.endGame() = EndGame;

  // 단어 입력 관련 액션들
  const factory WordPracticeAction.updateInput(String input) = UpdateInput;
  const factory WordPracticeAction.submitCurrentWord() = SubmitCurrentWord;
  const factory WordPracticeAction.skipCurrentWord() = SkipCurrentWord;
  const factory WordPracticeAction.clearInput() = ClearInput;

  // 단어 진행 관련 액션들
  const factory WordPracticeAction.moveToNextWord() = MoveToNextWord;
  const factory WordPracticeAction.moveToPreviousWord() = MoveToPreviousWord;
  const factory WordPracticeAction.completeCurrentWord({
    required bool isCorrect,
    required double timeTaken,
  }) = CompleteCurrentWord;

  // 힌트 관련 액션들
  const factory WordPracticeAction.showHint() = ShowHint;
  const factory WordPracticeAction.hideHint() = HideHint;
  const factory WordPracticeAction.useHint() = UseHint;

  // 통계 업데이트 액션들
  const factory WordPracticeAction.updateStatistics() = UpdateStatistics;
  const factory WordPracticeAction.calculateWpm() = CalculateWpm;
  const factory WordPracticeAction.calculateAccuracy() = CalculateAccuracy;

  // 시퀀스 관리 액션들
  const factory WordPracticeAction.loadWordSequence({
    required String sentenceText,
    required String sentenceId,
  }) = LoadWordSequence;
  const factory WordPracticeAction.generateNewSequence() = GenerateNewSequence;
  const factory WordPracticeAction.completeSequence() = CompleteSequence;

  // 설정 변경 액션들
  const factory WordPracticeAction.changeLanguage(String language) =
      ChangeLanguage;
  const factory WordPracticeAction.setTargetWordCount(int count) =
      SetTargetWordCount;

  // 네비게이션 액션들
  const factory WordPracticeAction.navigateToResult() = NavigateToResult;
  const factory WordPracticeAction.navigateToHome() = NavigateToHome;
  const factory WordPracticeAction.navigateToSentenceSelection() =
      NavigateToSentenceSelection;

  // 에러 처리 액션들
  const factory WordPracticeAction.handleError(String errorMessage) =
      HandleError;
  const factory WordPracticeAction.clearError() = ClearError;

  // 게임 상태 체크 액션들
  const factory WordPracticeAction.checkGameCompletion() = CheckGameCompletion;
  const factory WordPracticeAction.validateInput() = ValidateInput;

  // 타이머 관련 액션들
  const factory WordPracticeAction.startTimer() = StartTimer;
  const factory WordPracticeAction.stopTimer() = StopTimer;
  const factory WordPracticeAction.updateTimer() = UpdateTimer;
}
