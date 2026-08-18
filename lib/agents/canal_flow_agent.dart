import '../models/canal_section_model.dart';
import '../core/constants/app_constants.dart';

/// Canal Flow Monitoring Agent
/// Responsibility: Monitor canal conditions, detect anomalies, and
/// recommend actions based on flow/level data.
class CanalFlowAgent {
  /// Analyse a single canal section and return an anomaly report.
  static CanalAnomalyReport analyseSection(CanalSectionModel section) {
    final List<String> anomalies = [];
    String riskLevel = AppConstants.low;
    String recommendedAction = 'Continue normal monitoring.';

    final utilization = section.utilizationPercent;
    final supplyRatio = section.supplyRatio;

    // Check for sudden drop in flow (>20% drop in last 3 readings)
    if (section.flowHistory.length >= 3) {
      final recent = section.flowHistory.last;
      final prev = section.flowHistory[section.flowHistory.length - 4 < 0
          ? 0
          : section.flowHistory.length - 4];
      final drop = (prev - recent) / prev * 100;
      if (drop >= 35) {
        anomalies.add('Sudden flow decrease of ${drop.toStringAsFixed(1)}% detected.');
        riskLevel = AppConstants.critical;
      } else if (drop >= 20) {
        anomalies.add('Gradual flow decrease of ${drop.toStringAsFixed(1)}% detected.');
        riskLevel = AppConstants.high;
      }
    }

    // Supply-demand check
    if (supplyRatio < 0.40) {
      anomalies.add('Critical shortage: supply is only ${(supplyRatio * 100).toStringAsFixed(1)}% of demand.');
      riskLevel = AppConstants.critical;
      recommendedAction = 'Immediate upstream inspection required. '
          'Activate emergency water release protocol. Alert downstream farmers.';
    } else if (supplyRatio < 0.70) {
      if (riskLevel != AppConstants.critical) riskLevel = AppConstants.high;
      anomalies.add('Significant undersupply: ${(supplyRatio * 100).toStringAsFixed(1)}% of demand met.');
      recommendedAction = 'Reduce upstream allocation and redirect flow downstream. '
          'Notify section controller.';
    } else if (supplyRatio < 0.85) {
      if (riskLevel == AppConstants.low) riskLevel = AppConstants.medium;
      anomalies.add('Moderate undersupply: ${(supplyRatio * 100).toStringAsFixed(1)}% of demand met.');
      recommendedAction = 'Monitor closely. Consider minor schedule adjustments.';
    }

    // Over-utilization
    if (utilization > 95) {
      anomalies.add('Canal near maximum capacity (${utilization.toStringAsFixed(1)}%). Risk of overflow.');
      if (riskLevel == AppConstants.low) riskLevel = AppConstants.medium;
      recommendedAction = 'Reduce inlet flow rate. Check downstream gates.';
    }

    // Water level
    if (section.waterLevel < 0.8) {
      anomalies.add('Water level critically low at ${section.waterLevel.toStringAsFixed(2)} m.');
      riskLevel = AppConstants.critical;
    } else if (section.waterLevel < 1.5) {
      anomalies.add('Water level below normal: ${section.waterLevel.toStringAsFixed(2)} m.');
      if (riskLevel == AppConstants.low) riskLevel = AppConstants.medium;
    }

    return CanalAnomalyReport(
      sectionId: section.sectionId,
      sectionName: section.sectionName,
      anomalies: anomalies,
      riskLevel: riskLevel,
      recommendedAction: anomalies.isEmpty ? 'No anomalies detected. Normal operation.' : recommendedAction,
      dataConsidered: [
        'Flow Rate: ${section.flowRate} m³/s',
        'Water Level: ${section.waterLevel} m',
        'Capacity Utilization: ${utilization.toStringAsFixed(1)}%',
        'Supply/Demand Ratio: ${(supplyRatio * 100).toStringAsFixed(1)}%',
        'Historical Flow: last ${section.flowHistory.length} readings',
      ],
    );
  }

  /// Simulate flow changes based on scenario
  static CanalSectionModel applyScenario(CanalSectionModel section, String scenario) {
    switch (scenario) {
      case AppConstants.scenarioLow:
        return section.copyWith(
          flowRate: section.capacity * 0.40,
          waterLevel: section.waterLevel * 0.55,
          supply: section.supply * 0.45,
          status: 'Warning',
        );
      case AppConstants.scenarioHigh:
        return section.copyWith(
          flowRate: section.capacity * 0.92,
          waterLevel: section.waterLevel * 1.18,
          supply: section.demand * 1.1,
          status: 'Normal',
        );
      case AppConstants.scenarioShortage:
        return section.copyWith(
          flowRate: section.capacity * 0.25,
          waterLevel: section.waterLevel * 0.35,
          supply: section.demand * 0.28,
          status: 'Critical',
        );
      case AppConstants.scenarioEmergency:
        return section.copyWith(
          flowRate: section.capacity * 0.10,
          waterLevel: section.waterLevel * 0.15,
          supply: section.demand * 0.12,
          status: 'Critical',
        );
      default: // Normal
        return section;
    }
  }
}

class CanalAnomalyReport {
  final String sectionId;
  final String sectionName;
  final List<String> anomalies;
  final String riskLevel;
  final String recommendedAction;
  final List<String> dataConsidered;

  const CanalAnomalyReport({
    required this.sectionId,
    required this.sectionName,
    required this.anomalies,
    required this.riskLevel,
    required this.recommendedAction,
    required this.dataConsidered,
  });

  bool get hasAnomalies => anomalies.isNotEmpty;
}
