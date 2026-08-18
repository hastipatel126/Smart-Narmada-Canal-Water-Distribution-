import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/constants/app_constants.dart';
import '../../shell/app_shell.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _enterApp(String role) {
    context.read<AppState>().setRole(role);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF0277BD),
                  Color(0xFF006064),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // Animated water waves
          AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(_waveController.value),
              size: Size.infinite,
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 80 : 28,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 32),
                            _buildHeroText(),
                            const SizedBox(height: 48),
                            _buildRoleSelector(),
                            const SizedBox(height: 32),
                            _buildEnterButton(),
                            const SizedBox(height: 24),
                            _buildFooterNote(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: const Icon(Icons.water_drop, color: Colors.white, size: 44),
    );
  }

  Widget _buildHeroText() {
    return Column(
      children: [
        const Text(
          'SMART NARMADA AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Every Drop. Fairly Distributed.\nIntelligently Managed.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 20),
        _buildStatRow(),
      ],
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statBadge('10 Farmers', Icons.people_outline),
        const SizedBox(width: 16),
        _statBadge('8 Sections', Icons.water_outlined),
        const SizedBox(width: 16),
        _statBadge('AI Powered', Icons.smart_toy_outlined),
      ],
    );
  }

  Widget _statBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR ROLE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _RoleCard(
              role: AppConstants.roleFarmer,
              icon: Icons.agriculture,
              description: 'View your water status',
              selected: _selectedRole == AppConstants.roleFarmer,
              onTap: () => setState(() => _selectedRole = AppConstants.roleFarmer),
            ),
            const SizedBox(width: 10),
            _RoleCard(
              role: AppConstants.roleOfficer,
              icon: Icons.admin_panel_settings_outlined,
              description: 'Manage distribution',
              selected: _selectedRole == AppConstants.roleOfficer,
              onTap: () => setState(() => _selectedRole = AppConstants.roleOfficer),
            ),
            const SizedBox(width: 10),
            _RoleCard(
              role: AppConstants.roleAdmin,
              icon: Icons.dashboard_outlined,
              description: 'Full system access',
              selected: _selectedRole == AppConstants.roleAdmin,
              onTap: () => setState(() => _selectedRole = AppConstants.roleAdmin),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnterButton() {
    final enabled = _selectedRole != null;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? () => _enterApp(_selectedRole!) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0D47A1),
            disabledBackgroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF0D47A1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 18),
              const SizedBox(width: 8),
              Text(
                enabled ? 'Enter as $_selectedRole' : 'Select a role to continue',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Text(
      'Demo Platform · All data is simulated',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 11,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String role;
  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: selected ? 28 : 24),
              const SizedBox(height: 6),
              Text(
                role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint, progress, 0.6, 40);
    _drawWave(canvas, size, paint, progress + 0.3, 0.7, 30);
    _drawWave(canvas, size, paint, progress + 0.6, 0.55, 50);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double phase,
      double yFactor, double amplitude) {
    final path = Path();
    final y = size.height * yFactor;
    path.moveTo(0, y);
    for (double x = 0; x <= size.width; x++) {
      final wave = amplitude * sin((x / size.width * 2 * pi) + (phase * 2 * pi));
      path.lineTo(x, y + wave);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}
