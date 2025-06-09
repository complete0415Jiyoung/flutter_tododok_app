// lib/home/domain/repository/home_repository.dart
import 'package:tododok/home/domain/model/member.dart';
import '../../../shared/models/result.dart';

abstract interface class HomeRepository {
  /// 사용자 통계 정보 조회
  Future<Result<Member>> getMemberStats();

  /// 최근 연습 결과 목록 조회 (간단한 문자열 목록)
  Future<Result<List<String>>> getRecentResults();

  /// 읽지 않은 알림 개수 조회
  Future<Result<int>> getUnreadNotificationCount();
}
