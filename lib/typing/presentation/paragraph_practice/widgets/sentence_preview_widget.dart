// lib/typing/presentation/paragraph_practice/widgets/sentence_preview_widget.dart
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors_style.dart';
import '../../../../shared/styles/app_text_style.dart';

class SentencePreviewWidget extends StatelessWidget {
  final dynamic sentence; // Sentence 모델 타입에 맞게 수정

  const SentencePreviewWidget({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    final targetText = sentence.content ?? '문장 내용이 없습니다';

    return SizedBox(
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          children: _buildPreviewTextSpans(targetText),
          style: AppTextStyle.typingText.copyWith(height: 1.8, fontSize: 20),
        ),
      ),
    );
  }

  List<TextSpan> _buildPreviewTextSpans(String targetText) {
    List<TextSpan> spans = [];

    for (int i = 0; i < targetText.length; i++) {
      final char = targetText[i];

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            color: AppColorsStyle.gray300,
            backgroundColor: AppColorsStyle.background,
            fontSize: 20,
            height: 1.8,
            fontFamily: AppTextStyle.typingText.fontFamily,
            fontWeight: AppTextStyle.typingText.fontWeight,
            letterSpacing: AppTextStyle.typingText.letterSpacing,
          ),
        ),
      );
    }

    return spans;
  }
}
