class FairnessReport {
  final double overallScore;
  final double headReachAllocationPercent;
  final double midReachAllocationPercent;
  final double tailEndAllocationPercent;
  final String explanation;
  final String trend; // Improving, Declining, Stable
  final List<ZoneFairnessData> zoneData;

  const FairnessReport({
    required this.overallScore,
    required this.headReachAllocationPercent,
    required this.midReachAllocationPercent,
    required this.tailEndAllocationPercent,
    required this.explanation,
    required this.trend,
    required this.zoneData,
  });
}

class ZoneFairnessData {
  final String zoneId;
  final String zoneName;
  final String reachType;
  final double required;
  final double allocated;
  final double received;
  final double fairnessScore;

  const ZoneFairnessData({
    required this.zoneId,
    required this.zoneName,
    required this.reachType,
    required this.required,
    required this.allocated,
    required this.received,
    required this.fairnessScore,
  });

  double get allocationPercent => (received / required) * 100;
}
