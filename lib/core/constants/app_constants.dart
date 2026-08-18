class AppConstants {
  static const String appTitle = 'Narmada Water Monitor';
  static const String simulationBadge = '⚠ SIMULATION MODE — DEMO DATA';

  // Zone types
  static const String headReach = 'Head-Reach';
  static const String midReach = 'Mid-Reach';
  static const String tailEnd = 'Tail-End';

  // Dispute statuses
  static const String open = 'Open';
  static const String underReview = 'Under Review';
  static const String resolved = 'Resolved';

  // Schedule statuses
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String active = 'Active';

  // Languages
  static const String english = 'English';
  static const String gujarati = 'Gujarati';

  // Fairness thresholds
  static const double criticalFairnessThreshold = 40.0;
  static const double warningFairnessThreshold = 65.0;
  static const double goodFairnessThreshold = 80.0;

  // Simulation scenarios
  static const String scenarioNormal = 'Normal Flow';
  static const String scenarioLow = 'Low Flow';
  static const String scenarioHigh = 'High Flow';
  static const String scenarioShortage = 'Shortage';
  static const String scenarioEmergency = 'Emergency';

  // Alert severity levels
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String critical = 'Critical';

  // User roles
  static const String roleGuest = 'Guest';
  static const String roleFarmer = 'Farmer';
  static const String roleOfficer = 'Officer';
  static const String roleAdmin = 'Admin';
}
