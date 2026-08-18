class DisputeModel {
  final String complaintId;
  final String farmerId;
  final String farmerName;
  final String region;
  final String issue;
  final String severity; // Low, Medium, High, Critical
  String status; // Open, Under Review, Resolved
  final String aiAnalysis;
  final String suggestedResolution;
  final DateTime reportedAt;
  final double waterRequested;
  final double waterReceived;
  final String reachType;
  final List<String> auditTrail;

  DisputeModel({
    required this.complaintId,
    required this.farmerId,
    required this.farmerName,
    required this.region,
    required this.issue,
    required this.severity,
    required this.status,
    required this.aiAnalysis,
    required this.suggestedResolution,
    required this.reportedAt,
    required this.waterRequested,
    required this.waterReceived,
    required this.reachType,
    required this.auditTrail,
  });

  double get fulfillmentPercent => (waterReceived / waterRequested) * 100;
}
