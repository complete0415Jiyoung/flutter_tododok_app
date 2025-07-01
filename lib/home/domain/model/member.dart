// lib/home/domain/model/member.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';

@freezed
class Member with _$Member {
  const Member({
    required this.averageTypingSpeed, // averageWpm → averageTypingSpeed로 변경
    required this.averageAccuracy,
    required this.totalPracticeCount,
    required this.totalChallengeCount,
    required this.challengeWinCount,
    required this.bestTypingSpeed, // bestWpm → bestTypingSpeed로 변경
    required this.bestAccuracy,
  });

  /// 평균 타자 속도 (분당 타수 - CPM)
  @override
  final double averageTypingSpeed;

  /// 평균 정확도 (%)
  @override
  final double averageAccuracy;

  /// 총 연습 횟수
  @override
  final int totalPracticeCount;

  /// 총 도전장 참여 횟수
  @override
  final int totalChallengeCount;

  /// 도전장 승리 횟수
  @override
  final int challengeWinCount;

  /// 최고 타자 속도 (분당 타수 - CPM)
  @override
  final double bestTypingSpeed;

  /// 최고 정확도 (%)
  @override
  final double bestAccuracy;

  /// 도전장 승률 계산
  double get winRate => totalChallengeCount > 0
      ? (challengeWinCount / totalChallengeCount) * 100
      : 0.0;

  // 호환성을 위한 getter (기존 코드와의 compatibility)
  @Deprecated('Use averageTypingSpeed instead')
  double get averageWpm => averageTypingSpeed / 5.0; // 대략적인 변환 (5글자 = 1단어)

  @Deprecated('Use bestTypingSpeed instead')
  double get bestWpm => bestTypingSpeed / 5.0; // 대략적인 변환 (5글자 = 1단어)
}
