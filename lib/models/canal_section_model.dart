class CanalSectionModel {
  final String sectionId;
  final String sectionName;
  final double flowRate; // m³/s
  final double waterLevel; // meters
  final double capacity; // m³/s
  final double demand; // m³/s
  final double supply; // m³/s
  final String status; // Normal, Warning, Critical, Blocked
  final DateTime timestamp;
  final List<double> flowHistory; // last 12 readings

  const CanalSectionModel({
    required this.sectionId,
    required this.sectionName,
    required this.flowRate,
    required this.waterLevel,
    required this.capacity,
    required this.demand,
    required this.supply,
    required this.status,
    required this.timestamp,
    required this.flowHistory,
  });

  double get utilizationPercent => (flowRate / capacity) * 100;
  double get supplyRatio => supply / demand;
  bool get isUnderSupplied => supply < demand * 0.75;

  CanalSectionModel copyWith({
    double? flowRate,
    double? waterLevel,
    double? supply,
    String? status,
    DateTime? timestamp,
    List<double>? flowHistory,
  }) {
    return CanalSectionModel(
      sectionId: sectionId,
      sectionName: sectionName,
      flowRate: flowRate ?? this.flowRate,
      waterLevel: waterLevel ?? this.waterLevel,
      capacity: capacity,
      demand: demand,
      supply: supply ?? this.supply,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      flowHistory: flowHistory ?? this.flowHistory,
    );
  }
}
