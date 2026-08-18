class AlertModel {
  final String alertId;
  final String title;
  final String message;
  final String severity; // Low, Medium, High, Critical
  final String source; // Canal, Distribution, Farmer, Dispute
  final DateTime timestamp;
  bool isRead;

  AlertModel({
    required this.alertId,
    required this.title,
    required this.message,
    required this.severity,
    required this.source,
    required this.timestamp,
    this.isRead = false,
  });
}
