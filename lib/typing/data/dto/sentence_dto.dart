// lib/typing/data/dto/sentence_dto.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../core/utils/firebase_timestamp_converter.dart';

part 'sentence_dto.g.dart';

@JsonSerializable()
class SentenceDto {
  const SentenceDto({
    this.id,
    this.type,
    this.language,
    this.content,
    this.difficulty,
    this.wordCount,
    this.category,
    this.createdAt,
  });

  /// 문장 ID
  final String? id;

  /// 연습 타입 ("word" 또는 "paragraph")
  final String? type;

  /// 언어 ("ko" 또는 "en")
  final String? language;

  /// 문장 내용
  final String? content;

  /// 난이도 (1-5)
  final num? difficulty;

  /// 단어 개수
  final num? wordCount;

  /// 카테고리 (예: "기초", "고급", "프로그래밍" 등)
  final String? category;

  /// 생성 시간
  @JsonKey(
    fromJson: FirebaseTimestampConverter.timestampFromJson,
    toJson: FirebaseTimestampConverter.timestampToJson,
  )
  final DateTime? createdAt;

  factory SentenceDto.fromJson(Map<String, dynamic> json) =>
      _$SentenceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SentenceDtoToJson(this);
}
