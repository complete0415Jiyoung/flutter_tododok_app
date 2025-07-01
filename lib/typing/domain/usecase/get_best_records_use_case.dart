// lib/typing/domain/usecase/get_best_records_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/typing_result.dart';
import '../repository/typing_repository.dart';

class GetBestRecordsUseCase {
  final TypingRepository _repository;

  GetBestRecordsUseCase({required TypingRepository repository})
    : _repository = repository;

  Future<AsyncValue<TypingResult?>> getBestTypingSpeed(
    // 메서드명 변경
    String userId,
    String mode,
  ) async {
    final result = await _repository.getBestTypingSpeedResult(
      userId,
      mode,
    ); // 메서드명 변경

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }

  Future<AsyncValue<TypingResult?>> getBestAccuracy(
    String userId,
    String mode,
  ) async {
    final result = await _repository.getBestAccuracyResult(userId, mode);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
