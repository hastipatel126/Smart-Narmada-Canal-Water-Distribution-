import 'package:flutter/foundation.dart';
import '../models/farmer_model.dart';
import '../models/canal_section_model.dart';
import '../models/water_allocation_model.dart';
import '../models/dispute_model.dart';
import '../models/alert_model.dart';
import '../models/chat_message.dart';
import '../agents/canal_flow_agent.dart';
import '../agents/distribution_agent.dart';
import '../agents/farmer_alert_agent.dart';
import '../agents/dashboard_agent.dart';
import '../data/demo_data.dart';
import '../core/constants/app_constants.dart';

/// Central application state — all screens read from and write to this provider.
class AppState extends ChangeNotifier {
  // ── Raw data ──────────────────────────────────────────────────────────────
  List<FarmerModel> _farmers = DemoData.farmers;
  List<CanalSectionModel> _canalSections = DemoData.canalSections;
  List<WaterAllocationModel> _currentAllocations = DemoData.currentAllocations;
  List<WaterAllocationModel> _aiAllocations = DemoData.aiRecommendedAllocations;
  List<DisputeModel> _disputes = DemoData.disputes;
  List<AlertModel> _alerts = DemoData.alerts;

  // ── Simulation scenario ───────────────────────────────────────────────────
  String _activeScenario = AppConstants.scenarioNormal;

  // ── Selected farmer (for farmer view) ────────────────────────────────────
  FarmerModel? _selectedFarmer;

  // ── Computed state ────────────────────────────────────────────────────────
  late DashboardKPIs _kpis;
  List<CanalAnomalyReport> _anomalies = [];
  List<FarmerAlert> _farmerAlerts = [];

  // ── Language ──────────────────────────────────────────────────────────────
  String _language = AppConstants.english;

  // ── Role ──────────────────────────────────────────────────────────────────
  String _role = AppConstants.roleGuest;

  // ── Chat ──────────────────────────────────────────────────────────────────
  List<ChatMessage> _chatMessages = [];
  bool _chatTyping = false;

  AppState() {
    _recompute();
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<FarmerModel> get farmers => _farmers;
  List<CanalSectionModel> get canalSections => _canalSections;
  List<WaterAllocationModel> get currentAllocations => _currentAllocations;
  List<WaterAllocationModel> get aiAllocations => _aiAllocations;
  List<DisputeModel> get disputes => _disputes;
  List<AlertModel> get alerts => DashboardAgent.prioritiseAlerts(_alerts);
  DashboardKPIs get kpis => _kpis;
  List<CanalAnomalyReport> get anomalies => _anomalies;
  List<FarmerAlert> get farmerAlerts => _farmerAlerts;
  String get activeScenario => _activeScenario;
  FarmerModel? get selectedFarmer => _selectedFarmer;
  String get language => _language;
  int get openDisputeCount => _disputes.where((d) => d.status != AppConstants.resolved).length;
  String get role => _role;
  bool get isLoggedIn => _role != AppConstants.roleGuest;
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  bool get chatTyping => _chatTyping;

  // ── Mutations ─────────────────────────────────────────────────────────────

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void logout() {
    _role = AppConstants.roleGuest;
    _chatMessages = [];
    notifyListeners();
  }

  void applyScenario(String scenario) {
    _activeScenario = scenario;
    _canalSections = DemoData.canalSections
        .map((s) => CanalFlowAgent.applyScenario(s, scenario))
        .toList();
    _recompute();
    notifyListeners();
  }

  void approveAllocation(String allocationId) {
    _aiAllocations = _aiAllocations.map((a) {
      if (a.allocationId == allocationId) return a.copyWith(status: AppConstants.approved);
      return a;
    }).toList();
    _addSystemAlert(
      AlertModel(
        alertId: 'SYS-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Allocation Approved',
        message: 'Recommendation $allocationId approved by officer.',
        severity: AppConstants.low,
        source: 'Distribution',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void rejectAllocation(String allocationId) {
    _aiAllocations = _aiAllocations.map((a) {
      if (a.allocationId == allocationId) return a.copyWith(status: 'Rejected');
      return a;
    }).toList();
    notifyListeners();
  }

  void updateDisputeStatus(String complaintId, String newStatus) {
    for (final d in _disputes) {
      if (d.complaintId == complaintId) {
        d.status = newStatus;
        d.auditTrail.add('Status updated to "$newStatus" — ${_nowFormatted()}');
        break;
      }
    }
    notifyListeners();
  }

  void setSelectedFarmer(FarmerModel farmer) {
    _selectedFarmer = farmer;
    notifyListeners();
  }

  void toggleLanguage() {
    _language = _language == AppConstants.english ? AppConstants.gujarati : AppConstants.english;
    notifyListeners();
  }

  void markAlertRead(String alertId) {
    for (final a in _alerts) {
      if (a.alertId == alertId) a.isRead = true;
    }
    notifyListeners();
  }

  void regenerateAiAllocations() {
    final available = _canalSections.fold<double>(0, (s, c) => s + c.supply * 3.6);
    _aiAllocations = DistributionAgent.generateRecommendations(
      farmers: _farmers,
      availableSupply: available,
    );
    notifyListeners();
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  void sendChatMessage(String text) {
    final userMsg = ChatMessage(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages = [..._chatMessages, userMsg];
    _chatTyping = true;
    notifyListeners();

    // Simulate async AI response
    Future.delayed(const Duration(milliseconds: 900), () {
      final response = _generateAiResponse(text);
      final aiMsg = ChatMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatMessages = [..._chatMessages, aiMsg];
      _chatTyping = false;
      notifyListeners();
    });
  }

  void clearChat() {
    _chatMessages = [];
    notifyListeners();
  }

  String _generateAiResponse(String query) {
    final q = query.toLowerCase().trim();
    final kpis = _kpis;
    final report = kpis.fairnessReport;

    if (q.contains('status') || q.contains('water status')) {
      final totalFlow = _canalSections.fold<double>(0, (s, c) => s + c.flowRate);
      final critical = _canalSections.where((c) => c.status == 'Critical').length;
      return 'Current system status:\n'
          '• Total canal flow: ${totalFlow.toStringAsFixed(1)} m³/s\n'
          '• Fairness score: ${kpis.fairnessScore.toStringAsFixed(0)}/100\n'
          '• Critical sections: $critical\n'
          '• Active alerts: ${kpis.activeAlerts}\n'
          '• Scenario: $_activeScenario';
    }

    if (q.contains('fairness')) {
      return 'Water Distribution Fairness Score: ${kpis.fairnessScore.toStringAsFixed(0)}/100\n\n'
          '• Head-Reach: ${report.headReachAllocationPercent.toStringAsFixed(1)}% fulfilled\n'
          '• Mid-Reach: ${report.midReachAllocationPercent.toStringAsFixed(1)}% fulfilled\n'
          '• Tail-End: ${report.tailEndAllocationPercent.toStringAsFixed(1)}% fulfilled\n\n'
          'Trend: ${report.trend}. '
          '${kpis.fairnessScore < 65 ? "Immediate rebalancing recommended — tail-end zones are severely underserved." : "System fairness is acceptable."}';
    }

    if (q.contains('shortage') || q.contains('risk')) {
      final tailFarmers = _farmers.where((f) => f.reachType == AppConstants.tailEnd).toList();
      final avgTail = tailFarmers.isEmpty
          ? 0.0
          : tailFarmers.fold<double>(0, (s, f) => s + f.allocationRatio) / tailFarmers.length;
      final risk = avgTail < 0.5 ? 'HIGH' : avgTail < 0.75 ? 'MEDIUM' : 'LOW';
      return 'Shortage Risk Assessment: $risk\n\n'
          'Tail-end average fulfillment: ${(avgTail * 100).toStringAsFixed(1)}%\n'
          'Supply / Demand gap: ${(kpis.totalDemand - kpis.waterDistributed).toStringAsFixed(0)} ML\n'
          '${risk == "HIGH" ? "⚠ Immediate reallocation needed. Crops at risk of yield loss." : "Monitor closely over next 24 hours."}';
    }

    if (q.contains('tail') || q.contains('underserved')) {
      final tailFarmers = _farmers.where((f) => f.reachType == AppConstants.tailEnd).toList();
      final lines = tailFarmers.map((f) =>
          '• ${f.name} (${f.zone}): ${(f.allocationRatio * 100).toStringAsFixed(0)}% fulfilled').join('\n');
      return 'Underserved Tail-End Zones:\n\n$lines\n\n'
          'These ${tailFarmers.length} farmers are receiving critically low water. AI recommends priority allocation in next cycle.';
    }

    if (q.contains('schedule') || q.contains('my schedule')) {
      final pending = _aiAllocations.where((a) => a.status == AppConstants.pending).toList();
      if (pending.isEmpty) return 'All AI schedule recommendations have been reviewed and approved.';
      final top = pending.first;
      return 'Next AI-recommended irrigation:\n\n'
          '• Zone: ${top.zoneName}\n'
          '• Time: ${top.startTime} – ${top.endTime}\n'
          '• Water: ${top.allocatedWater.toStringAsFixed(0)} ML\n'
          '• Status: Awaiting officer approval\n\n'
          '${pending.length} total pending recommendations.';
    }

    if (q.contains('summary') || q.contains('today')) {
      return 'Today\'s System Summary:\n\n'
          '• Water available: ${kpis.totalWaterAvailable.toStringAsFixed(0)} ML\n'
          '• Total demand: ${kpis.totalDemand.toStringAsFixed(0)} ML\n'
          '• Distributed: ${kpis.waterDistributed.toStringAsFixed(0)} ML\n'
          '• Efficiency: ${kpis.efficiencyScore.toStringAsFixed(1)}%\n'
          '• Fairness score: ${kpis.fairnessScore.toStringAsFixed(0)}/100\n'
          '• Open disputes: ${kpis.activeDisputes}\n'
          '• Active alerts: ${kpis.activeAlerts}\n'
          '• Scenario: $_activeScenario';
    }

    if (q.contains('alert')) {
      final top = _alerts.take(3).toList();
      if (top.isEmpty) return 'No active alerts at this time.';
      final lines = top.map((a) => '• [${a.severity}] ${a.title}').join('\n');
      return 'Active Alerts:\n\n$lines\n\nTotal: ${_alerts.length} alerts in system.';
    }

    if (q.contains('dispute')) {
      final open = _disputes.where((d) => d.status != AppConstants.resolved).length;
      final critical = _disputes.where((d) => d.severity == AppConstants.critical).length;
      return 'Dispute Summary:\n\n'
          '• Total disputes: ${_disputes.length}\n'
          '• Open/Active: $open\n'
          '• Critical: $critical\n'
          '• Resolved: ${_disputes.length - open}\n\n'
          '${critical > 0 ? "⚠ $critical critical dispute(s) require immediate officer attention." : "No critical disputes currently."}';
    }

    if (q.contains('પાણી') || q.contains('pani')) {
      return 'પ્રિય ખેડૂત,\n\n'
          'સિસ્ટમ સ્ટેટસ:\n'
          '• ફેરનેસ સ્કોર: ${kpis.fairnessScore.toStringAsFixed(0)}/100\n'
          '• ઉપલબ્ધ પાણી: ${kpis.totalWaterAvailable.toStringAsFixed(0)} ML\n'
          '• ટેઇલ-એન્ડ ફુલફિલમેન્ટ: ${report.tailEndAllocationPercent.toStringAsFixed(1)}%\n\n'
          'AI ભલામણ: ટેઇલ-એન્ડ ઝોન્સ માટે તાત્કાલિક ફાળવણી જરૂરી છે.';
    }

    return 'I understand you\'re asking about "${query.length > 40 ? "${query.substring(0, 40)}..." : query}".\n\n'
        'I can help with:\n'
        '• Water status & flow\n'
        '• Fairness score analysis\n'
        '• Shortage risk assessment\n'
        '• Schedule information\n'
        '• Alerts & disputes\n'
        '• Daily summary\n\n'
        'Try one of the quick prompts below, or ask me in plain English (or Gujarati: "પાણી").';
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _recompute() {
    _anomalies = _canalSections.map(CanalFlowAgent.analyseSection).toList();
    _farmerAlerts = FarmerAlertAgent.generateAlerts(_farmers);
    _kpis = DashboardAgent.computeKPIs(
      farmers: _farmers,
      canalSections: _canalSections,
      alerts: _alerts,
      activeDisputes: openDisputeCount,
    );
  }

  void _addSystemAlert(AlertModel alert) {
    _alerts = [alert, ..._alerts];
  }

  String _nowFormatted() {
    final n = DateTime.now();
    return '${n.day}/${n.month}/${n.year} ${n.hour}:${n.minute.toString().padLeft(2, '0')}';
  }
}
