import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../agents/canal_flow_agent.dart';
import '../../models/canal_section_model.dart';
import '../../widgets/section_header.dart';
import '../../widgets/canal_map_widget.dart';

class CanalMonitoringScreen extends StatelessWidget {
  const CanalMonitoringScreen({super.key});

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

            // Canal Map
            const SectionHeader(title: 'Canal Network — Live Map', icon: Icons.map_outlined),
            CanalMapWidget(sections: state.canalSections),
            const SizedBox(height: 16),

            // Simulation Controls
            const SectionHeader(title: 'Simulation Controls', icon: Icons.settings_outlined),
            _SimulationControls(activeScenario: state.activeScenario),
            const SizedBox(height: 20),

            // Canal Section Cards
            const SectionHeader(title: 'Canal Sections — Live Status', icon: Icons.water_outlined),
            ...state.canalSections.asMap().entries.map((e) {
              final report = state.anomalies.isNotEmpty && e.key < state.anomalies.length
                  ? state.anomalies[e.key]
                  : null;
              return _CanalSectionCard(section: e.value, report: report);
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SimulationControls extends StatelessWidget {
  final String activeScenario;
  const _SimulationControls({required this.activeScenario});

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      AppConstants.scenarioNormal,
      AppConstants.scenarioLow,
      AppConstants.scenarioHigh,
      AppConstants.scenarioShortage,
      AppConstants.scenarioEmergency,
    ];

    final colors = {
      AppConstants.scenarioNormal: AppTheme.successColor,
      AppConstants.scenarioLow: AppTheme.warning,
      AppConstants.scenarioHigh: AppTheme.infoColor,
      AppConstants.scenarioShortage: const Color(0xFFE65100),
      AppConstants.scenarioEmergency: AppTheme.danger,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Flow Scenario:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scenarios.map((s) {
                final isActive = activeScenario == s;
                final color = colors[s] ?? AppTheme.primary;
                return GestureDetector(
                  onTap: () => context.read<AppState>().applyScenario(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? color : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: isActive ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (activeScenario != AppConstants.scenarioNormal) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Scenario "$activeScenario" active — agent recommendations updated.',
                  style: TextStyle(fontSize: 11, color: AppTheme.danger, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CanalSectionCard extends StatelessWidget {
  final CanalSectionModel section;
  final CanalAnomalyReport? report;
  const _CanalSectionCard({required this.section, this.report});

  Color get _statusColor {
    switch (section.status) {
      case 'Critical':
        return AppTheme.danger;
      case 'Warning':
        return AppTheme.warning;
      default:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.sectionName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(section.sectionId,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                AppUtils.statusChip(section.status, _statusColor),
              ],
            ),
            const Divider(height: 16),

            // Supply progress bar
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Supply/Demand',
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textMuted)),
                      const Spacer(),
                      Text(
                          '${(section.supplyRatio * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _statusColor)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: section.supplyRatio.clamp(0.0, 1.0),
                        backgroundColor: _statusColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(_statusColor),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 10),

            // Metrics row
            Row(
              children: [
                _MetricItem(
                    label: 'Flow Rate',
                    value: AppUtils.formatFlow(section.flowRate),
                    icon: Icons.waves),
                _MetricItem(
                    label: 'Water Level',
                    value: '${section.waterLevel.toStringAsFixed(1)} m',
                    icon: Icons.height),
                _MetricItem(
                    label: 'Capacity Use',
                    value: AppUtils.formatPercent(section.utilizationPercent),
                    icon: Icons.speed),
                _MetricItem(
                    label: 'Demand',
                    value: '${section.demand.toStringAsFixed(1)} m³/s',
                    icon: Icons.agriculture),
              ],
            ),

            // Flow history sparkline
            const SizedBox(height: 12),
            Text('Flow History (24h)', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            SizedBox(
              height: 60,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: section.flowHistory.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: _statusColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _statusColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Anomaly report
            if (report != null && report!.hasAnomalies) ...[
              const Divider(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 13, color: AppTheme.danger),
                        const SizedBox(width: 5),
                        Text('Agent Anomaly Report',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.danger,
                            )),
                        const Spacer(),
                        AppUtils.statusChip(
                            report!.riskLevel, AppUtils.severityColor(report!.riskLevel)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...report!.anomalies.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(a, style: const TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 4),
                    Text('Recommended: ${report!.recommendedAction}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              )),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
