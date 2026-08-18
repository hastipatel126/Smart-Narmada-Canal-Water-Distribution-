import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';

/// Visual gauge-style widget for the fairness score
class FairnessGauge extends StatelessWidget {
  final double score;
  const FairnessGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.fairnessColor(score);
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
