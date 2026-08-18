import '../models/farmer_model.dart';
import '../models/water_allocation_model.dart';
import '../models/fairness_report.dart';
import '../core/constants/app_constants.dart';

/// Distribution Scheduling Agent
/// Responsibility: Calculate fair water allocation based on farmer requirements,
/// reach type, historical shortage, and available supply.
class DistributionAgent {
  static const double _tailEndBonus = 1.35;
  static const double _midReachBonus = 1.10;
  static const double _headReachPenalty = 0.90;

  /// Compute a fairness score (0–100) for the given allocation list.
  static FairnessReport computeFairness(List<FarmerModel> farmers) {
    if (farmers.isEmpty) {
      return FairnessReport(
        overallScore: 0,
        headReachAllocationPercent: 0,
        midReachAllocationPercent: 0,
        tailEndAllocationPercent: 0,
        explanation: 'No farmer data available.',
        trend: 'Stable',
        zoneData: [],
      );
    }

    double headRequired = 0, headReceived = 0;
    double midRequired = 0, midReceived = 0;
    double tailRequired = 0, tailReceived = 0;

    final Map<String, List<FarmerModel>> byZone = {};
    for (final f in farmers) {
      byZone.putIfAbsent(f.zone, () => []).add(f);
    }

    for (final f in farmers) {
      switch (f.reachType) {
        case AppConstants.headReach:
          headRequired += f.waterRequired;
          headReceived += f.waterReceived;
          break;
        case AppConstants.midReach:
          midRequired += f.waterRequired;
          midReceived += f.waterReceived;
          break;
        case AppConstants.tailEnd:
          tailRequired += f.waterRequired;
          tailReceived += f.waterReceived;
          break;
      }
    }

    final headPct = headRequired > 0 ? (headReceived / headRequired) * 100 : 0.0;
    final midPct = midRequired > 0 ? (midReceived / midRequired) * 100 : 0.0;
    final tailPct = tailRequired > 0 ? (tailReceived / tailRequired) * 100 : 0.0;

    // Fairness score: weighted average penalizing large gap between head and tail
    final gap = (headPct - tailPct).clamp(0.0, 100.0);
    final baseScore = (headPct + midPct + tailPct) / 3.0;
    final penaltyFactor = gap > 40 ? 0.75 : (gap > 25 ? 0.88 : 1.0);
    final overallScore = (baseScore * penaltyFactor).clamp(0.0, 100.0);

    // Per-zone breakdown
    final zoneData = byZone.entries.map((e) {
      final zFarmers = e.value;
      final zRequired = zFarmers.fold<double>(0, (s, f) => s + f.waterRequired);
      final zAllocated = zFarmers.fold<double>(0, (s, f) => s + f.waterReceived);
      final zScore = zRequired > 0 ? (zAllocated / zRequired) * 100 : 0.0;
      return ZoneFairnessData(
        zoneId: e.key,
        zoneName: '${e.key} – ${zFarmers.first.village}',
        reachType: zFarmers.first.reachType,
        required: zRequired,
        allocated: zAllocated,
        received: zAllocated,
        fairnessScore: zScore,
      );
    }).toList()
      ..sort((a, b) => a.fairnessScore.compareTo(b.fairnessScore));

    String explanation;
    String trend;
    if (gap > 40) {
      explanation = 'Fairness score is low because tail-end zones are receiving only '
          '${tailPct.toStringAsFixed(1)}% of required water while head-reach zones '
          'have received ${headPct.toStringAsFixed(1)}%. '
          'A gap of ${gap.toStringAsFixed(1)}% between head and tail-end indicates significant inequity.';
      trend = 'Declining';
    } else if (gap > 20) {
      explanation = 'Moderate inequity detected. Tail-end zones at ${tailPct.toStringAsFixed(1)}% '
          'vs head-reach at ${headPct.toStringAsFixed(1)}%. '
          'Scheduling adjustments are recommended to improve balance.';
      trend = 'Stable';
    } else {
      explanation = 'Water distribution is relatively balanced across all reach zones. '
          'Head-reach: ${headPct.toStringAsFixed(1)}%, Tail-end: ${tailPct.toStringAsFixed(1)}%.';
      trend = 'Improving';
    }

    return FairnessReport(
      overallScore: overallScore,
      headReachAllocationPercent: headPct.toDouble(),
      midReachAllocationPercent: midPct.toDouble(),
      tailEndAllocationPercent: tailPct.toDouble(),
      explanation: explanation,
      trend: trend,
      zoneData: zoneData,
    );
  }

  /// Generate priority-weighted allocation recommendations.
  static List<WaterAllocationModel> generateRecommendations({
    required List<FarmerModel> farmers,
    required double availableSupply, // total ML available
  }) {
    final Map<String, List<FarmerModel>> byZone = {};
    for (final f in farmers) {
      byZone.putIfAbsent(f.zone, () => []).add(f);
    }

    // Calculate zone needs with reach-type weighting
    final List<_ZoneNeed> needs = [];
    byZone.forEach((zone, zFarmers) {
      final reach = zFarmers.first.reachType;
      final totalRequired = zFarmers.fold<double>(0, (s, f) => s + f.waterRequired);
      final totalReceived = zFarmers.fold<double>(0, (s, f) => s + f.waterReceived);
      final histShortage = totalRequired - totalReceived;
      double weight = 1.0;
      if (reach == AppConstants.tailEnd) weight = _tailEndBonus;
      if (reach == AppConstants.midReach) weight = _midReachBonus;
      if (reach == AppConstants.headReach) weight = _headReachPenalty;
      // Bump weight if historically underserved
      final ratio = totalReceived / totalRequired;
      if (ratio < 0.5) weight *= 1.3;
      needs.add(_ZoneNeed(
        zone: zone,
        village: zFarmers.first.village,
        reachType: reach,
        required: totalRequired,
        received: totalReceived,
        shortage: histShortage,
        weight: weight,
        crop: zFarmers.map((f) => f.crop).toSet().join(', '),
      ));
    });

    // Sort by weight desc (highest priority first)
    needs.sort((a, b) => b.weight.compareTo(a.weight));

    double remaining = availableSupply;
    final List<WaterAllocationModel> recommendations = [];
    int startHour = 6;

    for (int i = 0; i < needs.length; i++) {
      final need = needs[i];
      final allocate = (need.required * need.weight).clamp(0.0, remaining);
      final durationHours = (allocate / 10).clamp(2.0, 12.0).round();
      final endHour = startHour + durationHours;

      recommendations.add(WaterAllocationModel(
        allocationId: 'AI-REC-${i + 1}',
        zoneId: need.zone,
        zoneName: '${need.zone} – ${need.village}',
        reachType: need.reachType,
        allocatedWater: allocate,
        requiredWater: need.required,
        startTime: _formatHour(startHour),
        endTime: _formatHour(endHour % 24),
        priority: need.reachType == AppConstants.tailEnd
            ? 1
            : need.reachType == AppConstants.midReach
                ? 2
                : 3,
        reason: _generateReason(need, allocate),
        status: AppConstants.pending,
        isAiRecommended: true,
      ));

      remaining -= allocate;
      startHour = endHour % 24;
      if (remaining <= 0) break;
    }

    return recommendations;
  }

  static String _generateReason(_ZoneNeed need, double allocate) {
    final pct = (need.received / need.required * 100).toStringAsFixed(1);
    final allocPct = (allocate / need.required * 100).toStringAsFixed(1);
    return '${need.zone} (${need.reachType}) has received $pct% of required water historically. '
        'Crops: ${need.crop}. '
        'AI allocates ${allocate.toStringAsFixed(0)} ML ($allocPct% of requirement) this cycle, '
        'prioritized using reach-type weighting (factor: ${need.weight.toStringAsFixed(2)}).';
  }

  static String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}

class _ZoneNeed {
  final String zone;
  final String village;
  final String reachType;
  final double required;
  final double received;
  final double shortage;
  final double weight;
  final String crop;

  const _ZoneNeed({
    required this.zone,
    required this.village,
    required this.reachType,
    required this.required,
    required this.received,
    required this.shortage,
    required this.weight,
    required this.crop,
  });
}
