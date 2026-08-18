import '../models/farmer_model.dart';
import '../models/canal_section_model.dart';
import '../models/alert_model.dart';
import '../models/fairness_report.dart';
import '../agents/distribution_agent.dart';
import '../core/constants/app_constants.dart';

/// Dashboard Intelligence Agent
/// Responsibility: Aggregate system-wide KPIs, generate the overall
/// fairness report, and prioritise alerts for the officer dashboard.
class DashboardAgent {
  static DashboardKPIs computeKPIs({
    required List<FarmerModel> farmers,
    required List<CanalSectionModel> canalSections,
    required List<AlertModel> alerts,
    required int activeDisputes,
  }) {
    // Water totals
    double totalDemand = 0, totalDistributed = 0;
    for (final f in farmers) {
      totalDemand += f.waterRequired;
      totalDistributed += f.waterReceived;
    }
    final totalAvailable = canalSections.fold<double>(0, (s, c) => s + c.supply * 3.6);
    final totalRemaining = (totalAvailable - totalDistributed).clamp(0.0, double.infinity);

    // Efficiency: distributed / demand
    final efficiency = totalDemand > 0 ? (totalDistributed / totalDemand) * 100 : 0.0;

    // Fairness
    final fairnessReport = DistributionAgent.computeFairness(farmers);

    // Canal anomalies
    final anomalyCount = canalSections
        .where((c) => c.status == 'Critical' || c.status == 'Warning')
        .length;

    final unreadAlerts = alerts.where((a) => !a.isRead).length;

    return DashboardKPIs(
      totalWaterAvailable: totalAvailable,
      totalDemand: totalDemand,
      waterDistributed: totalDistributed,
      waterRemaining: totalRemaining,
      fairnessScore: fairnessReport.overallScore,
      efficiencyScore: efficiency.clamp(0.0, 100.0),
      activeAlerts: unreadAlerts,
      activeDisputes: activeDisputes,
      anomalySections: anomalyCount,
      fairnessReport: fairnessReport,
    );
  }

  static List<AlertModel> prioritiseAlerts(List<AlertModel> alerts) {
    final order = {
      AppConstants.critical: 0,
      AppConstants.high: 1,
      AppConstants.medium: 2,
      AppConstants.low: 3,
    };
    final sorted = List<AlertModel>.from(alerts);
    sorted.sort((a, b) {
      final severityComp = (order[a.severity] ?? 4).compareTo(order[b.severity] ?? 4);
      if (severityComp != 0) return severityComp;
      return b.timestamp.compareTo(a.timestamp);
    });
    return sorted;
  }

  /// What happened / Why / Data / Recommendation / Consequence
  static AIExplanation explainFairnessScore(FairnessReport report) {
    return AIExplanation(
      whatHappened: 'The Water Distribution Fairness Score is ${report.overallScore.toStringAsFixed(0)}/100.',
      whyDetected:
          'Head-reach zones received ${report.headReachAllocationPercent.toStringAsFixed(1)}% of required water, '
          'while tail-end zones received only ${report.tailEndAllocationPercent.toStringAsFixed(1)}%.',
      dataConsidered: [
        'Head-reach fulfillment: ${report.headReachAllocationPercent.toStringAsFixed(1)}%',
        'Mid-reach fulfillment: ${report.midReachAllocationPercent.toStringAsFixed(1)}%',
        'Tail-end fulfillment: ${report.tailEndAllocationPercent.toStringAsFixed(1)}%',
        'Gap penalty applied: ${(report.headReachAllocationPercent - report.tailEndAllocationPercent).toStringAsFixed(1)}%',
        'Trend: ${report.trend}',
      ],
      recommendation: report.overallScore < AppConstants.warningFairnessThreshold
          ? 'Immediate rebalancing of water allocation is recommended. '
              'Prioritize tail-end zones in the next 2–3 irrigation cycles.'
          : 'Continue monitoring. Minor adjustments may improve the score further.',
      consequence: report.overallScore < AppConstants.criticalFairnessThreshold
          ? 'Without intervention, tail-end crops face significant yield loss. '
              'Farmer disputes are likely to escalate.'
          : 'Score may continue declining if current distribution pattern persists.',
    );
  }
}

class DashboardKPIs {
  final double totalWaterAvailable;
  final double totalDemand;
  final double waterDistributed;
  final double waterRemaining;
  final double fairnessScore;
  final double efficiencyScore;
  final int activeAlerts;
  final int activeDisputes;
  final int anomalySections;
  final FairnessReport fairnessReport;

  const DashboardKPIs({
    required this.totalWaterAvailable,
    required this.totalDemand,
    required this.waterDistributed,
    required this.waterRemaining,
    required this.fairnessScore,
    required this.efficiencyScore,
    required this.activeAlerts,
    required this.activeDisputes,
    required this.anomalySections,
    required this.fairnessReport,
  });
}

class AIExplanation {
  final String whatHappened;
  final String whyDetected;
  final List<String> dataConsidered;
  final String recommendation;
  final String consequence;

  const AIExplanation({
    required this.whatHappened,
    required this.whyDetected,
    required this.dataConsidered,
    required this.recommendation,
    required this.consequence,
  });
}
