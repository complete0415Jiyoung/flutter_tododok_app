// lib/home/data/data_source/mock_home_data_source.dart
import '../dto/member_dto.dart';
import 'home_data_source.dart';

class MockHomeDataSource implements HomeDataSource {
  @override
  Future<MemberDto> fetchMemberStats() async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));

    return const MemberDto(
      averageWpm: 65.4,
      averageAccuracy: 92.8,
      totalPracticeCount: 47,
      totalChallengeCount: 12,
      challengeWinCount: 8,
      bestWpm: 89.2,
      bestAccuracy: 98.5,
    );
  }

  @override
  Future<List<String>> fetchRecentResults() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      '단어 연습 - 78 WPM, 94.2%',
      '장문 연습 - 62 WPM, 89.7%',
      '도전장 승리 - 71 WPM, 91.3%',
    ];
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return 3; // Mock 데이터: 읽지 않은 알림 3개
  }
}
