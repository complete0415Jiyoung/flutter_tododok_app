// lib/typing/domain/enum/sentence_category.dart
enum SentenceCategory {
  daily('일상'),
  technology('기술'),
  education('교육'),
  health('건강'),
  selfDevelopment('자기계발'),
  art('예술'),
  environment('환경'),
  business('비즈니스'),
  science('과학'),
  sports('스포츠');

  const SentenceCategory(this.displayName);

  final String displayName;

  static SentenceCategory fromDisplayName(String displayName) {
    return SentenceCategory.values.firstWhere(
      (category) => category.displayName == displayName,
      orElse: () => SentenceCategory.daily,
    );
  }

  static List<String> get allDisplayNames {
    return SentenceCategory.values.map((e) => e.displayName).toList();
  }
}
