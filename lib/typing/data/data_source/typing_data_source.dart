// lib/typing/data/data_source/typing_data_source.dart
import '../dto/sentence_dto.dart';
import '../dto/typing_result_dto.dart';

abstract interface class TypingDataSource {
  /// 연습 문장 목록 조회 (타입별)
  Future<List<SentenceDto>> fetchSentencesByType(String type);

  /// 연습 문장 목록 조회 (언어별)
  Future<List<SentenceDto>> fetchSentencesByLanguage(String language);

  /// 연습 문장 목록 조회 (타입 + 언어)
  Future<List<SentenceDto>> fetchSentences(String type, String language);

  /// 특정 문장 조회
  Future<SentenceDto> fetchSentenceById(String sentenceId);

  /// 랜덤 문장 조회
  Future<SentenceDto> fetchRandomSentence(String type, String language);

  /// 타자 연습 결과 저장
  Future<String> saveTypingResult(TypingResultDto result);

  /// 사용자의 타자 결과 목록 조회
  Future<List<TypingResultDto>> fetchUserTypingResults(String userId);

  /// 사용자의 최근 타자 결과 조회 (제한된 개수)
  Future<List<TypingResultDto>> fetchRecentTypingResults(
    String userId,
    int limit,
  );

  /// 특정 모드의 타자 결과 조회
  Future<List<TypingResultDto>> fetchTypingResultsByMode(
    String userId,
    String mode,
  );

  /// 최고 기록 조회 (WPM 기준)
  Future<TypingResultDto?> fetchBestWpmResult(String userId, String mode);

  /// 최고 정확도 기록 조회
  Future<TypingResultDto?> fetchBestAccuracyResult(String userId, String mode);
}
