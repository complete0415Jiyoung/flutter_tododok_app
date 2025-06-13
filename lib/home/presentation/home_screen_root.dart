// lib/home/presentation/home_screen_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_notifier.dart';
import 'home_screen.dart';
import 'home_action.dart';

class HomeScreenRoot extends ConsumerStatefulWidget {
  const HomeScreenRoot({super.key});

  @override
  ConsumerState<HomeScreenRoot> createState() => _HomeScreenRootState();
}

class _HomeScreenRootState extends ConsumerState<HomeScreenRoot> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성된 후 초기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(homeNotifierProvider.notifier)
          .onAction(const HomeAction.initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.watch(homeNotifierProvider.notifier);

    return HomeScreen(
      state: state,
      onAction: (action) async {
        switch (action) {
          case StartWordPractice():
            // 단어 연습 화면으로 바로 이동 (랜덤 문장 사용)
            await context.push('/typing/word?language=ko&random=true');

          case StartParagraphPractice():
            // 장문 연습 문장 선택 화면으로 이동
            await context.push(
              '/typing/sentence-selection?mode=paragraph&language=ko',
            );

          case EnterFriendChallenge():
            // TODO: 친구 대결 화면으로 이동
            await context.push('/challenge');

          case ViewRecords():
            // TODO: 기록 보기 화면으로 이동
            await context.push('/records');

          case ViewNotifications():
            // TODO: 알림함 화면으로 이동
            await context.push('/notifications');

          case OpenSettings():
            // TODO: 설정 화면으로 이동
            await context.push('/settings');

          case Initialize():
            // 상태 관리는 notifier에게 위임
            await notifier.onAction(action);
        }
      },
    );
  }
}
