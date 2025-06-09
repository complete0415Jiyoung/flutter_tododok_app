// lib/home/domain/usecase/get_unread_notification_count_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../repository/home_repository.dart';

class GetUnreadNotificationCountUseCase {
  final HomeRepository _repository;

  GetUnreadNotificationCountUseCase({required HomeRepository repository})
    : _repository = repository;

  Future<AsyncValue<int>> execute() async {
    final result = await _repository.getUnreadNotificationCount();

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
