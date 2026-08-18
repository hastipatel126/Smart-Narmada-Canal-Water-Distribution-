import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../agents/dashboard_agent.dart';
import '../../models/fairness_report.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/fairness_gauge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/reach_comparison_bar.dart';
import '../../widgets/alert_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kpis = state.kpis;
    final explanation = DashboardAgent.explainFairnessScore(kpis.fairnessReport);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.simulationBadge(),
            const SizedBox(height: 12),

            // Hero KPI header
            _HeroHeader(kpis: kpis),
            const SizedBox(height: 16),

            // KPI Grid
            const SectionHeader(title: 'System Overview', icon: Icons.dashboard_outlined),
            _KpiGrid(kpis: kpis),
            const SizedBox(height: 20),

            // Fairness Score
            const SectionHeader(title: 'Water Distribution Fairness', icon: Icons.balance),
            _FairnessSection(kpis: kpis, explanation: explanation),
            const SizedBox(height: 20),

            // Flow sparkline
            const SectionHeader(title: 'Canal Flow (24h Trend)', icon: Icons.show_chart),
            _FlowSparklineCard(sections: state.canalSections.take(4).toList()),
            const SizedBox(height: 20),

            // Head vs Tail Comparison
            const SectionHeader(title: 'Head → Mid → Tail Equity', icon: Icons.compare_arrows),
            _ReachComparisonSection(fairnessReport: kpis.fairnessReport),
            const SizedBox(height: 20),

            // AI Insights
            const SectionHeader(title: 'AI Insights', icon: Icons.psychology_outlined),
            _AiInsightsPanel(state: state),
            const SizedBox(height: 20),

            // Quick Actions
            const SectionHeader(title: 'Quick Actions', icon: Icons.bolt_outlined),
            _QuickActions(state: state),
            const SizedBox(height: 20),

            // Active Alerts
            const SectionHeader(title: 'Active Alerts', icon: Icons.notifications_outlined),
            _AlertsSection(alerts: state.alerts.take(5).toList()),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final DashboardKPIs kpis;
  const _HeroHeader({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Smart Narmada AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 0.5)),
                Text('Command Center',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${kpis.fairnessScore.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              Text('Fairness / 100',
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Grid
// ─────────────────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final DashboardKPIs kpis;
  const _KpiGrid({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: KpiCard(
              title: 'Total Water Available',
              value: AppUtils.formatVolume(kpis.totalWaterAvailable),
              icon: Icons.water,
              color: AppTheme.infoColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KpiCard(
              title: 'Total Demand',
              value: AppUtils.formatVolume(kpis.totalDemand),
              icon: Icons.agriculture,
              color: AppTheme.primary,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: KpiCard(
              title: 'Water Distributed',
              value: AppUtils.formatVolume(kpis.waterDistributed),
              icon: Icons.waves,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KpiCard(
              title: 'Water Remaining',
              value: AppUtils.formatVolume(kpis.waterRemaining),
              icon: Icons.water_drop_outlined,
              color: AppTheme.accent,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: KpiCard(
              title: 'Efficiency Score',
              value: '${kpis.efficiencyScore.toStringAsFixed(1)}%',
              icon: Icons.speed,
              color: AppUtils.fairnessColor(kpis.efficiencyScore),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KpiCard(
              title: 'Active Alerts',
              value: kpis.activeAlerts.toString(),
              icon: Icons.warning_amber_outlined,
              color: kpis.activeAlerts > 3 ? AppTheme.danger : AppTheme.warning,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: KpiCard(
              title: 'Open Disputes',
              value: kpis.activeDisputes.toString(),
              icon: Icons.gavel_outlined,
              color: kpis.activeDisputes > 1 ? AppTheme.danger : AppTheme.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KpiCard(
              title: 'Critical Sections',
              value: kpis.anomalySections.toString(),
              icon: Icons.location_on_outlined,
              color: kpis.anomalySections > 2 ? AppTheme.danger : AppTheme.warning,
            ),
          ),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flow Sparkline Card
// ─────────────────────────────────────────────────────────────────────────────

class _FlowSparklineCard extends StatelessWidget {
  final List sections;
  const _FlowSparklineCard({required this.sections});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final colors = [
      AppTheme.infoColor,
      AppTheme.accentGreen,
      AppTheme.warning,
      AppTheme.danger,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: sections.asMap().entries.map((e) {
                    final s = e.value;
                    final c = colors[e.key % colors.length];
                    return LineChartBarData(
                      spots: (s.flowHistory as List<double>).asMap().entries
                          .map((ep) => FlSpot(ep.key.toDouble(), ep.value))
                          .toList(),
                      isCurved: true,
                      color: c,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: c.withValues(alpha: 0.04)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: sections.asMap().entries.map((e) {
                final c = colors[e.key % colors.length];
                final name = (e.value.sectionName as String)
                    .replaceAll('Head Reach – ', 'H:')
                    .replaceAll('Mid Reach – ', 'M:')
                    .replaceAll('Tail End – ', 'T:');
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 3,
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(name, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Insights Panel
// ─────────────────────────────────────────────────────────────────────────────

class _AiInsightsPanel extends StatelessWidget {
  final AppState state;
  const _AiInsightsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final kpis = state.kpis;
    final report = kpis.fairnessReport;
    final tailEnd = report.tailEndAllocationPercent;
    final headEnd = report.headReachAllocationPercent;

    final insights = [
      _Insight(
        icon: Icons.water_drop,
        color: AppTheme.infoColor,
        title: 'Water Efficiency',
        body: 'System is distributing ${kpis.efficiencyScore.toStringAsFixed(1)}% of total demand. '
            '${kpis.efficiencyScore < 70 ? "Below optimal — demand exceeds supply." : "Acceptable efficiency level."}',
      ),
      _Insight(
        icon: Icons.balance,
        color: tailEnd < 50 ? AppTheme.danger : AppTheme.warning,
        title: 'Equity Gap',
        body: 'Head-reach zones receive ${headEnd.toStringAsFixed(0)}% vs tail-end only '
            '${tailEnd.toStringAsFixed(0)}%. Gap of ${(headEnd - tailEnd).toStringAsFixed(0)}% indicates '
            '${tailEnd < 50 ? "critical inequity requiring immediate action." : "moderate imbalance."}',
      ),
      _Insight(
        icon: Icons.warning_amber,
        color: AppTheme.warning,
        title: 'Alert Priority',
        body: '${kpis.activeAlerts} unread alert(s) in queue. '
            '${state.alerts.where((a) => a.severity == 'Critical').length} critical item(s) require officer attention.',
      ),
      _Insight(
        icon: Icons.schedule,
        color: AppTheme.accentGreen,
        title: 'AI Scheduling',
        body: '${state.aiAllocations.where((a) => a.status == "Pending").length} allocation recommendations pending approval. '
            'Review and approve to improve tail-end fulfillment.',
      ),
    ];

    return Column(
      children: insights.map((ins) => _InsightCard(insight: ins)).toList(),
    );
  }
}

class _Insight {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Insight({required this.icon, required this.color, required this.title, required this.body});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(insight.icon, color: insight.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text(insight.body,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final AppState state;
  const _QuickActions({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickActionBtn(
              label: 'Re-run AI',
              icon: Icons.refresh,
              color: AppTheme.primary,
              onTap: () => context.read<AppState>().regenerateAiAllocations(),
            ),
            _QuickActionBtn(
              label: 'Mark Alerts Read',
              icon: Icons.done_all,
              color: AppTheme.accentGreen,
              onTap: () {
                for (final a in context.read<AppState>().alerts) {
                  context.read<AppState>().markAlertRead(a.alertId);
                }
              },
            ),
            _QuickActionBtn(
              label: 'Reset Scenario',
              icon: Icons.restore,
              color: AppTheme.warning,
              onTap: () => context.read<AppState>().applyScenario('Normal Flow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn(
      {required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fairness Section (unchanged logic, upgraded styling)
// ─────────────────────────────────────────────────────────────────────────────

class _FairnessSection extends StatelessWidget {
  final DashboardKPIs kpis;
  final AIExplanation explanation;
  const _FairnessSection({required this.kpis, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FairnessGauge(score: kpis.fairnessScore),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Distribution Fairness Score',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${kpis.fairnessScore.toStringAsFixed(0)} / 100',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppUtils.fairnessColor(kpis.fairnessScore),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            kpis.fairnessReport.trend == 'Improving'
                                ? Icons.trending_up
                                : kpis.fairnessReport.trend == 'Declining'
                                    ? Icons.trending_down
                                    : Icons.trending_flat,
                            size: 16,
                            color: kpis.fairnessReport.trend == 'Improving'
                                ? AppTheme.successColor
                                : AppTheme.danger,
                          ),
                          const SizedBox(width: 4),
                          Text(kpis.fairnessReport.trend,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _aiExplanationPanel(context, explanation),
          ],
        ),
      ),
    );
  }

  Widget _aiExplanationPanel(BuildContext context, AIExplanation exp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text('AI Explanation',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          _expRow(context, '📌 What Happened', exp.whatHappened),
          _expRow(context, '🔍 Why Detected', exp.whyDetected),
          _expRow(context, '💡 Recommendation', exp.recommendation),
          _expRow(context, '⚠ Consequence', exp.consequence),
        ],
      ),
    );
  }

  Widget _expRow(BuildContext context, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reach Comparison
// ─────────────────────────────────────────────────────────────────────────────

class _ReachComparisonSection extends StatelessWidget {
  final FairnessReport fairnessReport;
  const _ReachComparisonSection({required this.fairnessReport});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ReachComparisonBar(
              label: 'Head-Reach',
              percent: fairnessReport.headReachAllocationPercent,
              color: AppTheme.headReachColor,
            ),
            const SizedBox(height: 10),
            ReachComparisonBar(
              label: 'Mid-Reach',
              percent: fairnessReport.midReachAllocationPercent,
              color: AppTheme.midReachColor,
            ),
            const SizedBox(height: 10),
            ReachComparisonBar(
              label: 'Tail-End',
              percent: fairnessReport.tailEndAllocationPercent,
              color: AppTheme.tailEndColor,
            ),
            const SizedBox(height: 12),
            Text(
              fairnessReport.explanation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alerts Section
// ─────────────────────────────────────────────────────────────────────────────

class _AlertsSection extends StatelessWidget {
  final List alerts;
  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No active alerts.'),
        ),
      );
    }
    return Column(
      children: alerts.map<Widget>((a) => AlertTile(alert: a)).toList(),
    );
  }
}
