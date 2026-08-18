import '../models/farmer_model.dart';
import '../models/alert_model.dart';
import '../core/constants/app_constants.dart';

/// Farmer Alert Agent
/// Responsibility: Generate farmer-specific alerts and water availability messages
/// in English and Gujarati.
class FarmerAlertAgent {
  static List<FarmerAlert> generateAlerts(List<FarmerModel> farmers) {
    final List<FarmerAlert> alerts = [];
    for (final farmer in farmers) {
      final ratio = farmer.allocationRatio;
      if (farmer.reachType == AppConstants.tailEnd && ratio < 0.5) {
        alerts.add(FarmerAlert(
          farmerId: farmer.farmerId,
          farmerName: farmer.name,
          severity: AppConstants.high,
          messageEn: 'Your zone ${farmer.zone} has received only '
              '${(ratio * 100).toStringAsFixed(1)}% of required water. '
              'Expected irrigation window: Contact your section officer.',
          messageGu: 'તમારા વિસ્તાર ${farmer.zone}ને જરૂરી પાણીના માત્ર '
              '${(ratio * 100).toStringAsFixed(1)}% મળ્યું છે. '
              'સિંચાઈ અધિકારીનો સંપર્ક કરો.',
          waterStatus: 'Critically Low',
          expectedArrival: 'Next 12–24 hours (pending AI schedule approval)',
        ));
      } else if (ratio < 0.75) {
        alerts.add(FarmerAlert(
          farmerId: farmer.farmerId,
          farmerName: farmer.name,
          severity: AppConstants.medium,
          messageEn: 'Zone ${farmer.zone}: Water availability below normal. '
              'Your irrigation is scheduled: ${farmer.scheduledTime}.',
          messageGu: 'ઝોન ${farmer.zone}: પાણીની ઉપલબ્ધતા સામાન્ય કરતા ઓછી છે. '
              'તમારી સિંચાઈ સમય: ${farmer.scheduledTime}.',
          waterStatus: 'Below Normal',
          expectedArrival: farmer.scheduledTime,
        ));
      }
    }
    return alerts;
  }

  static FarmerWaterStatus getWaterStatus(FarmerModel farmer) {
    final ratio = farmer.allocationRatio;
    String statusEn;
    String statusGu;
    String arrivalEn;
    String arrivalGu;

    if (ratio >= 0.90) {
      statusEn = 'Water supply is normal for your area.';
      statusGu = 'તમારા વિસ્તારમાં પાણી પુરવઠો સામાન્ય છે.';
      arrivalEn = farmer.scheduledTime;
      arrivalGu = farmer.scheduledTime;
    } else if (ratio >= 0.60) {
      statusEn = 'Water supply is below normal. Irrigation scheduled at ${farmer.scheduledTime}.';
      statusGu = 'પાણી પુરવઠો સામાન્ય કરતા ઓછો છે. '
          'સિંચાઈ સમય: ${farmer.scheduledTime}.';
      arrivalEn = farmer.scheduledTime;
      arrivalGu = farmer.scheduledTime;
    } else {
      statusEn = 'Significant water shortage in your zone ${farmer.zone}. '
          'AI-generated schedule recommends priority allocation for next cycle.';
      statusGu = 'તમારા ઝોન ${farmer.zone}માં ગંભીર પાણીની અછત. '
          'AI ભલામણ: આગામી ચક્રમાં પ્રાથમિકતા સિંચાઈ.';
      arrivalEn = 'Within next 24 hours (subject to officer approval)';
      arrivalGu = 'આગામી ૨૪ કલાકમાં (અધિકારી મંજૂરી સાપેક્ષ)';
    }

    return FarmerWaterStatus(
      farmer: farmer,
      statusEn: statusEn,
      statusGu: statusGu,
      waterAvailable: farmer.waterReceived,
      waterRequired: farmer.waterRequired,
      allocationPercent: ratio * 100,
      irrigationStartEn: arrivalEn,
      irrigationStartGu: arrivalGu,
    );
  }

  static AlertModel toSystemAlert(FarmerAlert fa) {
    return AlertModel(
      alertId: 'FA-${fa.farmerId}',
      title: 'Farmer Alert: ${fa.farmerName}',
      message: fa.messageEn,
      severity: fa.severity,
      source: 'Farmer',
      timestamp: DateTime.now(),
    );
  }
}

class FarmerAlert {
  final String farmerId;
  final String farmerName;
  final String severity;
  final String messageEn;
  final String messageGu;
  final String waterStatus;
  final String expectedArrival;

  const FarmerAlert({
    required this.farmerId,
    required this.farmerName,
    required this.severity,
    required this.messageEn,
    required this.messageGu,
    required this.waterStatus,
    required this.expectedArrival,
  });
}

class FarmerWaterStatus {
  final FarmerModel farmer;
  final String statusEn;
  final String statusGu;
  final double waterAvailable;
  final double waterRequired;
  final double allocationPercent;
  final String irrigationStartEn;
  final String irrigationStartGu;

  const FarmerWaterStatus({
    required this.farmer,
    required this.statusEn,
    required this.statusGu,
    required this.waterAvailable,
    required this.waterRequired,
    required this.allocationPercent,
    required this.irrigationStartEn,
    required this.irrigationStartGu,
  });
}
