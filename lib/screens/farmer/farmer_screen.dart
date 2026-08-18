import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../models/farmer_model.dart';
import '../../agents/farmer_alert_agent.dart';
import '../../widgets/section_header.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  FarmerModel? _selectedFarmer;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final farmers = state.farmers;
    final isGu = state.language == AppConstants.gujarati;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: _selectedFarmer == null
          ? _FarmerListView(
              farmers: farmers,
              isGu: isGu,
              onToggleLanguage: () => context.read<AppState>().toggleLanguage(),
              onSelect: (f) => setState(() => _selectedFarmer = f),
            )
          : _FarmerDetailView(
              farmer: _selectedFarmer!,
              isGu: isGu,
              onBack: () => setState(() => _selectedFarmer = null),
              onToggleLanguage: () => context.read<AppState>().toggleLanguage(),
            ),
    );
  }
}

class _FarmerListView extends StatelessWidget {
  final List<FarmerModel> farmers;
  final bool isGu;
  final VoidCallback onToggleLanguage;
  final void Function(FarmerModel) onSelect;

  const _FarmerListView({
    required this.farmers,
    required this.isGu,
    required this.onToggleLanguage,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppUtils.simulationBadge(),
          const SizedBox(height: 8),

          // Language toggle
          Row(
            children: [
              const Expanded(
                child: SectionHeader(title: 'Farmer Water Status', icon: Icons.person_outline),
              ),
              _LangToggle(isGu: isGu, onToggle: onToggleLanguage),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            isGu ? 'ખેડૂત પસંદ કરો:' : 'Select a farmer to view water status:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Farmer cards
          ...farmers.map((f) => _FarmerListTile(
                farmer: f,
                isGu: isGu,
                onTap: () => onSelect(f),
              )),
        ],
      ),
    );
  }
}

class _FarmerListTile extends StatelessWidget {
  final FarmerModel farmer;
  final bool isGu;
  final VoidCallback onTap;

  const _FarmerListTile({required this.farmer, required this.isGu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reachColor = AppUtils.reachColor(farmer.reachType);
    final fulfillColor = AppUtils.fairnessColor(farmer.allocationRatio * 100);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: reachColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: reachColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(farmer.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      isGu
                          ? '${farmer.village} | ઝોન: ${farmer.zone}'
                          : '${farmer.village} | Zone: ${farmer.zone}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AppUtils.statusChip(farmer.reachType, reachColor),
                        const SizedBox(width: 6),
                        if (farmer.hasShortage)
                          AppUtils.statusChip(
                              isGu ? 'અછત' : 'Shortage', AppTheme.danger),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(farmer.allocationRatio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: fulfillColor,
                    ),
                  ),
                  Text(
                    isGu ? 'પ્રાપ્ત' : 'received',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerDetailView extends StatelessWidget {
  final FarmerModel farmer;
  final bool isGu;
  final VoidCallback onBack;
  final VoidCallback onToggleLanguage;

  const _FarmerDetailView({
    required this.farmer,
    required this.isGu,
    required this.onBack,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final status = FarmerAlertAgent.getWaterStatus(farmer);
    final reachColor = AppUtils.reachColor(farmer.reachType);
    final fulfillColor = AppUtils.fairnessColor(status.allocationPercent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back & language
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              Expanded(
                child: Text(
                  isGu ? 'ખેડૂત માહિતી' : 'Farmer Details',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              _LangToggle(isGu: isGu, onToggle: onToggleLanguage),
            ],
          ),
          const SizedBox(height: 8),

          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: reachColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: reachColor, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGu ? 'સ્વાગત, ${farmer.name}' : 'Welcome, ${farmer.name}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '${farmer.village} | ${farmer.zone}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          AppUtils.statusChip(farmer.reachType, reachColor),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Status message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fulfillColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: fulfillColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isGu ? status.statusGu : status.statusEn,
                      style: TextStyle(
                        fontSize: 13,
                        color: fulfillColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Water info cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: isGu ? 'ઉપલબ્ધ પાણી' : 'Water Available',
                  value: '${farmer.waterReceived.toStringAsFixed(0)} ML',
                  icon: Icons.water_drop,
                  color: AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: isGu ? 'જરૂરી પાણી' : 'Water Required',
                  value: '${farmer.waterRequired.toStringAsFixed(0)} ML',
                  icon: Icons.agriculture,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: isGu ? 'ફાળવણી' : 'Allocation',
                  value: '${status.allocationPercent.toStringAsFixed(1)}%',
                  icon: Icons.pie_chart_outline,
                  color: fulfillColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: isGu ? 'પ્રાથમિકતા' : 'Priority',
                  value: 'P${farmer.priority}',
                  icon: Icons.star_outline,
                  color: farmer.priority == 1 ? AppTheme.danger : AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.schedule, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      isGu ? 'સિંચાઈ સમય' : 'Irrigation Schedule',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _scheduleRow(
                    context,
                    isGu ? 'સ્થિતિ' : 'Status',
                    farmer.scheduledTime == 'Not Scheduled'
                        ? (isGu ? 'સ્થગિત' : 'Not Scheduled')
                        : farmer.scheduledTime,
                    farmer.scheduledTime == 'Not Scheduled'
                        ? AppTheme.danger
                        : AppTheme.successColor,
                  ),
                  _scheduleRow(
                    context,
                    isGu ? 'અપેક્ષિત આગમન' : 'Expected Arrival',
                    isGu ? status.irrigationStartGu : status.irrigationStartEn,
                    AppTheme.infoColor,
                  ),
                  _scheduleRow(
                    context,
                    isGu ? 'કેનાલ વિભાગ' : 'Canal Section',
                    farmer.canalSection,
                    AppTheme.textSecondary,
                  ),
                  _scheduleRow(
                    context,
                    isGu ? 'પાક' : 'Crop',
                    farmer.crop,
                    AppTheme.accentGreen,
                  ),
                  _scheduleRow(
                    context,
                    isGu ? 'જમીન ક્ષેત્ર' : 'Land Area',
                    '${farmer.landArea} ha',
                    AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Shortage alert
          if (farmer.hasShortage) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppTheme.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isGu
                          ? 'ચેતવણી: ${farmer.shortageAmount.toStringAsFixed(0)} ML ની ઉણપ. '
                              'AI ઉપચારાત્મક ફાળવણી ભલામણ કરી છે.'
                          : 'Shortage Alert: ${farmer.shortageAmount.toStringAsFixed(0)} ML deficit. '
                              'AI has generated a compensatory allocation recommendation.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Report problem
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showReportDialog(context, isGu),
              icon: const Icon(Icons.report_problem_outlined, size: 16),
              label: Text(isGu ? 'સમસ્યા નોંધાવો' : 'Report a Problem'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow(BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, bool isGu) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isGu ? 'સમસ્યા નોંધો' : 'Report Problem'),
        content: Text(
          isGu
              ? 'તમારી ફરિયાદ નોંધાઈ ગઈ છે. '
                  'સિંચાઈ અધિકારી ૨૪ કલાકમાં સંપર્ક કરશે.'
              : 'Your complaint has been registered. '
                  'An irrigation officer will contact you within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isGu ? 'બરાબર' : 'OK'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final bool isGu;
  final VoidCallback onToggle;
  const _LangToggle({required this.isGu, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          isGu ? 'EN' : 'ગુ',
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
