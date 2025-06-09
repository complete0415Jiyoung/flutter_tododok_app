// lib/typing/domain/usecase/get_sentences_use_case.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/models/result.dart';
import '../model/sentence.dart';
import '../repository/typing_repository.dart';

class GetSentencesUseCase {
  final TypingRepository _repository;

  GetSentencesUseCase({required TypingRepository repository})
    : _repository = repository;

  Future<AsyncValue<List<Sentence>>> execute(
    String type,
    String language,
  ) async {
    final result = await _repository.getSentences(type, language);

    switch (result) {
      case Success(:final data):
        return AsyncData(data);
      case Error(:final failure):
        return AsyncError(failure, failure.stackTrace ?? StackTrace.current);
    }
  }
}
