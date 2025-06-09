// lib/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../shared/styles/app_colors_style.dart';
import '../../shared/styles/app_text_style.dart';
import '../../shared/styles/app_dimensions.dart';
import 'home_state.dart';
import 'home_action.dart';

class HomeScreen extends StatelessWidget {
  final HomeState state;
  final void Function(HomeAction action) onAction;

  const HomeScreen({super.key, required this.state, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('토도독'),
      actions: [_buildNotificationIcon(), _buildSettingsIcon()],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => onAction(const HomeAction.viewNotifications()),
        ),
        if (state.unreadNotificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColorsStyle.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${state.unreadNotificationCount}',
                style: AppTextStyle.caption.withColor(AppColorsStyle.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsIcon() {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => onAction(const HomeAction.openSettings()),
    );
  }

  Widget _buildBody() {
    if (!state.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => onAction(const HomeAction.initialize()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildStatsSection(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildMenuSection(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildRecentResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColorsStyle.primary, AppColorsStyle.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요! 👋',
            style: AppTextStyle.heading3.withColor(AppColorsStyle.white),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            '오늘도 타자 연습을 시작해볼까요?',
            style: AppTextStyle.bodyLarge.withColor(AppColorsStyle.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final memberStats = state.memberStats;

    if (memberStats is AsyncLoading) {
      return _buildStatsLoading();
    } else if (memberStats is AsyncError) {
      return _buildStatsError();
    } else if (memberStats is AsyncData) {
      return _buildStatsContent(memberStats.value!);
    }

    return _buildStatsLoading(); // fallback
  }

  Widget _buildStatsLoading() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatsError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: const Column(
        children: [
          Icon(Icons.error_outline, color: AppColorsStyle.error),
          SizedBox(height: AppDimensions.spacing8),
          Text('통계를 불러올 수 없습니다'),
        ],
      ),
    );
  }

  Widget _buildStatsContent(member) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: const [
          BoxShadow(
            color: AppColorsStyle.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('나의 타자 통계', style: AppTextStyle.heading4),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '평균 속도',
                  '${member.averageWpm.toStringAsFixed(1)} WPM',
                  Icons.speed,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '평균 정확도',
                  '${member.averageAccuracy.toStringAsFixed(1)}%',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '연습 횟수',
                  '${member.totalPracticeCount}회',
                  Icons.edit,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '승률',
                  '${member.winRate.toStringAsFixed(1)}%',
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColorsStyle.primary, size: AppDimensions.iconLG),
        const SizedBox(height: AppDimensions.spacing4),
        Text(value, style: AppTextStyle.numberMedium),
        Text(label, style: AppTextStyle.labelMedium.textSecondary),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('메뉴', style: AppTextStyle.heading4),
        const SizedBox(height: AppDimensions.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                '단어 연습',
                '떨어지는 단어를\n빠르게 입력해보세요',
                Icons.keyboard,
                AppColorsStyle.primary,
                () => onAction(const HomeAction.startWordPractice()),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: _buildMenuCard(
                '장문 연습',
                '긴 문장으로\n타자 실력을 향상시켜보세요',
                Icons.article,
                AppColorsStyle.secondary,
                () => onAction(const HomeAction.startParagraphPractice()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildMenuCard(
                '친구 대결',
                '친구와 함께\n타자 실력을 겨뤄보세요',
                Icons.group,
                AppColorsStyle.challengeWin,
                () => onAction(const HomeAction.enterFriendChallenge()),
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: _buildMenuCard(
                '기록 보기',
                '나의 타자 기록을\n확인해보세요',
                Icons.analytics,
                AppColorsStyle.info,
                () => onAction(const HomeAction.viewRecords()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColorsStyle.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: AppColorsStyle.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppDimensions.iconLG),
            const SizedBox(height: AppDimensions.spacing8),
            Text(title, style: AppTextStyle.labelLarge),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              description,
              style: AppTextStyle.bodySmall.textTertiary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('최근 연습 기록', style: AppTextStyle.heading4),
        const SizedBox(height: AppDimensions.spacing16),
        switch (state.recentResults) {
          AsyncLoading() => _buildRecentResultsLoading(),
          AsyncError() => _buildRecentResultsError(),
          AsyncData(:final value) => _buildRecentResultsList(value),
          _ => _buildRecentResultsLoading(),
        },
      ],
    );
  }

  Widget _buildRecentResultsLoading() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildRecentResultsError() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: const Text('최근 기록을 불러올 수 없습니다'),
    );
  }

  Widget _buildRecentResultsList(List<String> results) {
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColorsStyle.containerBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        child: const Text('아직 연습 기록이 없습니다'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColorsStyle.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: const [
          BoxShadow(
            color: AppColorsStyle.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: results.take(3).map((result) {
          return ListTile(
            leading: const Icon(Icons.history, color: AppColorsStyle.primary),
            title: Text(result, style: AppTextStyle.bodyMedium),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColorsStyle.textTertiary,
            ),
            onTap: () => onAction(const HomeAction.viewRecords()),
          );
        }).toList(),
      ),
    );
  }
}
