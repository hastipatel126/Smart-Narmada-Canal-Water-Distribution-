class FarmerModel {
  final String farmerId;
  final String name;
  final String village;
  final String zone;
  final String reachType; // Head-Reach, Mid-Reach, Tail-End
  final String crop;
  final double landArea; // hectares
  final double waterRequired; // ML per cycle
  final double waterReceived; // ML
  final int priority; // 1 = highest
  final String scheduledTime;
  final String canalSection;
  final double allocationRatio; // waterReceived / waterRequired

  const FarmerModel({
    required this.farmerId,
    required this.name,
    required this.village,
    required this.zone,
    required this.reachType,
    required this.crop,
    required this.landArea,
    required this.waterRequired,
    required this.waterReceived,
    required this.priority,
    required this.scheduledTime,
    required this.canalSection,
  }) : allocationRatio = waterReceived / waterRequired;

  double get shortageAmount => waterRequired - waterReceived;
  bool get hasShortage => waterReceived < waterRequired * 0.9;

  FarmerModel copyWith({
    double? waterReceived,
    String? scheduledTime,
    int? priority,
  }) {
    return FarmerModel(
      farmerId: farmerId,
      name: name,
      village: village,
      zone: zone,
      reachType: reachType,
      crop: crop,
      landArea: landArea,
      waterRequired: waterRequired,
      waterReceived: waterReceived ?? this.waterReceived,
      priority: priority ?? this.priority,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      canalSection: canalSection,
    );
  }
}
