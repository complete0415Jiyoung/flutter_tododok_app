// lib/home/presentation/home_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tododok/home/domain/model/member.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const HomeState({
    this.memberStats = const AsyncLoading(),
    this.recentResults = const AsyncLoading(),
    this.unreadNotificationCount = 0,
    this.isInitialized = false,
  });

  /// 사용자 통계 정보 (평균 WPM, 정확도 등)
  @override
  final AsyncValue<Member> memberStats;

  /// 최근 연습 결과 목록 (홈화면에서 간단히 표시용)
  @override
  final AsyncValue<List<String>> recentResults; // Mock용으로 간단히 String 리스트

  /// 읽지 않은 알림 개수
  @override
  final int unreadNotificationCount;

  /// 초기화 완료 여부
  @override
  final bool isInitialized;
}
