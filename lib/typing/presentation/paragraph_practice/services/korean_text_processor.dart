// lib/typing/presentation/paragraph_practice/services/korean_text_processor.dart
import '../constants/korean_constants.dart';

/// 한글 텍스트 처리 전담 클래스
class KoreanTextProcessor {
  /// 전체 텍스트를 순차적 요소 배열로 분해
  /// 예: "안녕" → ["ㅇ", "ㅏ", "ㄴ", "ㄴ", "ㅕ", "ㅇ"]
  List<String> decomposeCompleteText(String text) {
    List<String> elements = [];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      elements.addAll(decomposeCharacterToElements(char));
    }

    return elements;
  }

  /// 한 글자를 자음/모음/받침으로 분해
  /// 완성된 한글: "안" → ["ㅇ", "ㅏ", "ㄴ"]
  /// 조합 중인 한글: "ㅇ" → ["ㅇ"]
  /// 비한글: "A" → ["A"]
  List<String> decomposeCharacterToElements(String char) {
    if (isKoreanCharComplete(char)) {
      // 완성된 한글 → 자음/모음/받침으로 분해
      return decomposeKorean(char);
    } else if (isKoreanChar(char)) {
      // 조합 중인 한글 (ㅇ, ㄱ, ㅏ 등) → 단일 요소
      return [char];
    } else {
      // 영어, 숫자, 특수문자 → 단일 요소
      return [char];
    }
  }

  /// 완성된 한글 글자를 초성/중성/종성으로 분해
  /// "안" → ["ㅇ", "ㅏ", "ㄴ"]
  /// "가" → ["ㄱ", "ㅏ"] (받침 없음)
  List<String> decomposeKorean(String char) {
    if (!isKoreanCharComplete(char)) return [char];

    final code = char.codeUnitAt(0) - KoreanConstants.koreanCompleteStart;
    final initial = code ~/ 588; // 초성
    final medial = (code % 588) ~/ 28; // 중성
    final finalConsonant = code % 28; // 받침

    List<String> result = [];
    result.add(KoreanConstants.initials[initial]); // 초성
    result.add(KoreanConstants.medials[medial]); // 중성

    if (finalConsonant > 0) {
      result.add(KoreanConstants.finals[finalConsonant]); // 받침 (있는 경우만)
    }

    return result;
  }

  /// 완성된 한글 글자인지 확인 (가-힣 범위)
  bool isKoreanCharComplete(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= KoreanConstants.koreanCompleteStart &&
        code <= KoreanConstants.koreanCompleteEnd;
  }

  /// 한글 글자인지 확인 (조합 중 포함)
  /// 완성된 한글 + 조합용 자음/모음 모두 포함
  bool isKoreanChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= KoreanConstants.koreanJamoStart &&
            code <= KoreanConstants.koreanJamoEnd) || // 자음
        (code >= KoreanConstants.koreanCompatStart &&
            code <= KoreanConstants.koreanCompatEnd) || // 호환 자모
        (code >= KoreanConstants.koreanCompleteStart &&
            code <= KoreanConstants.koreanCompleteEnd); // 완성된 글자
  }

  /// 자음인지 확인
  bool isConsonant(String char) {
    if (char.isEmpty) return false;
    return KoreanConstants.consonants.contains(char);
  }

  /// 특정 요소 인덱스에서 예상되는 완전한 글자 찾기
  /// 받침 누락 감지에 사용
  String? findExpectedCharacterAt({
    required int elementIndex,
    required String targetText,
  }) {
    List<String> characters = targetText.split('');
    int currentIndex = 0;

    for (String char in characters) {
      List<String> charElements = decomposeCharacterToElements(char);

      // 요소 인덱스가 이 글자 범위에 있는지 확인
      if (elementIndex >= currentIndex &&
          elementIndex < currentIndex + charElements.length) {
        return char; // 해당 글자 반환
      }

      currentIndex += charElements.length;
    }

    return null; // 해당 인덱스에 글자가 없음
  }

  /// 현재 요소 인덱스를 기준으로 해당 글자의 모든 요소 반환
  List<String> getTargetElementsForCurrentChar({
    required int elementIndex,
    required String targetText,
  }) {
    List<String> characters = targetText.split('');
    int currentElementIndex = 0;

    for (String char in characters) {
      List<String> charElements = decomposeCharacterToElements(char);

      // 현재 요소 인덱스가 이 글자 범위에 있는지 확인
      if (elementIndex >= currentElementIndex &&
          elementIndex < currentElementIndex + charElements.length) {
        return charElements;
      }

      currentElementIndex += charElements.length;
    }

    return [];
  }

  /// 해당 인덱스가 새로운 글자의 시작인지 확인
  bool isStartOfNewCharacter({
    required int elementIndex,
    required String targetText,
  }) {
    List<String> characters = targetText.split('');
    int currentIndex = 0;

    for (String char in characters) {
      if (currentIndex == elementIndex) {
        return true; // 새로운 글자의 시작
      }
      List<String> charElements = decomposeCharacterToElements(char);
      currentIndex += charElements.length;
    }

    return false;
  }
}
