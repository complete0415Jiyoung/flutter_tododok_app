// lib/home/domain/model/member.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';

@freezed
class Member with _$Member {
  const Member({
    required this.averageWpm,
    required this.averageAccuracy,
    required this.totalPracticeCount,
    required this.totalChallengeCount,
    required this.challengeWinCount,
    required this.bestWpm,
    required this.bestAccuracy,
  });

  /// 평균 타자 속도 (WPM)
  @override
  final double averageWpm;

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

  /// 최고 타자 속도 (WPM)
  @override
  final double bestWpm;

  /// 최고 정확도 (%)
  @override
  final double bestAccuracy;

  /// 도전장 승률 계산
  double get winRate => totalChallengeCount > 0
      ? (challengeWinCount / totalChallengeCount) * 100
      : 0.0;
}
