// lib/home/data/repository_impl/home_repository_impl.dart
import 'package:tododok/home/domain/model/member.dart';

import '../../../shared/models/result.dart';
import '../../domain/repository/home_repository.dart';
import '../data_source/home_data_source.dart';
import '../mapper/member_mapper.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;

  HomeRepositoryImpl({required HomeDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<Member>> getMemberStats() async {
    try {
      final dto = await _dataSource.fetchMemberStats();
      final member = dto.toModel(); // DTO → Model 변환
      return Result.success(member);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<String>>> getRecentResults() async {
    try {
      final data = await _dataSource.fetchRecentResults();
      return Result.success(data);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<int>> getUnreadNotificationCount() async {
    try {
      final data = await _dataSource.fetchUnreadNotificationCount();
      return Result.success(data);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }
}
