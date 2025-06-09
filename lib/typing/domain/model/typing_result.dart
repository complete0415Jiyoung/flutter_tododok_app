// lib/typing/domain/model/typing_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'typing_result.freezed.dart';

@freezed
class TypingResult with _$TypingResult {
  const TypingResult({
    required this.id,
    required this.userId,
    required this.type,
    required this.mode,
    required this.sentenceId,
    required this.sentenceContent,
    required this.wpm,
    required this.accuracy,
    required this.typoCount,
    required this.totalCharacters,
    required this.correctCharacters,
    required this.duration,
    required this.language,
    required this.createdAt,
  });

  /// 결과 ID
  @override
  final String id;

  /// 사용자 UID
  @override
  final String userId;

  /// 결과 타입 ("practice" 또는 "challenge")
  @override
  final String type;

  /// 연습 모드 ("word" 또는 "paragraph")
  @override
  final String mode;

  /// 사용한 문장 ID
  @override
  final String sentenceId;

  /// 실제 연습한 문장 내용
  @override
  final String sentenceContent;

  /// 타자 속도 (Words Per Minute)
  @override
  final double wpm;

  /// 정확도 (0-100)
  @override
  final double accuracy;

  /// 오타 개수
  @override
  final int typoCount;

  /// 총 문자 수
  @override
  final int totalCharacters;

  /// 올바르게 입력한 문자 수
  @override
  final int correctCharacters;

  /// 입력 시간 (초)
  @override
  final double duration;

  /// 자판 언어 ("ko" 또는 "en")
  @override
  final String language;

  /// 생성 시간
  @override
  final DateTime createdAt;

  /// 연습 결과인지 확인
  bool get isPractice => type == 'practice';

  /// 도전장 결과인지 확인
  bool get isChallenge => type == 'challenge';

  /// 단어 연습 결과인지 확인
  bool get isWordMode => mode == 'word';

  /// 장문 연습 결과인지 확인
  bool get isParagraphMode => mode == 'paragraph';

  /// 한글 타자 결과인지 확인
  bool get isKorean => language == 'ko';

  /// 영문 타자 결과인지 확인
  bool get isEnglish => language == 'en';

  /// 우수한 정확도인지 확인 (90% 이상)
  bool get isGoodAccuracy => accuracy >= 90.0;

  /// 빠른 속도인지 확인 (60 WPM 이상)
  bool get isFastSpeed => wpm >= 60.0;

  /// 완벽한 타자인지 확인 (100% 정확도)
  bool get isPerfect => accuracy == 100.0;

  /// 오타율 계산
  double get errorRate =>
      totalCharacters > 0 ? (typoCount / totalCharacters) * 100 : 0.0;

  /// 분당 정확한 문자 수 (CPM - Characters Per Minute)
  double get cpm => duration > 0 ? (correctCharacters / duration) * 60 : 0.0;
}
