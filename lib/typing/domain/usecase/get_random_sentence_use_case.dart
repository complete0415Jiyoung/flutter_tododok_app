// lib/typing/domain/usecase/get_random_sentence_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/sentence.dart';
import '../repository/typing_repository.dart';

class GetRandomSentenceUseCase {
  final TypingRepository _repository;

  GetRandomSentenceUseCase({required TypingRepository repository})
    : _repository = repository;

  Future<AsyncValue<Sentence>> execute(String type, String language) async {
    final result = await _repository.getRandomSentence(type, language);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
