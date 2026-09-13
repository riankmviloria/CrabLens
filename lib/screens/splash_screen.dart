import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  late Animation<double> _iconScale;
  late Animation<double> _iconFade;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _subtitleFade;

  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // ANIMATION CONTROLLER
    // ==========================================================

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    );

    // ==========================================================
    // APP ICON
    // ==========================================================

    _iconScale = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.45,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _iconFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.30,
        curve: Curves.easeOut,
      ),
    );

    // ==========================================================
    // TITLE
    // ==========================================================

    _titleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.25,
        0.60,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(
        0,
        0.25,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.25,
          0.65,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ==========================================================
    // SUBTITLE
    // ==========================================================

    _subtitleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.45,
        0.75,
        curve: Curves.easeOut,
      ),
    );

    // ==========================================================
    // LOADER
    // ==========================================================

    _loaderFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.60,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    // ==========================================================
    // START ANIMATION
    // ==========================================================

    _animationController.forward();

    // ==========================================================
    // GO TO DASHBOARD
    // ==========================================================

    Future.delayed(
      const Duration(
        milliseconds: 2500,
      ),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardPage(),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // ==================================================
              // APP ICON
              // ==================================================

              FadeTransition(
                opacity: _iconFade,
                child: ScaleTransition(
                  scale: _iconScale,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                        return const Icon(
                          Icons.broken_image,
                          size: 110,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // APP NAME
              // ==================================================

              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    'CrabLens',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // SUBTITLE
              // ==================================================

              FadeTransition(
                opacity: _subtitleFade,
                child: const Text(
                  'AI-Powered Crab Identification',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 42),

              // ==================================================
              // LOADING INDICATOR
              // ==================================================

              FadeTransition(
                opacity: _loaderFade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 3,
                        color:
                            AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Initializing CrabLens...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}