import '../models/dispute_model.dart';
import '../models/farmer_model.dart';
import '../core/constants/app_constants.dart';

/// Dispute Detection Agent
/// Responsibility: Detect potential disputes from allocation data,
/// classify severity, and suggest resolutions — without unfair accusations.
class DisputeAgent {
  /// Detect potential disputes from farmer allocation data.
  static List<DetectedDispute> detectDisputes(List<FarmerModel> farmers) {
    final List<DetectedDispute> disputes = [];

    // Calculate head-reach average fulfillment
    final headFarmers = farmers.where((f) => f.reachType == AppConstants.headReach).toList();
    final tailFarmers = farmers.where((f) => f.reachType == AppConstants.tailEnd).toList();

    if (headFarmers.isEmpty || tailFarmers.isEmpty) return disputes;

    final headAvgFulfillment = headFarmers.fold<double>(0, (s, f) => s + f.allocationRatio) / headFarmers.length;
    final tailAvgFulfillment = tailFarmers.fold<double>(0, (s, f) => s + f.allocationRatio) / tailFarmers.length;

    // Detect systemic head-vs-tail inequity
    if (headAvgFulfillment - tailAvgFulfillment > 0.30) {
      final severity = (headAvgFulfillment - tailAvgFulfillment) > 0.45
          ? AppConstants.critical
          : AppConstants.high;
      disputes.add(DetectedDispute(
        id: 'AUTO-001',
        type: 'Systemic Inequity',
        description: 'Possible unequal allocation detected. '
            'Head-reach zones are receiving ${(headAvgFulfillment * 100).toStringAsFixed(1)}% '
            'of required water on average, while tail-end zones are receiving only '
            '${(tailAvgFulfillment * 100).toStringAsFixed(1)}%.',
        affectedZones: tailFarmers.map((f) => f.zone).toSet().join(', '),
        severity: severity,
        supportingData: [
          'Head-reach average fulfillment: ${(headAvgFulfillment * 100).toStringAsFixed(1)}%',
          'Tail-end average fulfillment: ${(tailAvgFulfillment * 100).toStringAsFixed(1)}%',
          'Gap: ${((headAvgFulfillment - tailAvgFulfillment) * 100).toStringAsFixed(1)}%',
        ],
        suggestedResolution: 'Initiate upstream flow audit. '
            'Review and redistribute allocation for next 3 irrigation cycles. '
            'Assign field supervisor to tail-end sections.',
      ));
    }

    // Detect critically underserved individual farmers
    for (final farmer in tailFarmers) {
      if (farmer.allocationRatio < 0.45) {
        disputes.add(DetectedDispute(
          id: 'AUTO-${farmer.farmerId}',
          type: 'Individual Undersupply',
          description: 'Possible insufficient supply to farmer ${farmer.name} in zone ${farmer.zone}. '
              'Received ${(farmer.allocationRatio * 100).toStringAsFixed(1)}% of required water.',
          affectedZones: farmer.zone,
          severity: farmer.allocationRatio < 0.35 ? AppConstants.critical : AppConstants.high,
          supportingData: [
            'Required: ${farmer.waterRequired} ML',
            'Received: ${farmer.waterReceived} ML',
            'Shortfall: ${farmer.shortageAmount.toStringAsFixed(0)} ML',
            'Crop: ${farmer.crop} – ${farmer.village}',
          ],
          suggestedResolution: 'Priority irrigation allocation for zone ${farmer.zone} in next cycle. '
              'Field officer to verify gate position at section ${farmer.canalSection}.',
        ));
      }
    }

    return disputes;
  }

  /// Classify severity of an existing dispute based on data.
  static String classifySeverity(DisputeModel dispute) {
    final fulfillment = dispute.fulfillmentPercent;
    if (fulfillment < 40) return AppConstants.critical;
    if (fulfillment < 60) return AppConstants.high;
    if (fulfillment < 75) return AppConstants.medium;
    return AppConstants.low;
  }

  /// Generate a resolution text for a dispute.
  static String suggestResolution(DisputeModel dispute) {
    if (dispute.fulfillmentPercent < 40) {
      return 'Emergency: Immediate water release to ${dispute.region}. '
          'Reduce head-reach allocation by 20% for next 2 cycles. '
          'Alert district water management authority.';
    }
    if (dispute.fulfillmentPercent < 60) {
      return 'Urgent: Review upstream gate positions. '
          'Add ${dispute.region} to priority queue for next cycle. '
          'Issue compensatory allocation order.';
    }
    return 'Schedule review meeting with section officer. '
        'Adjust schedule for next cycle to compensate shortfall.';
  }
}

class DetectedDispute {
  final String id;
  final String type;
  final String description;
  final String affectedZones;
  final String severity;
  final List<String> supportingData;
  final String suggestedResolution;

  const DetectedDispute({
    required this.id,
    required this.type,
    required this.description,
    required this.affectedZones,
    required this.severity,
    required this.supportingData,
    required this.suggestedResolution,
  });
}
