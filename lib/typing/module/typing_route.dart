// lib/typing/module/typing_route.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/word_practice/word_practice_screen_root.dart';
import '../presentation/paragraph_practice/paragraph_practice_screen_root.dart';
import '../presentation/sentence_selection/sentence_selection_screen_root.dart';
import '../presentation/result/typing_result_screen.dart';

final typingRoutes = [
  // 단어 연습
  GoRoute(
    path: '/typing/word',
    name: 'wordPractice',
    builder: (context, state) {
      final language = state.uri.queryParameters['language'] ?? 'ko';
      final sentenceId = state.uri.queryParameters['sentenceId'];
      final random = state.uri.queryParameters['random'] == 'true';

      return WordPracticeScreenRoot(
        language: language,
        sentenceId: sentenceId,
        random: random,
      );
    },
  ),

  // 장문 연습
  GoRoute(
    path: '/typing/paragraph',
    name: 'paragraphPractice',
    builder: (context, state) {
      final language = state.uri.queryParameters['language'] ?? 'ko';
      final sentenceId = state.uri.queryParameters['sentenceId'];
      final random = state.uri.queryParameters['random'] == 'true';

      return ParagraphPracticeScreenRoot(
        language: language,
        sentenceId: sentenceId,
        random: random,
      );
    },
  ),

  // 문장 선택 화면
  GoRoute(
    path: '/typing/sentence-selection',
    name: 'sentenceSelection',
    builder: (context, state) {
      final mode = state.uri.queryParameters['mode'] ?? 'paragraph';
      final language = state.uri.queryParameters['language'] ?? 'ko';

      return SentenceSelectionScreenRoot(mode: mode, language: language);
    },
  ),

  // 연습 결과 화면
  GoRoute(
    path: '/typing/result',
    name: 'typingResult',
    builder: (context, state) {
      final params = state.uri.queryParameters;
      return TypingResultScreen(params: params);
    },
  ),
];
