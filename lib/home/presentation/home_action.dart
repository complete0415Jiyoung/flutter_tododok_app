// lib/home/presentation/home_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_action.freezed.dart';

@freezed
sealed class HomeAction with _$HomeAction {
  /// 타자 연습 시작 (단어 모드)
  const factory HomeAction.startWordPractice() = StartWordPractice;

  /// 타자 연습 시작 (장문 모드)
  const factory HomeAction.startParagraphPractice() = StartParagraphPractice;

  /// 친구 대결 메뉴 진입
  const factory HomeAction.enterFriendChallenge() = EnterFriendChallenge;

  /// 기록 보기 메뉴 진입
  const factory HomeAction.viewRecords() = ViewRecords;

  /// 알림함 메뉴 진입
  const factory HomeAction.viewNotifications() = ViewNotifications;

  /// 설정 메뉴 진입
  const factory HomeAction.openSettings() = OpenSettings;

  /// 화면 초기화 (진입 시 호출)
  const factory HomeAction.initialize() = Initialize;
}
