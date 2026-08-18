import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class AppUtils {
  static Color severityColor(String severity) {
    switch (severity) {
      case AppConstants.critical:
        return AppTheme.danger;
      case AppConstants.high:
        return AppTheme.warning;
      case AppConstants.medium:
        return const Color(0xFFF9A825);
      case AppConstants.low:
        return AppTheme.successColor;
      default:
        return AppTheme.textMuted;
    }
  }

  static Color reachColor(String reachType) {
    switch (reachType) {
      case AppConstants.headReach:
        return AppTheme.headReachColor;
      case AppConstants.midReach:
        return AppTheme.midReachColor;
      case AppConstants.tailEnd:
        return AppTheme.tailEndColor;
      default:
        return AppTheme.textMuted;
    }
  }

  static Color fairnessColor(double score) {
    if (score >= AppConstants.goodFairnessThreshold) return AppTheme.successColor;
    if (score >= AppConstants.warningFairnessThreshold) return AppTheme.warning;
    return AppTheme.danger;
  }

  static String formatFlow(double flow) => '${flow.toStringAsFixed(1)} m³/s';
  static String formatVolume(double vol) => '${vol.toStringAsFixed(0)} ML';
  static String formatPercent(double val) => '${val.toStringAsFixed(1)}%';

  static Widget statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget simulationBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info_outline, size: 14, color: Color(0xFFF57C00)),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              AppConstants.simulationBadge,
              style: TextStyle(
                color: Color(0xFFF57C00),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
