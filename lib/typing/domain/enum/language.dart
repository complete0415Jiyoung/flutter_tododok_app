// lib/typing/domain/enum/language.dart
enum Language {
  korean('ko', '한글'),
  english('en', 'English');

  const Language(this.code, this.displayName);

  final String code;
  final String displayName;

  static Language fromCode(String code) {
    return Language.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => Language.korean,
    );
  }

  bool get isKorean => this == Language.korean;
  bool get isEnglish => this == Language.english;
}
