// lib/typing/presentation/word_practice/widgets/real_time_stats_widget.dart

import 'package:flutter/material.dart';
import '../word_practice_state.dart';

class RealTimeStatsWidget extends StatelessWidget {
  final WordPracticeState state;
  final bool isCountingDown; // 카운트다운 상태 전달

  const RealTimeStatsWidget({
    super.key,
    required this.state,
    this.isCountingDown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: Icons.timer_outlined,
            label: '시간',
            value: _formatElapsedTime(_getDisplayTime()),
            color: Colors.blue,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            icon: Icons.speed_outlined,
            label: state.language == 'ko' ? '타/분' : 'WPM',
            value: _getDisplayTypingSpeed().toStringAsFixed(0),
            color: Colors.green,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            icon: Icons.check_circle_outline,
            label: '정확도',
            value: '${_getDisplayAccuracy().toStringAsFixed(0)}%',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // 카운트다운 중에는 0초, 게임 중에는 실제 시간 표시
  int _getDisplayTime() {
    if (isCountingDown || !state.isGameRunning) {
      return 0;
    }
    return state.elapsedSeconds.toInt();
  }

  // 카운트다운 중에는 0 타수, 게임 중에는 실제 타수 표시
  double _getDisplayTypingSpeed() {
    if (isCountingDown || !state.isGameRunning) {
      return 0.0;
    }
    return state.typingSpeed;
  }

  // 카운트다운 중에는 0% 정확도, 게임 중에는 실제 정확도 표시
  double _getDisplayAccuracy() {
    if (isCountingDown || !state.isGameRunning) {
      return 0.0;
    }
    return state.accuracy;
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
    );
  }

  String _formatElapsedTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
