// lib/typing/presentation/paragraph_practice/widgets/real_time_stats_widget.dart
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors_style.dart';
import '../../../../shared/styles/app_text_style.dart';

class RealTimeStatsWidget extends StatelessWidget {
  final int wpm;
  final double accuracy;
  final int elapsedSeconds;
  final int totalTypos;

  const RealTimeStatsWidget({
    super.key,
    required this.wpm,
    required this.accuracy,
    required this.elapsedSeconds,
    required this.totalTypos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            '속도',
            '$wpm',
            '타/분',
            Icons.speed,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            '정확도',
            accuracy.toStringAsFixed(1),
            '%',
            Icons.track_changes,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            '시간',
            '$elapsedSeconds',
            '초',
            Icons.timer,
            const Color(0xFFFF9800),
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            '오타',
            '$totalTypos',
            '개',
            Icons.warning,
            const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                unit,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
