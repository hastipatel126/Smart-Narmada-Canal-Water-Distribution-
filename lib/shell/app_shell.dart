import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/canal_monitoring/canal_monitoring_screen.dart';
import '../screens/scheduling/scheduling_screen.dart';
import '../screens/farmer/farmer_screen.dart';
import '../screens/disputes/dispute_screen.dart';
import '../screens/officer/officer_screen.dart';
import '../screens/simulation/simulation_screen.dart';
import '../screens/analytics/predictive_analytics_screen.dart';
import '../widgets/ai_chat_fab.dart';
import '../screens/landing/landing_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // Full nav items (admin/officer view)
  static const List<_NavItem> _fullNavItems = [
    _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
    _NavItem(label: 'Canal', icon: Icons.water_outlined, activeIcon: Icons.water),
    _NavItem(label: 'Schedule', icon: Icons.event_note_outlined, activeIcon: Icons.event_note),
    _NavItem(label: 'Farmers', icon: Icons.people_outline, activeIcon: Icons.people),
    _NavItem(label: 'Disputes', icon: Icons.gavel_outlined, activeIcon: Icons.gavel),
    _NavItem(label: 'Officer', icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings),
    _NavItem(label: 'Simulate', icon: Icons.science_outlined, activeIcon: Icons.science),
    _NavItem(label: 'Analytics', icon: Icons.analytics_outlined, activeIcon: Icons.analytics),
  ];

  static const List<Widget> _fullScreens = [
    DashboardScreen(),
    CanalMonitoringScreen(),
    SchedulingScreen(),
    FarmerScreen(),
    DisputeScreen(),
    OfficerScreen(),
    SimulationScreen(),
    PredictiveAnalyticsScreen(),
  ];

  // Farmer-only nav (simplified)
  static const List<_NavItem> _farmerNavItems = [
    _NavItem(label: 'My Water', icon: Icons.water_drop_outlined, activeIcon: Icons.water_drop),
    _NavItem(label: 'Schedule', icon: Icons.event_note_outlined, activeIcon: Icons.event_note),
    _NavItem(label: 'Disputes', icon: Icons.gavel_outlined, activeIcon: Icons.gavel),
  ];

  static const List<Widget> _farmerScreens = [
    FarmerScreen(),
    SchedulingScreen(),
    DisputeScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isFarmer = state.role == AppConstants.roleFarmer;
    final navItems = isFarmer ? _farmerNavItems : _fullNavItems;
    final screens = isFarmer ? _farmerScreens : _fullScreens;
    final unread = state.alerts.where((a) => !a.isRead).length;
    final disputes = state.openDisputeCount;

    // Clamp index when switching roles
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.water_drop, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Smart Narmada AI',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          // Role badge
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.role,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),

          // Alert badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => setState(() => _selectedIndex = 0),
                tooltip: 'Alerts',
              ),
              if (unread > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),

          if (disputes > 0)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.gavel_outlined, color: Colors.white),
                  onPressed: () =>
                      setState(() => _selectedIndex = isFarmer ? 2 : 4),
                  tooltip: 'Disputes',
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.warning,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$disputes',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            onPressed: () {
              context.read<AppState>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
              );
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: navItems.length <= 5
          ? NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              height: 66,
              destinations: navItems
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon, size: 22),
                        selectedIcon: Icon(item.activeIcon,
                            size: 22, color: AppTheme.primary),
                        label: item.label,
                      ))
                  .toList(),
            )
          : _ScrollableBottomNav(
              selectedIndex: safeIndex,
              navItems: navItems,
              onSelected: (i) => setState(() => _selectedIndex = i),
            ),
      floatingActionButton: const AiChatFab(),
    );
  }
}

/// Horizontally scrollable bottom nav for when there are many tabs.
class _ScrollableBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onSelected;

  const _ScrollableBottomNav({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: navItems.length,
        itemBuilder: (_, i) {
          final item = navItems[i];
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
}
