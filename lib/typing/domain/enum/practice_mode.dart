// lib/typing/domain/enum/practice_mode.dart
import 'package:flutter/material.dart';

enum PracticeMode {
  word('word', '단어 연습', Icons.sports_esports_rounded),
  paragraph('paragraph', '장문 연습', Icons.article_rounded);

  const PracticeMode(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final IconData icon;

  static PracticeMode fromValue(String value) {
    return PracticeMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => PracticeMode.word,
    );
  }

  bool get isWord => this == PracticeMode.word;
  bool get isParagraph => this == PracticeMode.paragraph;
}
