// lib/home/data/data_source/home_data_source.dart
import '../dto/member_dto.dart';

abstract interface class HomeDataSource {
  /// 사용자 통계 정보 조회
  Future<MemberDto> fetchMemberStats();

  /// 최근 연습 결과 목록 조회
  Future<List<String>> fetchRecentResults();

  /// 읽지 않은 알림 개수 조회
  Future<int> fetchUnreadNotificationCount();
}
