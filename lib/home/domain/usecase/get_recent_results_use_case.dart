// lib/home/domain/usecase/get_recent_results_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../repository/home_repository.dart';

class GetRecentResultsUseCase {
  final HomeRepository _repository;

  GetRecentResultsUseCase({required HomeRepository repository})
    : _repository = repository;

  Future<AsyncValue<List<String>>> execute() async {
    final result = await _repository.getRecentResults();

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
