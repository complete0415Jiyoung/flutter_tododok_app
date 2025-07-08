// lib/typing/domain/enum/difficulty_level.dart
import 'package:flutter/material.dart';

enum DifficultyLevel {
  beginner(1, '쉬움', Color(0xFF10B981)),
  intermediate(2, '보통', Color(0xFF3B82F6)),
  advanced(3, '어려움', Color(0xFFF59E0B)),
  expert(4, '매우어려움', Color(0xFFEF4444)),
  master(5, '최고난이도', Color(0xFF8B5CF6));

  const DifficultyLevel(this.level, this.label, this.color);

  final int level;
  final String label;
  final Color color;

  static DifficultyLevel fromLevel(int level) {
    return DifficultyLevel.values.firstWhere(
      (difficulty) => difficulty.level == level,
      orElse: () => DifficultyLevel.beginner,
    );
  }

  bool get isBeginner => level <= 2;
  bool get isIntermediate => level == 3;
  bool get isAdvanced => level >= 4;
}
