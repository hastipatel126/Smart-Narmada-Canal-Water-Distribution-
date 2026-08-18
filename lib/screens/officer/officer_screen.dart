import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../models/farmer_model.dart';
import '../../models/water_allocation_model.dart';
import '../../widgets/section_header.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/alert_tile.dart';

class OfficerScreen extends StatelessWidget {
  const OfficerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kpis = state.kpis;
    final pendingCount = state.aiAllocations
        .where((a) => a.status == AppConstants.pending)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.simulationBadge(),
            const SizedBox(height: 12),

            // Header banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Officer Command Centre',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    Text('${state.role} view  ·  ${state.activeScenario}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
                  ]),
                ),
                if (pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$pendingCount Pending',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
            const SizedBox(height: 16),

            // Quick stats row
            Row(children: [
              Expanded(
                child: KpiCard(
                  title: 'Pending Approvals',
                  value: pendingCount.toString(),
                  icon: Icons.pending_actions,
                  color: AppTheme.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Open Disputes',
                  value: state.openDisputeCount.toString(),
                  icon: Icons.gavel_outlined,
                  color: AppTheme.danger,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: KpiCard(
                  title: 'Fairness Score',
                  value: '${kpis.fairnessScore.toStringAsFixed(0)}/100',
                  icon: Icons.balance,
                  color: AppUtils.fairnessColor(kpis.fairnessScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Efficiency',
                  value: '${kpis.efficiencyScore.toStringAsFixed(1)}%',
                  icon: Icons.speed,
                  color: AppUtils.fairnessColor(kpis.efficiencyScore),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Pending AI Allocations
            const SectionHeader(
                title: 'Pending AI Schedule Approvals', icon: Icons.psychology_outlined),
            _PendingAllocationsSection(allocations: state.aiAllocations),
            const SizedBox(height: 20),

            // Farmer Summary
            const SectionHeader(title: 'Farmer Water Summary', icon: Icons.people_outline),
            _FarmerSummaryTable(farmers: state.farmers),
            const SizedBox(height: 20),

            // Latest Alerts
            const SectionHeader(title: 'Latest Alerts', icon: Icons.notifications_outlined),
            ...state.alerts.take(4).map((a) => AlertTile(
                  alert: a,
                  onTap: () => context.read<AppState>().markAlertRead(a.alertId),
                )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _PendingAllocationsSection extends StatelessWidget {
  final List<WaterAllocationModel> allocations;
  const _PendingAllocationsSection({required this.allocations});

  @override
  Widget build(BuildContext context) {
    final pending = allocations.where((a) => a.status == AppConstants.pending).toList();
    if (pending.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: const [
            Icon(Icons.check_circle_outline, color: AppTheme.successColor),
            SizedBox(width: 10),
            Text('All AI recommendations have been reviewed.'),
          ]),
        ),
      );
    }
    return Column(
      children: pending.map((a) => _PendingAllocationTile(allocation: a)).toList(),
    );
  }
}

class _PendingAllocationTile extends StatelessWidget {
  final WaterAllocationModel allocation;
  const _PendingAllocationTile({required this.allocation});

  @override
  Widget build(BuildContext context) {
    final reachColor = AppUtils.reachColor(allocation.reachType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(allocation.zoneName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(children: [
                      AppUtils.statusChip(allocation.reachType, reachColor),
                      const SizedBox(width: 6),
                      Text(
                        '${allocation.allocatedWater.toStringAsFixed(0)} ML | ${allocation.startTime}–${allocation.endTime}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${allocation.allocationPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppUtils.fairnessColor(allocation.allocationPercent),
                    ),
                  ),
                  Text('fulfillment', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ]),
            const SizedBox(height: 6),
            Text(allocation.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<AppState>().rejectAllocation(allocation.allocationId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<AppState>().approveAllocation(allocation.allocationId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _FarmerSummaryTable extends StatelessWidget {
  final List<FarmerModel> farmers;
  const _FarmerSummaryTable({required this.farmers});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1.8),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              children: const [
                _TH('Farmer / Village'),
                _TH('Reach'),
                _TH('Required'),
                _TH('Received'),
                _TH('Ratio'),
              ],
            ),
            ...farmers.map((f) => TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  children: [
                    _TD(Text('${f.name}\n${f.village}',
                        style: const TextStyle(fontSize: 11))),
                    _TD(Text(f.reachType,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppUtils.reachColor(f.reachType),
                          fontWeight: FontWeight.w600,
                        ))),
                    _TD(Text('${f.waterRequired.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11))),
                    _TD(Text('${f.waterReceived.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: f.hasShortage
                              ? AppTheme.danger
                              : AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ))),
                    _TD(Text('${(f.allocationRatio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppUtils.fairnessColor(f.allocationRatio * 100),
                          fontWeight: FontWeight.bold,
                        ))),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          )),
    );
  }
}

class _TD extends StatelessWidget {
  final Widget child;
  const _TD(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: child,
    );
  }
}
