// lib/typing/data/mapper/typing_result_mapper.dart
import '../../domain/model/typing_result.dart';
import '../dto/typing_result_dto.dart';

extension TypingResultDtoMapper on TypingResultDto {
  TypingResult toModel() {
    return TypingResult(
      id: id ?? '',
      userId: userId ?? '',
      type: type ?? 'practice',
      mode: mode ?? 'word',
      sentenceId: sentenceId ?? '',
      sentenceContent: sentenceContent ?? '',
      typingSpeed: (wpm ?? 0).toDouble() * 5.0, // WPM을 분당 타수로 변환
      accuracy: (accuracy ?? 0).toDouble(),
      typoCount: (typoCount ?? 0).toInt(),
      totalCharacters: (totalCharacters ?? 0).toInt(),
      correctCharacters: (correctCharacters ?? 0).toInt(),
      duration: (duration ?? 0).toDouble(),
      language: language ?? 'ko',
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension TypingResultModelMapper on TypingResult {
  TypingResultDto toDto() {
    return TypingResultDto(
      id: id,
      userId: userId,
      type: type,
      mode: mode,
      sentenceId: sentenceId,
      sentenceContent: sentenceContent,
      wpm: typingSpeed / 5.0, // 분당 타수를 WPM으로 변환 (Firebase 호환성)
      accuracy: accuracy,
      typoCount: typoCount,
      totalCharacters: totalCharacters,
      correctCharacters: correctCharacters,
      duration: duration,
      language: language,
      createdAt: createdAt,
    );
  }
}

extension TypingResultDtoListMapper on List<TypingResultDto>? {
  List<TypingResult> toModelList() =>
      this?.map((e) => e.toModel()).toList() ?? [];
}

extension MapToTypingResultDto on Map<String, dynamic> {
  TypingResultDto toTypingResultDto() => TypingResultDto.fromJson(this);
}

extension MapListToTypingResultDtoList on List<Map<String, dynamic>>? {
  List<TypingResultDto> toTypingResultDtoList() =>
      this?.map((e) => TypingResultDto.fromJson(e)).toList() ?? [];
}
