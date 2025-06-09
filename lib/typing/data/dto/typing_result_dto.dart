// lib/typing/data/dto/typing_result_dto.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../core/utils/firebase_timestamp_converter.dart';

part 'typing_result_dto.g.dart';

@JsonSerializable()
class TypingResultDto {
  const TypingResultDto({
    this.id,
    this.userId,
    this.type,
    this.mode,
    this.sentenceId,
    this.sentenceContent,
    this.wpm,
    this.accuracy,
    this.typoCount,
    this.totalCharacters,
    this.correctCharacters,
    this.duration,
    this.language,
    this.createdAt,
  });

  /// 결과 ID
  final String? id;

  /// 사용자 UID
  final String? userId;

  /// 결과 타입 ("practice" 또는 "challenge")
  final String? type;

  /// 연습 모드 ("word" 또는 "paragraph")
  final String? mode;

  /// 사용한 문장 ID
  final String? sentenceId;

  /// 실제 연습한 문장 내용 (백업용)
  final String? sentenceContent;

  /// 타자 속도 (Words Per Minute)
  final num? wpm;

  /// 정확도 (0-100)
  final num? accuracy;

  /// 오타 개수
  final num? typoCount;

  /// 총 문자 수
  final num? totalCharacters;

  /// 올바르게 입력한 문자 수
  final num? correctCharacters;

  /// 입력 시간 (초)
  final num? duration;

  /// 자판 언어 ("ko" 또는 "en")
  final String? language;

  /// 생성 시간
  @JsonKey(
    fromJson: FirebaseTimestampConverter.timestampFromJson,
    toJson: FirebaseTimestampConverter.timestampToJson,
  )
  final DateTime? createdAt;

  factory TypingResultDto.fromJson(Map<String, dynamic> json) =>
      _$TypingResultDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TypingResultDtoToJson(this);
}
