import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class PredictiveAnalyticsScreen extends StatelessWidget {
  const PredictiveAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kpis = state.kpis;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.simulationBadge(),
            const SizedBox(height: 12),

            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0xFF6A1B9A), const Color(0xFF1565C0)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Predictive Analytics',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text('AI-powered demand forecast & risk analysis',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // Shortage Risk Gauge
            Text('Shortage Risk Assessment',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ShortageRiskCard(kpis: kpis),
            const SizedBox(height: 16),

            // 7-day demand forecast
            Text('7-Day Demand Forecast',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _DemandForecastChart(state: state),
            const SizedBox(height: 16),

            // Zone risk table
            Text('Zone Risk Analysis',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ZoneRiskTable(farmers: state.farmers),
            const SizedBox(height: 16),

            // Tail-end risk
            Text('Tail-End Risk Map',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _TailEndRiskMap(state: state),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shortage Risk Card
// ─────────────────────────────────────────────────────────────────────────────

class _ShortageRiskCard extends StatelessWidget {
  final dynamic kpis;
  const _ShortageRiskCard({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final efficiency = kpis.efficiencyScore as double;
    final fairness = kpis.fairnessScore as double;
    final risk = _computeRisk(efficiency, fairness);
    final color = risk > 70
        ? AppTheme.danger
        : risk > 40
            ? AppTheme.warning
            : AppTheme.successColor;
    final riskLabel = risk > 70 ? 'HIGH' : risk > 40 ? 'MEDIUM' : 'LOW';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: risk / 100,
                    strokeWidth: 10,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Text(
                    '${risk.toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('Risk Level: ',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textSecondary)),
                    Text(riskLabel,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: color)),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    _riskDescription(riskLabel),
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  _riskBar('Efficiency', efficiency, AppTheme.infoColor),
                  const SizedBox(height: 4),
                  _riskBar('Fairness', fairness, AppUtils.fairnessColor(fairness)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _computeRisk(double efficiency, double fairness) {
    return (100 - (efficiency * 0.5 + fairness * 0.5)).clamp(0, 100);
  }

  String _riskDescription(String level) {
    switch (level) {
      case 'HIGH':
        return 'Severe shortage risk. Tail-end crops face immediate yield loss. '
            'Officer intervention required within 24 hours.';
      case 'MEDIUM':
        return 'Moderate shortage risk. Monitor tail-end zones closely. '
            'AI scheduling adjustments recommended.';
      default:
        return 'Low shortage risk. System is operating within acceptable parameters. '
            'Continue standard monitoring.';
    }
  }

  Widget _riskBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demand Forecast Chart (7 days, simulated prediction)
// ─────────────────────────────────────────────────────────────────────────────

class _DemandForecastChart extends StatelessWidget {
  final dynamic state;
  const _DemandForecastChart({required this.state});

  @override
  Widget build(BuildContext context) {
    // Simulate 7-day forecast based on current demand with trend
    final baseDemand = (state.kpis.totalDemand as double);
    final supply = state.kpis.totalWaterAvailable as double;

    final demandData = List.generate(7, (i) {
      final variation = 1.0 + (i * 0.03) + (i % 2 == 0 ? 0.05 : -0.02);
      return baseDemand * variation;
    });
    final supplyData = List.generate(7, (i) {
      final variation = 1.0 - (i * 0.01);
      return supply * variation;
    });

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _legendDot(AppTheme.primary, 'Predicted Demand'),
              const SizedBox(width: 16),
              _legendDot(AppTheme.infoColor, 'Available Supply'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.borderColor, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                            days[v.toInt() % 7],
                            style: const TextStyle(
                                fontSize: 9, color: AppTheme.textMuted)),
                        interval: 1,
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: demandData.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                                  radius: 3,
                                  color: AppTheme.primary,
                                  strokeWidth: 0)),
                      belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary.withValues(alpha: 0.06)),
                    ),
                    LineChartBarData(
                      spots: supplyData.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.infoColor,
                      barWidth: 2.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.infoColor.withValues(alpha: 0.04)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '* Forecast based on current allocation patterns and seasonal trends.',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zone Risk Table
// ─────────────────────────────────────────────────────────────────────────────

class _ZoneRiskTable extends StatelessWidget {
  final List farmers;
  const _ZoneRiskTable({required this.farmers});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: farmers.map<Widget>((f) {
            final ratio = f.allocationRatio as double;
            final riskColor = ratio < 0.5
                ? AppTheme.danger
                : ratio < 0.8
                    ? AppTheme.warning
                    : AppTheme.successColor;
            final riskLabel = ratio < 0.5 ? 'High Risk' : ratio < 0.8 ? 'Medium' : 'Low Risk';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name as String,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(f.zone as String,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: riskColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(riskColor),
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(ratio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: riskColor),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(riskLabel,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: riskColor)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tail-End Risk Map
// ─────────────────────────────────────────────────────────────────────────────

class _TailEndRiskMap extends StatelessWidget {
  final dynamic state;
  const _TailEndRiskMap({required this.state});

  @override
  Widget build(BuildContext context) {
    final tailSections = (state.canalSections as List)
        .where((s) => s.sectionName.toString().contains('Tail'))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tail-end sections are the most vulnerable. Monitor flow rates daily.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ...tailSections.map<Widget>((s) {
              final color = s.status == 'Critical'
                  ? AppTheme.danger
                  : AppTheme.warning;
              final supplyRatio = (s.supplyRatio as double).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.location_on, color: color, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(s.sectionName as String,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      AppUtils.statusChip(s.status as String, color),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _tileKpi(
                          'Flow', '${(s.flowRate as double).toStringAsFixed(1)} m³/s'),
                      _tileKpi('Demand',
                          '${(s.demand as double).toStringAsFixed(1)} m³/s'),
                      _tileKpi('Supply/Demand',
                          '${(supplyRatio * 100).toStringAsFixed(0)}%'),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: supplyRatio,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tileKpi(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
