// lib/typing/module/typing_route.dart 수정
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/word_practice/word_practice_screen_root.dart';

final typingRoutes = [
  GoRoute(
    path: '/typing/word',
    name: 'wordPractice',
    builder: (context, state) {
      final language = state.uri.queryParameters['language'] ?? 'ko';
      return WordPracticeScreenRoot(language: language);
    },
  ),
  GoRoute(
    path: '/typing/paragraph',
    name: 'paragraphPractice',
    builder: (context, state) {
      return const _TemporaryScreen(title: '장문 연습', message: '장문 연습 화면 구현 예정');
    },
  ),
  GoRoute(
    path: '/typing/result',
    name: 'typingResult',
    builder: (context, state) {
      final resultId = state.uri.queryParameters['resultId'];
      return _TemporaryScreen(
        title: '연습 결과',
        message: '연습 결과 화면 구현 예정\nResult ID: $resultId',
      );
    },
  ),
];

/// 임시 화면 위젯
class _TemporaryScreen extends StatelessWidget {
  final String title;
  final String message;

  const _TemporaryScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('뒤로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}
