import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';

class ReachComparisonBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const ReachComparisonBar({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0);
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: clamped / 100,
                  minHeight: 12,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 2),
              Text(AppUtils.formatPercent(clamped),
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
