// lib/typing/domain/model/sentence.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sentence.freezed.dart';

@freezed
class Sentence with _$Sentence {
  const Sentence({
    required this.id,
    required this.type,
    required this.language,
    required this.content,
    required this.difficulty,
    required this.wordCount,
    required this.category,
    required this.createdAt,
  });

  /// 문장 ID
  @override
  final String id;

  /// 연습 타입 ("word" 또는 "paragraph")
  @override
  final String type;

  /// 언어 ("ko" 또는 "en")
  @override
  final String language;

  /// 문장 내용
  @override
  final String content;

  /// 난이도 (1-5)
  @override
  final int difficulty;

  /// 단어 개수
  @override
  final int wordCount;

  /// 카테고리
  @override
  final String category;

  /// 생성 시간
  @override
  final DateTime createdAt;

  /// 단어 연습용 문장인지 확인
  bool get isWordType => type == 'word';

  /// 장문 연습용 문장인지 확인
  bool get isParagraphType => type == 'paragraph';

  /// 한글 문장인지 확인
  bool get isKorean => language == 'ko';

  /// 영문 문장인지 확인
  bool get isEnglish => language == 'en';

  /// 초급 난이도인지 확인 (1-2)
  bool get isBeginner => difficulty <= 2;

  /// 중급 난이도인지 확인 (3)
  bool get isIntermediate => difficulty == 3;

  /// 고급 난이도인지 확인 (4-5)
  bool get isAdvanced => difficulty >= 4;
}
