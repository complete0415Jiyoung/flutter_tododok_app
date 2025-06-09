// lib/typing/data/repository_impl/typing_repository_impl.dart
import '../../../shared/models/result.dart';
import '../../domain/model/sentence.dart';
import '../../domain/model/typing_result.dart';
import '../../domain/repository/typing_repository.dart';
import '../data_source/typing_data_source.dart';
import '../mapper/sentence_mapper.dart';
import '../mapper/typing_result_mapper.dart';

class TypingRepositoryImpl implements TypingRepository {
  final TypingDataSource _dataSource;

  TypingRepositoryImpl({required TypingDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<List<Sentence>>> getSentencesByType(String type) async {
    try {
      final dtoList = await _dataSource.fetchSentencesByType(type);
      final sentences = dtoList.toModelList();
      return Result.success(sentences);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<Sentence>>> getSentencesByLanguage(String language) async {
    try {
      final dtoList = await _dataSource.fetchSentencesByLanguage(language);
      final sentences = dtoList.toModelList();
      return Result.success(sentences);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<Sentence>>> getSentences(
    String type,
    String language,
  ) async {
    try {
      final dtoList = await _dataSource.fetchSentences(type, language);
      final sentences = dtoList.toModelList();
      return Result.success(sentences);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Sentence>> getSentenceById(String sentenceId) async {
    try {
      final dto = await _dataSource.fetchSentenceById(sentenceId);
      final sentence = dto.toModel();
      return Result.success(sentence);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<Sentence>> getRandomSentence(
    String type,
    String language,
  ) async {
    try {
      final dto = await _dataSource.fetchRandomSentence(type, language);
      final sentence = dto.toModel();
      return Result.success(sentence);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TypingResult>> saveTypingResult(TypingResult result) async {
    try {
      final dto = result.toDto();
      final savedId = await _dataSource.saveTypingResult(dto);

      // 저장된 ID로 결과 업데이트
      final savedResult = result.copyWith(id: savedId);
      return Result.success(savedResult);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TypingResult>>> getUserTypingResults(String userId) async {
    try {
      final dtoList = await _dataSource.fetchUserTypingResults(userId);
      final results = dtoList.toModelList();
      return Result.success(results);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TypingResult>>> getRecentTypingResults(
    String userId,
    int limit,
  ) async {
    try {
      final dtoList = await _dataSource.fetchRecentTypingResults(userId, limit);
      final results = dtoList.toModelList();
      return Result.success(results);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<List<TypingResult>>> getTypingResultsByMode(
    String userId,
    String mode,
  ) async {
    try {
      final dtoList = await _dataSource.fetchTypingResultsByMode(userId, mode);
      final results = dtoList.toModelList();
      return Result.success(results);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TypingResult?>> getBestWpmResult(
    String userId,
    String mode,
  ) async {
    try {
      final dto = await _dataSource.fetchBestWpmResult(userId, mode);
      final result = dto?.toModel();
      return Result.success(result);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  @override
  Future<Result<TypingResult?>> getBestAccuracyResult(
    String userId,
    String mode,
  ) async {
    try {
      final dto = await _dataSource.fetchBestAccuracyResult(userId, mode);
      final result = dto?.toModel();
      return Result.success(result);
    } catch (e, st) {
      return Result.error(mapExceptionToFailure(e, st));
    }
  }
}
