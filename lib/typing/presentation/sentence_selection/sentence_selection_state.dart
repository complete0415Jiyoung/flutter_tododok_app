// lib/typing/presentation/sentence_selection/sentence_selection_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/sentence.dart';

part 'sentence_selection_state.freezed.dart';

@freezed
class SentenceSelectionState with _$SentenceSelectionState {
  const SentenceSelectionState({
    this.sentences = const AsyncLoading(),
    this.selectedSentence,
    this.mode = 'paragraph',
    this.language = 'ko',
    this.isLoading = false,
    this.errorMessage,
  });

  /// 문장 목록
  @override
  final AsyncValue<List<Sentence>> sentences;

  /// 선택된 문장
  @override
  final Sentence? selectedSentence;

  /// 연습 모드 ('word' 또는 'paragraph')
  @override
  final String mode;

  /// 언어 ('ko' 또는 'en')
  @override
  final String language;

  /// 로딩 상태
  @override
  final bool isLoading;

  /// 에러 메시지
  @override
  final String? errorMessage;

  /// 문장이 있는지 확인
  bool get hasSentences => sentences.value?.isNotEmpty ?? false;

  /// 선택된 문장이 있는지 확인
  bool get hasSelectedSentence => selectedSentence != null;
}
