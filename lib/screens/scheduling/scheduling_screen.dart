import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../models/water_allocation_model.dart';
import '../../widgets/section_header.dart';

class SchedulingScreen extends StatelessWidget {
  const SchedulingScreen({super.key});

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

            // Regenerate button
            Row(
              children: [
                const Expanded(
                  child: SectionHeader(
                    title: 'AI Scheduling Engine',
                    icon: Icons.smart_toy_outlined,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.read<AppState>().regenerateAiAllocations(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Re-run AI'),
                ),
              ],
            ),
            _workflowBanner(context),
            const SizedBox(height: 16),

            // Current Schedule
            const SectionHeader(title: 'Current Schedule', icon: Icons.schedule),
            ...state.currentAllocations.map((a) => _AllocationCard(
                  allocation: a,
                  isAi: false,
                )),
            const SizedBox(height: 20),

            // AI Recommended
            const SectionHeader(
                title: 'AI Recommended Schedule', icon: Icons.psychology_outlined),
            ...state.aiAllocations.map((a) => _AllocationCard(
                  allocation: a,
                  isAi: true,
                )),
          ],
        ),
      ),
    );
  }

  Widget _workflowBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _WorkflowStep(label: 'AI\nRecommendation', active: true),
          Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textMuted),
          _WorkflowStep(label: 'Officer\nReview', active: false),
          Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textMuted),
          _WorkflowStep(label: 'Approval', active: false),
          Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textMuted),
          _WorkflowStep(label: 'Schedule\nUpdate', active: false),
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String label;
  final bool active;
  const _WorkflowStep({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.primary : AppTheme.borderColor,
          ),
          child: Icon(
            active ? Icons.check : Icons.circle_outlined,
            size: 14,
            color: active ? Colors.white : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: active ? AppTheme.primary : AppTheme.textMuted,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            )),
      ],
    );
  }
}

class _AllocationCard extends StatelessWidget {
  final WaterAllocationModel allocation;
  final bool isAi;
  const _AllocationCard({required this.allocation, required this.isAi});

  Color get _reachColor => AppUtils.reachColor(allocation.reachType);

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(allocation.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone + reach
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _reachColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(allocation.zoneName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          AppUtils.statusChip(allocation.reachType, _reachColor),
                          const SizedBox(width: 6),
                          AppUtils.statusChip(allocation.status, statusColor),
                          if (isAi) ...[
                            const SizedBox(width: 6),
                            AppUtils.statusChip('AI', AppTheme.primary),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${allocation.allocationPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppUtils.fairnessColor(allocation.allocationPercent),
                      ),
                    ),
                    Text('fulfilled', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // Metrics
            Row(
              children: [
                _detail('Allocated', '${allocation.allocatedWater.toStringAsFixed(0)} ML'),
                _detail('Required', '${allocation.requiredWater.toStringAsFixed(0)} ML'),
                _detail('Start', allocation.startTime),
                _detail('End', allocation.endTime),
                _detail('Priority', 'P${allocation.priority}'),
              ],
            ),

            // Reason
            if (isAi) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.smart_toy_outlined, size: 12, color: AppTheme.primary),
                      const SizedBox(width: 5),
                      Text('AI Reasoning',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          )),
                    ]),
                    const SizedBox(height: 4),
                    Text(allocation.reason,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],

            // Action buttons for pending AI items
            if (isAi && allocation.status == AppConstants.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.read<AppState>().rejectAllocation(allocation.allocationId),
                      icon: const Icon(Icons.close, size: 14),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AppState>().approveAllocation(allocation.allocationId),
                      icon: const Icon(Icons.check, size: 14),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.approved: return AppTheme.successColor;
      case AppConstants.active: return AppTheme.infoColor;
      case 'Rejected': return AppTheme.danger;
      default: return AppTheme.warning;
    }
  }
}
