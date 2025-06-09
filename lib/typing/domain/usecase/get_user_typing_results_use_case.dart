// lib/typing/domain/usecase/get_user_typing_results_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/typing_result.dart';
import '../repository/typing_repository.dart';

class GetUserTypingResultsUseCase {
  final TypingRepository _repository;

  GetUserTypingResultsUseCase({required TypingRepository repository})
    : _repository = repository;

  Future<AsyncValue<List<TypingResult>>> execute(String userId) async {
    final result = await _repository.getUserTypingResults(userId);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
