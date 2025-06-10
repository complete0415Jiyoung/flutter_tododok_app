// lib/typing/presentation/word_practice/word_practice_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_practice_action.freezed.dart';

@freezed
sealed class WordPracticeAction with _$WordPracticeAction {
  /// 화면 초기화 (문장 로드)
  const factory WordPracticeAction.initialize(String language) = Initialize;

  /// 특정 문장으로 초기화 (문장 선택에서 온 경우)
  const factory WordPracticeAction.initializeWithSentence(
    String language,
    String sentenceId,
  ) = InitializeWithSentence;

  /// 랜덤 문장으로 초기화
  const factory WordPracticeAction.initializeWithRandom(String language) =
      InitializeWithRandom;

  /// 게임 시작
  const factory WordPracticeAction.startGame() = StartGame;

  /// 게임 일시정지
  const factory WordPracticeAction.pauseGame() = PauseGame;

  /// 게임 재개
  const factory WordPracticeAction.resumeGame() = ResumeGame;

  /// 게임 종료
  const factory WordPracticeAction.endGame() = EndGame;

  /// 게임 재시작
  const factory WordPracticeAction.restartGame() = RestartGame;

  /// 새로운 단어 생성
  const factory WordPracticeAction.spawnWord() = SpawnWord;

  /// 떨어지는 단어들 위치 업데이트
  const factory WordPracticeAction.updateFallingWords(double deltaTime) =
      UpdateFallingWords;

  /// 사용자 입력 변경
  const factory WordPracticeAction.updateInput(String input) = UpdateInput;

  /// 입력된 단어 확인 (엔터 또는 스페이스)
  const factory WordPracticeAction.submitInput() = SubmitInput;

  /// 단어 매칭 성공
  const factory WordPracticeAction.wordMatched(String wordId) = WordMatched;

  /// 단어 놓침 (화면 하단 도달)
  const factory WordPracticeAction.wordMissed(String wordId) = WordMissed;

  /// 레벨 업
  const factory WordPracticeAction.levelUp() = LevelUp;

  /// 언어 변경
  const factory WordPracticeAction.changeLanguage(String language) =
      ChangeLanguage;

  /// 결과 화면으로 이동
  const factory WordPracticeAction.navigateToResult() = NavigateToResult;

  /// 홈으로 돌아가기
  const factory WordPracticeAction.navigateToHome() = NavigateToHome;
}
