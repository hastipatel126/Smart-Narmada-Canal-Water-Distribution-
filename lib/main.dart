import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/landing/landing_screen.dart';

void main() {
  runApp(const NarmadaWaterApp());
}

class NarmadaWaterApp extends StatelessWidget {
  const NarmadaWaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Smart Narmada AI',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const LandingScreen(),
      ),
    );
  }
}
