import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.simulationBadge(),
            const SizedBox(height: 12),
            _SimControlPanel(activeScenario: state.activeScenario),
            const SizedBox(height: 16),
            _SimResultsPanel(state: state),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SimControlPanel extends StatelessWidget {
  final String activeScenario;
  const _SimControlPanel({required this.activeScenario});

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      (AppConstants.scenarioNormal, Icons.check_circle_outline, AppTheme.successColor,
          'Baseline normal flow conditions.'),
      (AppConstants.scenarioLow, Icons.arrow_downward, AppTheme.warning,
          'Flow reduced by ~25%. Monitor mid-reach.'),
      (AppConstants.scenarioHigh, Icons.arrow_upward, AppTheme.infoColor,
          'High inflow event — surplus water available.'),
      (AppConstants.scenarioShortage, Icons.water_drop_outlined, const Color(0xFFE65100),
          'Shortage — significant demand-supply gap.'),
      (AppConstants.scenarioEmergency, Icons.warning_amber, AppTheme.danger,
          'Emergency! Canal flow critically low.'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.science_outlined, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text('Simulation Control Panel',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Select a flow scenario. All agents will react in real-time and update the system.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...scenarios.map((s) => _ScenarioTile(
                  scenario: s.$1,
                  icon: s.$2,
                  color: s.$3,
                  description: s.$4,
                  isActive: activeScenario == s.$1,
                  onTap: () => context.read<AppState>().applyScenario(s.$1),
                )),
          ],
        ),
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  final String scenario;
  final IconData icon;
  final Color color;
  final String description;
  final bool isActive;
  final VoidCallback onTap;

  const _ScenarioTile({
    required this.scenario,
    required this.icon,
    required this.color,
    required this.description,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isActive ? color : AppTheme.borderColor,
              width: isActive ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scenario,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive ? color : AppTheme.textPrimary)),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            if (isActive)
              Icon(Icons.radio_button_checked, color: color, size: 18)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SimResultsPanel extends StatelessWidget {
  final AppState state;
  const _SimResultsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final kpis = state.kpis;
    final report = kpis.fairnessReport;
    final sections = state.canalSections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary.withValues(alpha: 0.1),
                       AppTheme.accent.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.insights, color: AppTheme.primary, size: 16),
                const SizedBox(width: 6),
                Text('Live Agent Results — ${state.activeScenario}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.primary)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _simKpi('Fairness', '${kpis.fairnessScore.toStringAsFixed(0)}/100',
                    AppUtils.fairnessColor(kpis.fairnessScore)),
                _simKpi('Efficiency', '${kpis.efficiencyScore.toStringAsFixed(1)}%',
                    AppUtils.fairnessColor(kpis.efficiencyScore)),
                _simKpi('Alerts', '${kpis.activeAlerts}',
                    kpis.activeAlerts > 3 ? AppTheme.danger : AppTheme.warning),
                _simKpi('Disputes', '${kpis.activeDisputes}',
                    kpis.activeDisputes > 0 ? AppTheme.danger : AppTheme.successColor),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Canal sections as bars
        Text('Canal Section Response',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...sections.map((s) {
          final color = s.status == 'Critical'
              ? AppTheme.danger
              : s.status == 'Warning'
                  ? AppTheme.warning
                  : AppTheme.successColor;
          final ratio = (s.supplyRatio).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(s.sectionName,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  AppUtils.statusChip(s.status, color),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                    '${s.flowRate.toStringAsFixed(1)} m³/s  ·  Supply/Demand: ${(ratio * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),
        // Fairness comparison bar chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Head → Mid → Tail Fulfillment',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const labels = ['Head', 'Mid', 'Tail'];
                              return Text(labels[v.toInt()],
                                  style: const TextStyle(
                                      fontSize: 10, color: AppTheme.textMuted));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(
                              toY: report.headReachAllocationPercent,
                              color: AppTheme.headReachColor,
                              width: 28,
                              borderRadius: BorderRadius.circular(4))
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                              toY: report.midReachAllocationPercent,
                              color: AppTheme.midReachColor,
                              width: 28,
                              borderRadius: BorderRadius.circular(4))
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(
                              toY: report.tailEndAllocationPercent,
                              color: AppTheme.tailEndColor,
                              width: 28,
                              borderRadius: BorderRadius.circular(4))
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _simKpi(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
