// lib/typing/presentation/paragraph_practice/services/typing_validation_service.dart
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors_style.dart';
import 'korean_text_processor.dart';

/// 타이핑 검증 전담 서비스
class TypingValidationService {
  final KoreanTextProcessor _koreanProcessor = KoreanTextProcessor();

  /// 받침 누락 감지 핵심 메서드
  bool hasIncompleteInput({
    required String inputChar,
    required int targetElementIndex,
    required int charIndex,
    required String inputText,
    required String targetText,
  }) {
    print('받침 누락 검사 시작: $inputChar at index $targetElementIndex');

    // 현재 입력된 글자의 요소들
    List<String> inputElements = _koreanProcessor.decomposeCharacterToElements(
      inputChar,
    );

    // 목표 위치에서 예상되는 완전한 글자 찾기
    String? expectedCompleteChar = _koreanProcessor.findExpectedCharacterAt(
      elementIndex: targetElementIndex,
      targetText: targetText,
    );

    if (expectedCompleteChar == null) {
      print('예상 글자를 찾을 수 없음');
      return false;
    }

    // 예상 글자의 요소들
    List<String> expectedElements = _koreanProcessor
        .decomposeCharacterToElements(expectedCompleteChar);

    print(
      '받침 누락 검사 상세: 입력=$inputChar(${inputElements.join(',')}) vs 예상=$expectedCompleteChar(${expectedElements.join(',')})',
    );

    // 🎯 핵심 받침 누락 조건 확인
    if (expectedElements.length == 3 && inputElements.length == 2) {
      // 초성과 중성 비교
      bool initialMatch = expectedElements[0] == inputElements[0]; // 초성
      bool medialMatch = expectedElements[1] == inputElements[1]; // 중성

      if (initialMatch && medialMatch) {
        print('✅ 받침 누락 확인됨: ${expectedElements[2]} 누락됨');
        return true; // 받침이 누락됨
      } else {
        print('❌ 초성/중성 불일치: 초성($initialMatch), 중성($medialMatch)');
      }
    } else {
      print(
        '❌ 요소 개수가 받침 누락 조건에 맞지 않음: expected=${expectedElements.length}, input=${inputElements.length}',
      );
    }

    return false;
  }

  /// 불일치 시 받침 누락 재검사 메서드
  bool isIncompleteCharacterMatch({
    required String inputChar,
    required int targetElementIndex,
    required List<String> targetElements,
  }) {
    List<String> inputElements = _koreanProcessor.decomposeCharacterToElements(
      inputChar,
    );

    // 현재 인덱스부터 시작해서 입력 글자의 요소들이 순차적으로 일치하는지 확인
    for (int i = 0; i < inputElements.length; i++) {
      final checkIndex = targetElementIndex + i;
      if (checkIndex >= targetElements.length) return false;
      if (inputElements[i] != targetElements[checkIndex]) return false;
    }

    // 입력 글자의 요소들이 모두 일치하면, 다음 요소가 받침인지 확인
    final nextIndex = targetElementIndex + inputElements.length;
    if (nextIndex < targetElements.length) {
      String nextElement = targetElements[nextIndex];
      if (_koreanProcessor.isConsonant(nextElement)) {
        print('다음 요소가 받침임: $nextElement');
        return true; // 받침이 누락된 것으로 판정
      }
    }

    return false;
  }

  /// 완성된 글자의 색상 결정 - 받침 누락 감지 포함
  Color getCompleteCharacterColor({
    required String inputChar,
    required int targetElementIndex,
    required int charIndex,
    required String inputText,
    required List<String> targetElements,
    required String targetText,
  }) {
    List<String> charElements = _koreanProcessor.decomposeCharacterToElements(
      inputChar,
    );

    print(
      '완성된 글자 검증: $inputChar, 시작인덱스: $targetElementIndex, 요소들: $charElements',
    );

    // 🎯 먼저 받침 누락 감지 로직 실행
    if (hasIncompleteInput(
      inputChar: inputChar,
      targetElementIndex: targetElementIndex,
      charIndex: charIndex,
      inputText: inputText,
      targetText: targetText,
    )) {
      print('받침 누락 감지: $inputChar');
      return AppColorsStyle.error; // ❌ 빨간색 (받침 누락)
    }

    // 기존 로직: 현재 목표 인덱스부터 이 글자의 요소들이 순차적으로 일치하는지 확인
    for (int i = 0; i < charElements.length; i++) {
      final checkIndex = targetElementIndex + i;
      if (checkIndex >= targetElements.length) {
        print('인덱스 초과: $checkIndex >= ${targetElements.length}');
        return AppColorsStyle.error;
      }
      if (charElements[i] != targetElements[checkIndex]) {
        print(
          '불일치: ${charElements[i]} != ${targetElements[checkIndex]} at $checkIndex',
        );

        // 🎯 불일치 시에도 받침 누락인지 한번 더 확인
        print('불일치 발생, 받침 누락 재검사 시작');
        if (isIncompleteCharacterMatch(
          inputChar: inputChar,
          targetElementIndex: targetElementIndex,
          targetElements: targetElements,
        )) {
          print('받침 누락으로 재판정: $inputChar');
          return AppColorsStyle.error; // ❌ 빨간색 (받침 누락)
        }

        return AppColorsStyle.error;
      }
    }

    print('완성된 글자 일치: $inputChar');
    return AppColorsStyle.textPrimary; // ✅ 검은색 (정확)
  }

  /// 한글 요소의 색상 결정 및 스킵 처리
  Map<String, dynamic> getKoreanElementColorWithSkip({
    required String inputChar,
    required int currentTargetIndex,
    required int charIndex,
    required String inputText,
    required List<String> targetElements,
    required String targetText,
  }) {
    print(
      '검증 중: $inputChar, 현재인덱스: $currentTargetIndex, 목표요소: ${currentTargetIndex < targetElements.length ? targetElements[currentTargetIndex] : "없음"}',
    );

    // 현재 요소와 목표 요소 직접 비교
    if (currentTargetIndex < targetElements.length &&
        inputChar == targetElements[currentTargetIndex]) {
      // 🎯 받침 누락 감지 (조합 중인 글자에 대해서도) - 단, 완성된 글자로 이어지는 경우만
      if (_koreanProcessor.isConsonant(inputChar) &&
          charIndex + 1 < inputText.length) {
        final nextChar = inputText[charIndex + 1];

        if (_koreanProcessor.isKoreanCharComplete(nextChar) ||
            _koreanProcessor.isConsonant(nextChar)) {
          // 다음이 완성된 한글이거나 자음이면, 현재 자음 이후에 모음이 누락되었는지 확인
          List<String> targetElementsForChar = _getTargetElementsForCurrentChar(
            elementIndex: currentTargetIndex,
            targetText: targetText,
          );

          // 현재 자음이 글자의 첫 자음이고, 해당 글자에 모음이 있어야 하는 경우
          if (targetElementsForChar.length >= 2 &&
              targetElementsForChar[0] == inputChar) {
            print('모음 누락 감지: $inputChar, 다음 글자는 스킵 처리됨');
            // 🎯 핵심: 모음이 누락된 경우, 해당 모음을 스킵하여 다음 글자가 올바른 위치에서 시작되도록 함
            return {
              'color': AppColorsStyle.error, // ❌ 빨간색 (모음 누락)
              'newIndex':
                  currentTargetIndex +
                  targetElementsForChar.length, // 전체 글자의 요소를 스킵
            };
          }
        }
      }

      return {
        'color': AppColorsStyle.textPrimary, // ✅ 검은색 (정확)
        'newIndex': currentTargetIndex + 1,
      };
    }

    // 🎯 스킵 전환 처리 - 자음이 다음 글자의 첫 자음인지 확인 (기존 로직 유지)
    if (_koreanProcessor.isConsonant(inputChar)) {
      print('자음 스킵 전환 시도: $inputChar');
      // 현재 위치부터 목표 배열에서 이 자음을 찾기
      for (
        int searchIndex = currentTargetIndex;
        searchIndex < targetElements.length;
        searchIndex++
      ) {
        if (targetElements[searchIndex] == inputChar) {
          print('자음 발견: 인덱스 $searchIndex');
          // 스킵할 요소들 확인 (단순화) - 기존 로직 유지
          bool canSkip = true; // 우선 모든 스킵 허용하여 테스트

          if (canSkip) {
            print('스킵 성공: $currentTargetIndex -> $searchIndex');
            return {
              'color': AppColorsStyle.textPrimary, // ✅ 검은색 (스킵하여 다음 글자로 인식)
              'newIndex': searchIndex + 1, // 스킵된 인덱스로 점프
            };
          }
        }
      }
    }

    // 모음인 경우도 처리 (기존 로직 유지)
    if (!_koreanProcessor.isConsonant(inputChar)) {
      print('모음 확인: $inputChar');
      if (currentTargetIndex < targetElements.length &&
          inputChar == targetElements[currentTargetIndex]) {
        return {
          'color': AppColorsStyle.textPrimary, // ✅ 검은색
          'newIndex': currentTargetIndex + 1,
        };
      }
    }

    print('매칭 실패: $inputChar');
    return {
      'color': AppColorsStyle.error, // ❌ 빨간색 (틀림)
      'newIndex': currentTargetIndex, // 인덱스 증가하지 않음
    };
  }

  /// 전환을 위한 요소 스킵 가능 여부 확인
  bool canSkipElementsForTransition({
    required int fromIndex,
    required int toIndex,
    required List<String> targetElements,
    required String targetText,
  }) {
    // fromIndex와 toIndex 사이의 요소들이 스킵 가능한지 확인
    for (int i = fromIndex; i < toIndex; i++) {
      if (i < targetElements.length) {
        String element = targetElements[i];
        // 모음과 일부 자음(받침 등)은 스킵 가능
        // 하지만 다른 글자의 첫 자음은 스킵 불가능
        if (_koreanProcessor.isConsonant(element)) {
          // 이 자음이 새로운 글자의 시작인지 확인
          if (_isStartOfNewCharacter(elementIndex: i, targetText: targetText)) {
            return false; // 다른 글자의 첫 자음은 스킵할 수 없음
          }
        }
      }
    }
    return true;
  }

  /// 해당 인덱스가 새로운 글자의 시작인지 확인
  bool _isStartOfNewCharacter({
    required int elementIndex,
    required String targetText,
  }) {
    List<String> characters = targetText.split('');
    int currentIndex = 0;

    for (String char in characters) {
      List<String> charElements = _koreanProcessor.decomposeCharacterToElements(
        char,
      );
      if (currentIndex == elementIndex) {
        return true; // 새로운 글자의 시작
      }
      currentIndex += charElements.length;
    }
    return false;
  }

  /// 현재 요소 인덱스를 기준으로 해당 글자의 모든 요소 반환
  List<String> _getTargetElementsForCurrentChar({
    required int elementIndex,
    required String targetText,
  }) {
    // 현재 요소가 속한 글자의 모든 요소를 찾기
    List<String> characters = targetText.split('');
    int currentElementIndex = 0;

    for (String char in characters) {
      List<String> charElements = _koreanProcessor.decomposeCharacterToElements(
        char,
      );

      // 현재 요소 인덱스가 이 글자 범위에 있는지 확인
      if (elementIndex >= currentElementIndex &&
          elementIndex < currentElementIndex + charElements.length) {
        return charElements;
      }

      currentElementIndex += charElements.length;
    }

    return [];
  }
}
