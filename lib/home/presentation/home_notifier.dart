// lib/home/presentation/home_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/usecase/get_member_stats_use_case.dart';
import '../domain/usecase/get_recent_results_use_case.dart';
import '../domain/usecase/get_unread_notification_count_use_case.dart';
import '../module/home_di.dart';
import 'home_state.dart';
import 'home_action.dart';

part 'home_notifier.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  late final GetMemberStatsUseCase _getMemberStatsUseCase;
  late final GetRecentResultsUseCase _getRecentResultsUseCase;
  late final GetUnreadNotificationCountUseCase
  _getUnreadNotificationCountUseCase;

  @override
  HomeState build() {
    // Provider들이 제대로 초기화되었는지 확인
    _getMemberStatsUseCase = ref.watch(getMemberStatsUseCaseProvider);
    _getRecentResultsUseCase = ref.watch(getRecentResultsUseCaseProvider);
    _getUnreadNotificationCountUseCase = ref.watch(
      getUnreadNotificationCountUseCaseProvider,
    );

    // 초기화를 비동기로 처리하지 말고 기본 상태만 반환
    return const HomeState();
  }

  Future<void> onAction(HomeAction action) async {
    switch (action) {
      case Initialize():
        await _initialize();
      case StartWordPractice():
        // 단어 연습 관련 로직 (필요시)
        break;
      case StartParagraphPractice():
        // 장문 연습 관련 로직 (필요시)
        break;
      case EnterFriendChallenge():
        // 친구 대결 관련 로직 (필요시)
        break;
      case ViewRecords():
        // 기록 보기 관련 로직 (필요시)
        break;
      case ViewNotifications():
        // 알림함 관련 로직 (필요시)
        break;
      case OpenSettings():
        // 설정 관련 로직 (필요시)
        break;
    }
  }

  Future<void> _initialize() async {
    if (state.isInitialized) return;

    // 각각 순차적으로 로딩
    try {
      final memberStats = await _getMemberStatsUseCase.execute();
      state = state.copyWith(memberStats: memberStats);

      final recentResults = await _getRecentResultsUseCase.execute();
      state = state.copyWith(recentResults: recentResults);

      final notificationCount = await _getUnreadNotificationCountUseCase
          .execute();
      switch (notificationCount) {
        case AsyncData(:final value):
          state = state.copyWith(unreadNotificationCount: value);
        case AsyncError():
          state = state.copyWith(unreadNotificationCount: 0);
        case AsyncLoading():
          break;
      }

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      // 오류 처리
      print('Home initialization error: $e');
    }
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isInitialized: false);
    await _initialize();
  }
}
