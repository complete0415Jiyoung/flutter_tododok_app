// lib/typing/presentation/sentence_selection/sentence_selection_action.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/sentence.dart';

part 'sentence_selection_action.freezed.dart';

@freezed
sealed class SentenceSelectionAction with _$SentenceSelectionAction {
  /// 초기화
  const factory SentenceSelectionAction.initialize(
    String mode,
    String language,
  ) = Initialize;

  /// 문장 목록 로드
  const factory SentenceSelectionAction.loadSentences(
    String mode,
    String language,
  ) = LoadSentences;

  /// 문장 선택
  const factory SentenceSelectionAction.selectSentence(Sentence sentence) =
      SelectSentence;

  /// 랜덤 문장 가져오기
  const factory SentenceSelectionAction.getRandomSentence(
    String mode,
    String language,
  ) = GetRandomSentence;

  /// 언어 변경
  const factory SentenceSelectionAction.changeLanguage(String language) =
      ChangeLanguage;
}
