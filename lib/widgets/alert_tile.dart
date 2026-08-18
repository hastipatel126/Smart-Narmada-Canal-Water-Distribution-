import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';
import 'package:intl/intl.dart';

class AlertTile extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertTile({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.severityColor(alert.severity);
    final timeStr = DateFormat('HH:mm').format(alert.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_sourceIcon(alert.source), color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(alert.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: alert.isRead ? AppTheme.textMuted : AppTheme.textPrimary,
                                )),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                    ]),
                    const SizedBox(height: 3),
                    Text(alert.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(children: [
                      AppUtils.statusChip(alert.severity, color),
                      const SizedBox(width: 6),
                      Text(timeStr, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'Canal': return Icons.water_outlined;
      case 'Distribution': return Icons.account_tree_outlined;
      case 'Farmer': return Icons.person_outline;
      case 'Dispute': return Icons.gavel_outlined;
      default: return Icons.info_outline;
    }
  }
}
