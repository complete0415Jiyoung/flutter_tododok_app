// lib/typing/presentation/result/typing_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';

class TypingResultScreen extends StatefulWidget {
  final Map<String, String> params;

  const TypingResultScreen({super.key, required this.params});

  @override
  State<TypingResultScreen> createState() => _TypingResultScreenState();
}

class _TypingResultScreenState extends State<TypingResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _statsController;
  late AnimationController _fadeController;

  late Animation<double> _celebrationAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    // 순차적 애니메이션 실행
    _startAnimations();

    // 햅틱 피드백
    HapticFeedback.lightImpact();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _celebrationController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _statsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPerformanceColor().withOpacity(0.1),
              AppColorsStyle.surface,
              _getPerformanceColor().withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildCelebrationSection(),
                  const SizedBox(height: 32),
                  _buildMainStats(),
                  const SizedBox(height: 24),
                  _buildDetailedStats(),
                  const SizedBox(height: 24),
                  _buildPerformanceAnalysis(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColorsStyle.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColorsStyle.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColorsStyle.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorsStyle.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColorsStyle.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(_getModeText(), style: AppTextStyle.labelLarge.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationSection() {
    return ScaleTransition(
      scale: _celebrationAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsStyle.white,
              AppColorsStyle.white.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _getPerformanceColor().withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColorsStyle.white.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPerformanceColor(),
                    _getPerformanceColor().withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getPerformanceColor().withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _getPerformanceIcon(),
                size: 48,
                color: AppColorsStyle.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getCelebrationText(),
              style: AppTextStyle.heading2.copyWith(
                color: _getPerformanceColor(),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceMessage(),
              style: AppTextStyle.bodyLarge.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return ScaleTransition(
      scale: _statsAnimation,
      child: Row(
        children: [
          Expanded(
            child: _buildMainStatCard(
              'WPM',
              _getWpm(),
              Icons.speed_rounded,
              const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMainStatCard(
              '정확도',
              '${_getAccuracy()}%',
              Icons.check_circle_rounded,
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorsStyle.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyle.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyle.labelLarge.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColorsStyle.shadow.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('상세 통계', style: AppTextStyle.heading4),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStatItem(
                      Icons.timer_rounded,
                      '소요 시간',
                      _getFormattedDuration(),
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailStatItem(
                      Icons.language_rounded,
                      '언어',
                      _getLanguageText(),
                      const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStatItem(
                      Icons.text_fields_rounded,
                      '글자 수',
                      widget.params['sentenceLength'] ?? '0',
                      const Color(0xFF607D8B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailStatItem(
                      Icons.error_outline_rounded,
                      '오타 수',
                      widget.params['typos'] ?? '0',
                      const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyle.numberMedium.copyWith(color: color)),
          Text(
            label,
            style: AppTextStyle.labelSmall.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalysis() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPerformanceColor().withOpacity(0.05),
              _getPerformanceColor().withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getPerformanceColor().withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: _getPerformanceColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '성능 분석',
                  style: AppTextStyle.heading4.copyWith(
                    color: _getPerformanceColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPerformanceBar(),
            const SizedBox(height: 16),
            Text(
              _getDetailedAnalysis(),
              style: AppTextStyle.bodyMedium.textSecondary,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    final normalizedScore = (accuracy / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('종합 점수', style: AppTextStyle.labelMedium.textSecondary),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColorsStyle.containerBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalizedScore,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPerformanceColor(),
                    _getPerformanceColor().withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(normalizedScore * 100).toInt()}점',
          style: AppTextStyle.numberMedium.copyWith(
            color: _getPerformanceColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // 주요 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  '다시 연습',
                  Icons.refresh_rounded,
                  AppColorsStyle.primary,
                  () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  '홈으로',
                  Icons.home_rounded,
                  AppColorsStyle.secondary,
                  () => Navigator.of(context).pushReplacementNamed('/home'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 도전장 생성 버튼 (연습 모드일 때만)
          if (widget.params['type'] == 'practice') _buildChallengeButton(),

          const SizedBox(height: 12),

          // 결과 공유 버튼
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColorsStyle.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTextStyle.buttonMedium.withColor(
                    AppColorsStyle.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorsStyle.warning.withOpacity(0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            AppColorsStyle.warning.withOpacity(0.1),
            AppColorsStyle.warning.withOpacity(0.05),
          ],
        ),
      ),
      child: InkWell(
        onTap: _showCreateChallengeDialog,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColorsStyle.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColorsStyle.warning,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '이 결과로 친구에게 도전장 보내기',
                style: AppTextStyle.buttonMedium.copyWith(
                  color: AppColorsStyle.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _shareResult,
        icon: const Icon(
          Icons.share_rounded,
          color: AppColorsStyle.textSecondary,
          size: 18,
        ),
        label: Text('결과 공유하기', style: AppTextStyle.labelLarge.textSecondary),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Helper methods
  String _getModeText() {
    final mode = widget.params['mode'] ?? 'word';
    return mode == 'word' ? '단어 연습 결과' : '장문 연습 결과';
  }

  String _getWpm() {
    final wpm = double.tryParse(widget.params['wpm'] ?? '0') ?? 0;
    return wpm.toStringAsFixed(1);
  }

  String _getAccuracy() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    return accuracy.toStringAsFixed(1);
  }

  String _getFormattedDuration() {
    final duration = double.tryParse(widget.params['duration'] ?? '0') ?? 0;
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    if (minutes > 0) {
      return '$minutes분 $seconds초';
    }
    return '$seconds초';
  }

  String _getLanguageText() {
    final language = widget.params['language'] ?? 'ko';
    return language == 'ko' ? '한글' : 'English';
  }

  Color _getPerformanceColor() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    if (accuracy >= 95) return const Color(0xFF4CAF50); // Green
    if (accuracy >= 85) return const Color(0xFF2196F3); // Blue
    if (accuracy >= 75) return const Color(0xFFFF9800); // Orange
    if (accuracy >= 65) return const Color(0xFFF44336); // Red
    return AppColorsStyle.textTertiary;
  }

  IconData _getPerformanceIcon() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    if (accuracy >= 95) return Icons.emoji_events_rounded;
    if (accuracy >= 85) return Icons.star_rounded;
    if (accuracy >= 75) return Icons.thumb_up_rounded;
    return Icons.trending_up_rounded;
  }

  String _getCelebrationText() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    if (accuracy >= 95) return '완벽해요! 🎉';
    if (accuracy >= 85) return '훌륭해요! ⭐';
    if (accuracy >= 75) return '잘했어요! 👍';
    return '연습 완료! 💪';
  }

  String _getPerformanceMessage() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    final wpm = double.tryParse(widget.params['wpm'] ?? '0') ?? 0;

    if (accuracy >= 95 && wpm >= 60) {
      return '정확도와 속도 모두 뛰어난 실력입니다!';
    } else if (accuracy >= 95) {
      return '정확도가 정말 훌륭해요!';
    } else if (wpm >= 60) {
      return '타자 속도가 매우 빨라요!';
    } else if (accuracy >= 85) {
      return '좋은 정확도를 보여주고 있어요!';
    }
    return '꾸준한 연습으로 더 나아질 수 있어요!';
  }

  String _getDetailedAnalysis() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    final wpm = double.tryParse(widget.params['wpm'] ?? '0') ?? 0;
    final typos = int.tryParse(widget.params['typos'] ?? '0') ?? 0;

    List<String> insights = [];

    if (accuracy >= 95) {
      insights.add('정확도가 매우 우수합니다.');
    } else if (accuracy >= 85) {
      insights.add('정확도가 좋은 편입니다.');
    } else {
      insights.add('정확도 향상을 위해 천천히 정확하게 타이핑해보세요.');
    }

    if (wpm >= 60) {
      insights.add('타자 속도가 빠른 편입니다.');
    } else if (wpm >= 40) {
      insights.add('타자 속도가 평균적입니다.');
    } else {
      insights.add('타자 속도 향상을 위해 더 많은 연습이 필요합니다.');
    }

    if (typos == 0) {
      insights.add('오타 없이 완벽하게 입력했습니다!');
    } else if (typos <= 2) {
      insights.add('오타가 적어 좋습니다.');
    } else {
      insights.add('오타를 줄이기 위해 조금 더 신중하게 입력해보세요.');
    }

    return insights.join(' ');
  }

  void _showCreateChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorsStyle.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColorsStyle.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('도전장 생성'),
          ],
        ),
        content: const Text(
          '이 연습 결과를 바탕으로 친구에게 도전장을 보내시겠습니까?\n'
          '친구는 같은 문장으로 연습한 후 결과를 비교할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 실제 도전장 생성 화면으로 이동
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsStyle.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('도전장 만들기'),
          ),
        ],
      ),
    );
  }

  void _shareResult() {
    final mode = widget.params['mode'] == 'word' ? '단어' : '장문';
    final shareText =
        '''
🎯 토도독 $mode 연습 결과

📊 WPM: ${_getWpm()}
🎯 정확도: ${_getAccuracy()}%
⏱️ 시간: ${_getFormattedDuration()}
🌐 언어: ${_getLanguageText()}

${_getCelebrationText()}
    ''';

    // TODO: 실제 공유 기능 구현
    print('공유할 텍스트: $shareText');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('결과가 클립보드에 복사되었습니다!'),
        backgroundColor: AppColorsStyle.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
