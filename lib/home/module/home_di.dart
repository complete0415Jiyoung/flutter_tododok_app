// lib/home/module/home_di.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tododok/home/data/data_source/mock_home_data_source_impl.dart';
import 'package:tododok/home/domain/usecase/get_recent_results_use_case.dart';
import '../data/data_source/home_data_source.dart';
import '../data/repository_impl/home_repository_impl.dart';
import '../domain/repository/home_repository.dart';
import '../domain/usecase/get_member_stats_use_case.dart';
import '../domain/usecase/get_unread_notification_count_use_case.dart';

part 'home_di.g.dart';

/// DataSource Provider (Mock 데이터 사용, 상태 유지 필요)
@Riverpod(keepAlive: true)
HomeDataSource homeDataSource(HomeDataSourceRef ref) => MockHomeDataSource();

/// Repository Provider
@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) =>
    HomeRepositoryImpl(dataSource: ref.watch(homeDataSourceProvider));

/// UseCase Providers
@riverpod
GetMemberStatsUseCase getMemberStatsUseCase(GetMemberStatsUseCaseRef ref) =>
    GetMemberStatsUseCase(repository: ref.watch(homeRepositoryProvider));

@riverpod
GetRecentResultsUseCase getRecentResultsUseCase(
  GetRecentResultsUseCaseRef ref,
) => GetRecentResultsUseCase(repository: ref.watch(homeRepositoryProvider));

@riverpod
GetUnreadNotificationCountUseCase getUnreadNotificationCountUseCase(
  GetUnreadNotificationCountUseCaseRef ref,
) => GetUnreadNotificationCountUseCase(
  repository: ref.watch(homeRepositoryProvider),
);
