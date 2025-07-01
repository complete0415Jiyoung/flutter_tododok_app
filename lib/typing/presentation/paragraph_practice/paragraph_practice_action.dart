// lib/typing/presentation/paragraph_practice/paragraph_practice_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'paragraph_practice_action.freezed.dart';

@freezed
sealed class ParagraphPracticeAction with _$ParagraphPracticeAction {
  /// 화면 초기화 (문장 로드)
  const factory ParagraphPracticeAction.initialize(String language) =
      Initialize;

  /// 연습할 문장 선택
  const factory ParagraphPracticeAction.selectSentence(String sentenceId) =
      SelectSentence;

  /// 랜덤 문장 선택
  const factory ParagraphPracticeAction.selectRandomSentence() =
      SelectRandomSentence;

  /// 연습 시작
  const factory ParagraphPracticeAction.startPractice() = StartPractice;

  /// 연습 일시정지
  const factory ParagraphPracticeAction.pausePractice() = PausePractice;

  /// 연습 재개
  const factory ParagraphPracticeAction.resumePractice() = ResumePractice;

  /// 연습 재시작 (처음부터 다시)
  const factory ParagraphPracticeAction.restartPractice() = RestartPractice;

  /// 연습 완료 (자동 호출)
  const factory ParagraphPracticeAction.completePractice() = CompletePractice;

  /// 사용자 입력 변경
  const factory ParagraphPracticeAction.updateInput(String input) = UpdateInput;

  /// 백스페이스 처리
  const factory ParagraphPracticeAction.handleBackspace() = HandleBackspace;

  /// 단일 글자 입력 처리
  const factory ParagraphPracticeAction.inputCharacter(String character) =
      InputCharacter;

  /// 실시간 통계 업데이트
  const factory ParagraphPracticeAction.updateStats() = UpdateStats;

  /// 언어 변경
  const factory ParagraphPracticeAction.changeLanguage(String language) =
      ChangeLanguage;

  /// 결과 저장
  const factory ParagraphPracticeAction.saveResult() = SaveResult;

  /// 결과 화면으로 이동
  const factory ParagraphPracticeAction.navigateToResult() = NavigateToResult;

  /// 홈으로 돌아가기
  const factory ParagraphPracticeAction.navigateToHome() = NavigateToHome;

  /// 도전장 생성하기
  const factory ParagraphPracticeAction.createChallenge() = CreateChallenge;

  /// 다른 문장으로 연습하기
  const factory ParagraphPracticeAction.practiceAnotherSentence() =
      PracticeAnotherSentence;
}
