// lib/typing/presentation/paragraph_practice/paragraph_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tododok/typing/presentation/paragraph_practice/constants/korean_constants.dart';
import 'package:tododok/typing/presentation/paragraph_practice/services/korean_text_processor.dart';
import 'package:tododok/typing/presentation/paragraph_practice/services/typing_validation_service.dart';
import 'package:tododok/typing/presentation/paragraph_practice/widgets/practice_app_bar.dart';
import 'package:tododok/typing/presentation/paragraph_practice/widgets/practice_status_views.dart';
import 'package:tododok/typing/presentation/paragraph_practice/widgets/sentence_preview_widget.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';

import 'paragraph_practice_state.dart';
import 'paragraph_practice_action.dart';

class ParagraphPracticeScreen extends StatefulWidget {
  final ParagraphPracticeState state;
  final void Function(ParagraphPracticeAction action) onAction;

  const ParagraphPracticeScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<ParagraphPracticeScreen> createState() =>
      _ParagraphPracticeScreenState();
}

class _ParagraphPracticeScreenState extends State<ParagraphPracticeScreen> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  // ✅ 서비스 인스턴스들
  final KoreanTextProcessor _koreanProcessor = KoreanTextProcessor();
  final TypingValidationService _validationService = TypingValidationService();

  // 🎯 순차적 요소 비교를 위한 캐시 변수
  List<String> _targetElements = [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // 화면이 로드되면 자동으로 키보드 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _initializeTargetElements();
    });
  }

  @override
  void didUpdateWidget(ParagraphPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 문장이 바뀌면 목표 텍스트 재분해
    if (oldWidget.state.currentSentence?.content !=
        widget.state.currentSentence?.content) {
      _initializeTargetElements();
    }
  }

  // 🎯 목표 텍스트 전체를 순차적으로 요소 분해
  void _initializeTargetElements() {
    final sentence = widget.state.currentSentence;
    if (sentence?.content != null) {
      _targetElements = _koreanProcessor.decomposeCompleteText(
        sentence!.content,
      );
      print('목표 요소들 (현재 문장만): $_targetElements'); // 디버깅용
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.background,
      appBar: PracticeAppBar(
        onBackPressed: () =>
            widget.onAction(const ParagraphPracticeAction.navigateToHome()),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.state.availableSentences is AsyncLoading) {
      return PracticeStatusViews.loading();
    }

    if (widget.state.availableSentences is AsyncError) {
      return PracticeStatusViews.error();
    }

    // 일시정지 상태 확인 (있다면)
    if (widget.state.isPaused == true) {
      return PracticeStatusViews.paused(
        onResume: () =>
            widget.onAction(const ParagraphPracticeAction.resumePractice()),
        onRestart: () =>
            widget.onAction(const ParagraphPracticeAction.restartPractice()),
      );
    }

    // 완료 상태 확인 (있다면)
    if (widget.state.isCompleted == true) {
      return PracticeStatusViews.completed(
        onViewResult: () =>
            widget.onAction(const ParagraphPracticeAction.navigateToResult()),
        onRestart: () =>
            widget.onAction(const ParagraphPracticeAction.restartPractice()),
      );
    }

    return _buildSentencePreview();
  }

  Widget _buildSentencePreview() {
    final sentence = widget.state.currentSentence;

    // 문장이 없는 경우
    if (sentence == null) {
      return const Center(child: Text('문장을 선택해주세요'));
    }

    return GestureDetector(
      onTap: () {
        // 화면을 탭하면 키보드 포커스
        _focusNode.requestFocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Stack(
          children: [
            // 문장 미리보기 (뒤쪽)
            _buildPreviewText(sentence),

            // 입력 표시 (앞쪽에 겹침)
            _buildInputField(),

            // 숨겨진 실제 입력창
            _buildHiddenTextField(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewText(dynamic sentence) {
    return SentencePreviewWidget(sentence: sentence);
  }

  // 🎯 한글 스킵 전환을 지원하는 입력 필드
  Widget _buildInputField() {
    return SizedBox(
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: _buildSkipTransitionTextSpans(),
          style: AppTextStyle.typingText.copyWith(height: 1.8, fontSize: 20),
        ),
      ),
    );
  }

  // 🎯 핵심: 받침 누락 감지를 포함한 한글 스킵 전환 TextSpan 생성
  List<TextSpan> _buildSkipTransitionTextSpans() {
    List<TextSpan> spans = [];
    final inputText = _textController.text;

    List<String> inputElements = _koreanProcessor.decomposeCompleteText(
      inputText,
    );

    print('=== 입력 분석 시작 ===');
    print('입력 텍스트: $inputText');
    print('입력 요소들: $inputElements');
    print('목표 요소들: $_targetElements');

    int targetElementIndex = 0; // 실제 목표 인덱스

    // 입력된 각 글자를 순회
    for (int charIndex = 0; charIndex < inputText.length; charIndex++) {
      final inputChar = inputText[charIndex];
      Color textColor;

      print('\n--- 글자 $charIndex: $inputChar (인덱스: $targetElementIndex) ---');

      if (_koreanProcessor.isKoreanCharComplete(inputChar)) {
        // 🔥 완성된 한글: 받침 누락 감지 포함한 전체 글자 검증
        // ✅ 서비스 호출로 변경
        textColor = _validationService.getCompleteCharacterColor(
          inputChar: inputChar,
          targetElementIndex: targetElementIndex,
          charIndex: charIndex,
          inputText: inputText,
          targetElements: _targetElements,
          targetText: widget.state.currentSentence?.content ?? '',
        );

        // 인덱스 업데이트 로직 개선
        if (textColor == AppColorsStyle.error) {
          // 🎯 오류인 경우: 받침 누락인지 확인하여 적절히 인덱스 조정
          // ✅ 서비스 호출로 변경
          if (_validationService.hasIncompleteInput(
                inputChar: inputChar,
                targetElementIndex: targetElementIndex,
                charIndex: charIndex,
                inputText: inputText,
                targetText: widget.state.currentSentence?.content ?? '',
              ) ||
              _validationService.isIncompleteCharacterMatch(
                inputChar: inputChar,
                targetElementIndex: targetElementIndex,
                targetElements: _targetElements,
              )) {
            // 받침 누락인 경우: 예상 글자의 전체 요소 수만큼 스킵
            String? expectedChar = _koreanProcessor.findExpectedCharacterAt(
              elementIndex: targetElementIndex,
              targetText: widget.state.currentSentence?.content ?? '',
            );
            if (expectedChar != null) {
              List<String> expectedElements = _koreanProcessor
                  .decomposeCharacterToElements(expectedChar);
              targetElementIndex += expectedElements.length;
              print(
                '받침 누락으로 예상 글자 스킵: $expectedChar (${expectedElements.length}개 요소)',
              );
            } else {
              // 예상 글자를 찾을 수 없는 경우: 입력 글자의 요소 수만큼만 증가
              List<String> charElements = _koreanProcessor
                  .decomposeCharacterToElements(inputChar);
              targetElementIndex += charElements.length;
              print('예상 글자 없음, 입력 글자만큼 증가: ${charElements.length}');
            }
          } else {
            // 일반적인 오류: 입력 글자의 요소 수만큼만 증가
            List<String> charElements = _koreanProcessor
                .decomposeCharacterToElements(inputChar);
            targetElementIndex += charElements.length;
            print('일반 오류, 입력 글자만큼 증가: ${charElements.length}');
          }
        } else {
          // 정상적인 경우: 입력 글자의 요소 수만큼 증가
          List<String> charElements = _koreanProcessor
              .decomposeCharacterToElements(inputChar);
          targetElementIndex += charElements.length;
          print('정상 입력, 요소 수만큼 증가: ${charElements.length}');
        }

        print('완성된 글자 처리 완료: $inputChar → 새로운 인덱스: $targetElementIndex');
      } else if (_koreanProcessor.isKoreanChar(inputChar)) {
        // 🟡 조합 중인 한글: 받침 누락을 포함한 스마트 스킵 검증
        // ✅ 서비스 호출로 변경
        var result = _validationService.getKoreanElementColorWithSkip(
          inputChar: inputChar,
          currentTargetIndex: targetElementIndex,
          charIndex: charIndex,
          inputText: inputText,
          targetElements: _targetElements,
          targetText: widget.state.currentSentence?.content ?? '',
        );
        textColor = result['color'];
        targetElementIndex = result['newIndex'];

        print('한글 요소 처리: $inputChar → 새로운 인덱스: $targetElementIndex');
      } else {
        // 🔤 영어, 숫자, 특수문자: 순차적 목표와 즉시 비교
        final isCorrect =
            targetElementIndex < _targetElements.length &&
            inputChar == _targetElements[targetElementIndex];

        textColor = isCorrect
            ? AppColorsStyle.textPrimary
            : AppColorsStyle.error;

        if (isCorrect) targetElementIndex++;
        print('비한글 처리: $inputChar → 정확: $isCorrect → 인덱스: $targetElementIndex');
      }

      spans.add(
        TextSpan(
          text: inputChar,
          style: TextStyle(
            color: textColor,
            backgroundColor: AppColorsStyle.background,
            fontSize: 20,
            height: 1.8,
            fontFamily: AppTextStyle.typingText.fontFamily,
            fontWeight: AppTextStyle.typingText.fontWeight,
          ),
        ),
      );
    }

    print('=== 입력 분석 완료 ===\n');
    return spans;
  }

  Widget _buildHiddenTextField() {
    return Positioned(
      left: -9999, // 화면 밖으로 숨김
      child: SizedBox(
        width: 1,
        height: 1,
        child: TextField(
          focusNode: _focusNode,
          controller: _textController,
          style: const TextStyle(color: Colors.transparent),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          showCursor: false, // 커서 숨김 (RichText에서 표시)
          onChanged: (value) {
            setState(() {
              // 입력 변경 시 화면 갱신 - 한글 스킵 전환 처리됨
            });
          },
        ),
      ),
    );
  }
}
