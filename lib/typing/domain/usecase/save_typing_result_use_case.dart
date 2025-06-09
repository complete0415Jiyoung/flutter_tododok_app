// lib/typing/domain/usecase/save_typing_result_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/typing_result.dart';
import '../repository/typing_repository.dart';

class SaveTypingResultUseCase {
  final TypingRepository _repository;

  SaveTypingResultUseCase({required TypingRepository repository})
    : _repository = repository;

  Future<AsyncValue<TypingResult>> execute(TypingResult result) async {
    final saveResult = await _repository.saveTypingResult(result);

    switch (saveResult) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
