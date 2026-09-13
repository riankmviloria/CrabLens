import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CrabLensApp());
}

class CrabLensApp extends StatelessWidget {
  const CrabLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrabLens AI',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColors.primary,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),

        useMaterial3: true,

        scaffoldBackgroundColor:
            AppColors.background,
      ),

      home: const SplashScreen(),
    );
  }
}