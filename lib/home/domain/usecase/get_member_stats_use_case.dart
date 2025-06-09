// lib/home/domain/usecase/get_member_stats_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/member.dart';
import '../repository/home_repository.dart';

class GetMemberStatsUseCase {
  final HomeRepository _repository;

  GetMemberStatsUseCase({required HomeRepository repository})
    : _repository = repository;

  Future<AsyncValue<Member>> execute() async {
    final result = await _repository.getMemberStats();

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
