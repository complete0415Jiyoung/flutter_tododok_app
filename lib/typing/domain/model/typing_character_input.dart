// lib/typing/domain/model/typing_character_input.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'typing_character_input.freezed.dart';

@freezed
class TypingCharacterInput with _$TypingCharacterInput {
  const TypingCharacterInput({
    required this.targetCharacter,
    required this.actualInput,
    required this.isCorrect,
    required this.timestamp,
    required this.inputDuration,
  });

  /// 목표 글자 (입력해야 할 글자)
  @override
  final String targetCharacter;

  /// 실제 입력한 글자
  @override
  final String actualInput;

  /// 정확성 여부
  @override
  final bool isCorrect;

  /// 입력한 시간
  @override
  final DateTime timestamp;

  /// 입력 소요 시간
  @override
  final Duration inputDuration;

  /// 오타인지 확인
  bool get isTypo => !isCorrect;

  /// 입력 속도가 빠른지 확인 (100ms 이하)
  bool get isFastInput => inputDuration.inMilliseconds <= 100;

  /// 입력 속도가 느린지 확인 (1초 이상)
  bool get isSlowInput => inputDuration.inMilliseconds >= 1000;

  /// 밀리초 단위 입력 시간 반환
  int get inputTimeInMs => inputDuration.inMilliseconds;
}
