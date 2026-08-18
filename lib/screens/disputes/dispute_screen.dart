import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../models/dispute_model.dart';
import '../../agents/dispute_agent.dart';
import '../../widgets/section_header.dart';

class DisputeScreen extends StatelessWidget {
  const DisputeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final disputes = state.disputes;
    final autoDetected = DisputeAgent.detectDisputes(state.farmers);

    final total = disputes.length;
    final open = disputes.where((d) => d.status == AppConstants.open).length;
    final critical = disputes.where((d) => d.severity == AppConstants.critical).length;
    final resolved = disputes.where((d) => d.status == AppConstants.resolved).length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.simulationBadge(),
            const SizedBox(height: 12),

            // Stats Cards
            Row(
              children: [
                _StatCard(label: 'Total', value: '$total', color: AppTheme.primary),
                const SizedBox(width: 8),
                _StatCard(label: 'Open', value: '$open', color: AppTheme.danger),
                const SizedBox(width: 8),
                _StatCard(label: 'Critical', value: '$critical', color: AppTheme.warning),
                const SizedBox(width: 8),
                _StatCard(label: 'Resolved', value: '$resolved', color: AppTheme.successColor),
              ],
            ),
            const SizedBox(height: 16),

            // Auto-detected
            if (autoDetected.isNotEmpty) ...[
              const SectionHeader(
                  title: 'AI Auto-Detected Issues', icon: Icons.psychology_outlined),
              ...autoDetected.map((d) => _AutoDetectedCard(detected: d)),
              const SizedBox(height: 20),
            ],

            // Filed disputes
            const SectionHeader(title: 'Farmer Complaints', icon: Icons.report_outlined),
            ...disputes.map((d) => _DisputeCard(dispute: d)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _AutoDetectedCard extends StatelessWidget {
  final DetectedDispute detected;
  const _AutoDetectedCard({required this.detected});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.severityColor(detected.severity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.smart_toy_outlined, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text('AI Detection: ${detected.type}',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              AppUtils.statusChip(detected.severity, color),
            ]),
            const SizedBox(height: 8),
            Text(detected.description,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Affected: ${detected.affectedZones}',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: detected.supportingData
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(d, style: const TextStyle(fontSize: 10)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text('💡 ${detected.suggestedResolution}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.infoColor, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class _DisputeCard extends StatefulWidget {
  final DisputeModel dispute;
  const _DisputeCard({required this.dispute});

  @override
  State<_DisputeCard> createState() => _DisputeCardState();
}

class _DisputeCardState extends State<_DisputeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    final severityColor = AppUtils.severityColor(d.severity);
    final statusColor = _statusColor(d.status);

    return Card(
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Severity color strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(d.complaintId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(d.region,
                              style: Theme.of(context).textTheme.titleMedium)),
                      AppUtils.statusChip(d.severity, severityColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(d.issue,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(children: [
                    AppUtils.statusChip(d.status, statusColor),
                    const SizedBox(width: 8),
                    AppUtils.statusChip(d.reachType, AppUtils.reachColor(d.reachType)),
                    const Spacer(),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.textMuted,
                    ),
                  ]),

                  if (_expanded) ...[
                    const Divider(height: 20),
                    // Water data
                    Row(
                      children: [
                        _dataChip('Requested',
                            '${d.waterRequested.toStringAsFixed(0)} ML', AppTheme.primary),
                        const SizedBox(width: 8),
                        _dataChip('Received', '${d.waterReceived.toStringAsFixed(0)} ML',
                            AppUtils.fairnessColor(d.fulfillmentPercent)),
                        const SizedBox(width: 8),
                        _dataChip('Fulfillment',
                            '${d.fulfillmentPercent.toStringAsFixed(1)}%',
                            AppUtils.fairnessColor(d.fulfillmentPercent)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _Section(
                      icon: Icons.smart_toy_outlined,
                      title: 'AI Analysis',
                      color: AppTheme.primary,
                      child: Text(d.aiAnalysis,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(height: 10),

                    _Section(
                      icon: Icons.lightbulb_outline,
                      title: 'Suggested Resolution',
                      color: AppTheme.accentGreen,
                      child: Text(d.suggestedResolution,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(height: 10),

                    _Section(
                      icon: Icons.history,
                      title: 'Audit Trail',
                      color: AppTheme.textSecondary,
                      child: Column(
                        children: d.auditTrail
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(fontSize: 11)),
                                      Expanded(
                                          child: Text(t,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textSecondary))),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status actions
                    if (d.status != AppConstants.resolved) ...[
                      Row(
                        children: [
                          if (d.status == AppConstants.open)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<AppState>()
                                    .updateDisputeStatus(
                                        d.complaintId, AppConstants.underReview),
                                child: const Text('Mark Under Review'),
                              ),
                            ),
                          if (d.status == AppConstants.underReview) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<AppState>()
                                    .updateDisputeStatus(
                                        d.complaintId, AppConstants.resolved),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen),
                                child: const Text('Mark Resolved'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.open:
        return AppTheme.danger;
      case AppConstants.underReview:
        return AppTheme.warning;
      case AppConstants.resolved:
        return AppTheme.successColor;
      default:
        return AppTheme.textMuted;
    }
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _Section(
      {required this.icon, required this.title, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(title,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
