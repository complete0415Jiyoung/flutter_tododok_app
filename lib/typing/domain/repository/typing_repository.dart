// lib/typing/domain/repository/typing_repository.dart
import '../../../shared/models/result.dart';
import '../model/sentence.dart';
import '../model/typing_result.dart';

abstract interface class TypingRepository {
  /// 연습 문장 목록 조회 (타입별)
  Future<Result<List<Sentence>>> getSentencesByType(String type);

  /// 연습 문장 목록 조회 (언어별)
  Future<Result<List<Sentence>>> getSentencesByLanguage(String language);

  /// 연습 문장 목록 조회 (타입 + 언어)
  Future<Result<List<Sentence>>> getSentences(String type, String language);

  /// 특정 문장 조회
  Future<Result<Sentence>> getSentenceById(String sentenceId);

  /// 랜덤 문장 조회
  Future<Result<Sentence>> getRandomSentence(String type, String language);

  /// 타자 연습 결과 저장
  Future<Result<TypingResult>> saveTypingResult(TypingResult result);

  /// 사용자의 타자 결과 목록 조회
  Future<Result<List<TypingResult>>> getUserTypingResults(String userId);

  /// 사용자의 최근 타자 결과 조회 (제한된 개수)
  Future<Result<List<TypingResult>>> getRecentTypingResults(
    String userId,
    int limit,
  );

  /// 특정 모드의 타자 결과 조회
  Future<Result<List<TypingResult>>> getTypingResultsByMode(
    String userId,
    String mode,
  );

  /// 최고 기록 조회 (분당 타수 기준) - 메서드명 변경
  Future<Result<TypingResult?>> getBestTypingSpeedResult(
    String userId,
    String mode,
  );

  /// 최고 정확도 기록 조회
  Future<Result<TypingResult?>> getBestAccuracyResult(
    String userId,
    String mode,
  );
}
