// lib/home/data/data_source/mock_home_data_source_impl.dart
import '../dto/member_dto.dart';
import 'home_data_source.dart';

class MockHomeDataSource implements HomeDataSource {
  @override
  Future<MemberDto> fetchMemberStats() async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));

    return const MemberDto(
      averageWpm: 327.0, // 분당 타수로 변경 (기존 65.4 * 5)
      averageAccuracy: 92.8,
      totalPracticeCount: 47,
      totalChallengeCount: 12,
      challengeWinCount: 8,
      bestWpm: 446.0, // 분당 타수로 변경 (기존 89.2 * 5)
      bestAccuracy: 98.5,
    );
  }

  @override
  Future<List<String>> fetchRecentResults() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      '단어 연습 - 390 타수, 94.2%', // 분당 타수로 표시 변경
      '장문 연습 - 310 타수, 89.7%', // 분당 타수로 표시 변경
      '도전장 승리 - 355 타수, 91.3%', // 분당 타수로 표시 변경
    ];
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return 3; // Mock 데이터: 읽지 않은 알림 3개
  }
}
