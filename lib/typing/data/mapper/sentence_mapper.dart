// lib/typing/data/mapper/sentence_mapper.dart
import '../../domain/model/sentence.dart';
import '../dto/sentence_dto.dart';

extension SentenceDtoMapper on SentenceDto {
  Sentence toModel() {
    return Sentence(
      id: id ?? '',
      type: type ?? 'word',
      language: language ?? 'ko',
      content: content ?? '',
      difficulty: (difficulty ?? 1).toInt(),
      wordCount: (wordCount ?? 0).toInt(),
      category: category ?? '기본',
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension SentenceModelMapper on Sentence {
  SentenceDto toDto() {
    return SentenceDto(
      id: id,
      type: type,
      language: language,
      content: content,
      difficulty: difficulty,
      wordCount: wordCount,
      category: category,
      createdAt: createdAt,
    );
  }
}

extension SentenceDtoListMapper on List<SentenceDto>? {
  List<Sentence> toModelList() => this?.map((e) => e.toModel()).toList() ?? [];
}

extension MapToSentenceDto on Map<String, dynamic> {
  SentenceDto toSentenceDto() => SentenceDto.fromJson(this);
}

extension MapListToSentenceDtoList on List<Map<String, dynamic>>? {
  List<SentenceDto> toSentenceDtoList() =>
      this?.map((e) => SentenceDto.fromJson(e)).toList() ?? [];
}
