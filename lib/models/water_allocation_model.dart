class WaterAllocationModel {
  final String allocationId;
  final String zoneId;
  final String zoneName;
  final String reachType;
  final double allocatedWater; // ML
  final double requiredWater; // ML
  final String startTime;
  final String endTime;
  final int priority;
  final String reason;
  final String status; // Pending, Approved, Active
  final bool isAiRecommended;
  final double allocationPercent;

  WaterAllocationModel({
    required this.allocationId,
    required this.zoneId,
    required this.zoneName,
    required this.reachType,
    required this.allocatedWater,
    required this.requiredWater,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.reason,
    required this.status,
    this.isAiRecommended = true,
  }) : allocationPercent = (allocatedWater / requiredWater) * 100;

  WaterAllocationModel copyWith({String? status}) {
    return WaterAllocationModel(
      allocationId: allocationId,
      zoneId: zoneId,
      zoneName: zoneName,
      reachType: reachType,
      allocatedWater: allocatedWater,
      requiredWater: requiredWater,
      startTime: startTime,
      endTime: endTime,
      priority: priority,
      reason: reason,
      status: status ?? this.status,
      isAiRecommended: isAiRecommended,
    );
  }
}
