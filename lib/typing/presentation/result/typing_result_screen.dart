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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    // 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });

    // 햅틱 피드백
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildMainResult(),
                const SizedBox(height: 32),
                _buildStats(),
                const SizedBox(height: 32),
                _buildAnalysis(),
                const SizedBox(height: 40),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColorsStyle.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColorsStyle.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getModeText(),
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColorsStyle.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainResult() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColorsStyle.shadow.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _getCelebrationText(),
                style: AppTextStyle.heading2.copyWith(
                  color: _getPerformanceColor(),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getPerformanceMessage(),
                style: AppTextStyle.bodyLarge.copyWith(
                  color: AppColorsStyle.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildMainStat('WPM', _getWpm())),
                  Container(
                    width: 1,
                    height: 60,
                    color: AppColorsStyle.border,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  Expanded(child: _buildMainStat('정확도(%)', _getAccuracy())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.heading1.copyWith(
            color: _getPerformanceColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyle.labelLarge.copyWith(
            color: AppColorsStyle.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsStyle.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColorsStyle.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 정보',
              style: AppTextStyle.heading5.copyWith(
                color: AppColorsStyle.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('소요 시간', _getFormattedDuration()),
                ),
                Expanded(child: _buildStatItem('언어', _getLanguageText())),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '단어 수',
                    widget.params['sentenceLength'] ?? '0',
                  ),
                ),
                Expanded(
                  child: _buildStatItem('오타 수', widget.params['typos'] ?? '0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColorsStyle.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColorsStyle.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysis() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getPerformanceColor().withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getPerformanceColor().withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '분석',
              style: AppTextStyle.heading5.copyWith(
                color: _getPerformanceColor(),
              ),
            ),
            const SizedBox(height: 12),
            _buildPerformanceBar(),
            const SizedBox(height: 16),
            Text(
              _getDetailedAnalysis(),
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColorsStyle.textSecondary,
                height: 1.5,
              ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '종합 점수',
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColorsStyle.textSecondary,
              ),
            ),
            Text(
              '${(normalizedScore * 100).toInt()}점',
              style: AppTextStyle.labelMedium.copyWith(
                color: _getPerformanceColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColorsStyle.containerBackground,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: normalizedScore,
            child: Container(
              decoration: BoxDecoration(
                color: _getPerformanceColor(),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
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
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  '다시 연습',
                  true,
                  () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  '홈으로',
                  false,
                  () => Navigator.of(context).pushReplacementNamed('/home'),
                ),
              ),
            ],
          ),
          if (widget.params['type'] == 'practice') ...[
            const SizedBox(height: 16),
            _buildChallengeButton(),
          ],
          const SizedBox(height: 12),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    bool isPrimary,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isPrimary ? AppColorsStyle.primary : AppColorsStyle.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(color: AppColorsStyle.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColorsStyle.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: AppTextStyle.buttonMedium.copyWith(
                color: isPrimary
                    ? AppColorsStyle.white
                    : AppColorsStyle.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColorsStyle.warning.withOpacity(0.3),
          width: 1,
        ),
        color: AppColorsStyle.warning.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCreateChallengeDialog,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              '친구에게 도전장 보내기',
              style: AppTextStyle.buttonMedium.copyWith(
                color: AppColorsStyle.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _shareResult,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          '결과 공유하기',
          style: AppTextStyle.labelLarge.copyWith(
            color: AppColorsStyle.textSecondary,
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _getModeText() {
    final mode = widget.params['mode'] ?? 'word';
    return mode == 'word' ? '단어 연습' : '장문 연습';
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
    if (accuracy >= 95) return const Color(0xFF10B981); // 초록
    if (accuracy >= 85) return AppColorsStyle.primary; // 파랑
    if (accuracy >= 75) return const Color(0xFFF59E0B); // 주황
    return const Color(0xFFEF4444); // 빨강
  }

  String _getCelebrationText() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    if (accuracy >= 95) return '완벽합니다!';
    if (accuracy >= 85) return '훌륭해요!';
    if (accuracy >= 75) return '잘했어요!';
    return '연습 완료!';
  }

  String _getPerformanceMessage() {
    final accuracy = double.tryParse(widget.params['accuracy'] ?? '0') ?? 0;
    final wpm = double.tryParse(widget.params['wpm'] ?? '0') ?? 0;

    if (accuracy >= 95 && wpm >= 60) {
      return '정확도와 속도 모두 뛰어난 실력입니다';
    } else if (accuracy >= 95) {
      return '정확도가 정말 훌륭해요';
    } else if (wpm >= 60) {
      return '타자 속도가 매우 빨라요';
    } else if (accuracy >= 85) {
      return '좋은 정확도를 보여주고 있어요';
    }
    return '꾸준한 연습으로 더 나아질 수 있어요';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('도전장 생성'),
        content: const Text(
          '이 연습 결과를 바탕으로 친구에게 도전장을 보내시겠습니까?\n'
          '친구는 같은 문장으로 연습한 후 결과를 비교할 수 있습니다.',
          style: TextStyle(height: 1.5),
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
                borderRadius: BorderRadius.circular(8),
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
        '''🎯 토도독 $mode 연습 결과

📊 WPM: ${_getWpm()}
🎯 정확도: ${_getAccuracy()}%
⏱️ 시간: ${_getFormattedDuration()}
🌐 언어: ${_getLanguageText()}

${_getCelebrationText()}''';

    // TODO: 실제 공유 기능 구현
    print('공유할 텍스트: $shareText');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('결과가 클립보드에 복사되었습니다!'),
        backgroundColor: AppColorsStyle.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
