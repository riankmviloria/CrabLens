import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'about_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final GlobalKey<HistoryScreenState> _historyKey =
      GlobalKey<HistoryScreenState>();

  final GlobalKey<HomeScreenState> _homeKey =
      GlobalKey<HomeScreenState>();

  // ============================================================
  // APP BAR ANIMATION
  // ============================================================

  late final AnimationController _appBarController;

  late final Animation<double> _appBarFade;
  late final Animation<Offset> _appBarSlide;

  // ============================================================
  // PAGE TRANSITION ANIMATION
  // ============================================================

  late AnimationController _pageController;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // APP BAR
    // ==========================================================

    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _appBarFade = CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeOut,
    );

    _appBarSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _appBarController,
        curve: Curves.easeOutCubic,
      ),
    );

    _appBarController.forward();

    // ==========================================================
    // PAGE TRANSITION
    // ==========================================================

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _pageFade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _pageSlide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pageController.value = 1.0;
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // ABOUT SCREEN
  // ============================================================

  void _openAboutScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 500),
        reverseTransitionDuration:
            const Duration(milliseconds: 350),
        pageBuilder: (
          _,
          animation,
          secondaryAnimation,
        ) {
          return const AboutScreen();
        },
        transitionsBuilder: (
          _,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curvedAnimation =
              CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TAB CHANGE
  // ============================================================

  void _onTabChanged(int index) {
    if (_currentIndex == index) {
      if (index == 1) {
        _historyKey.currentState?.loadHistory();
      }

      if (index == 0) {
        _homeKey.currentState?.loadRecentScans();
      }

      return;
    }

    _previousIndex = _currentIndex;

    setState(() {
      _currentIndex = index;
    });

    // ==========================================================
    // DIRECTION
    // ==========================================================

    final bool movingForward = index > _previousIndex;

    _pageSlide = Tween<Offset>(
      begin: Offset(
        movingForward ? 0.10 : -0.10,
        0,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ==========================================================
    // PLAY PAGE ANIMATION
    // ==========================================================

    _pageController
      ..reset()
      ..forward();

    // ==========================================================
    // REFRESH DATA
    // ==========================================================

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!mounted) return;

        if (index == 1) {
          _historyKey.currentState?.loadHistory();
        }

        if (index == 0) {
          _homeKey.currentState?.loadRecentScans();
        }
      },
    );
  }

  // ============================================================
  // CURRENT PAGE
  // ============================================================

  Widget _buildCurrentPage() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        HomeScreen(key: _homeKey),
        HistoryScreen(key: _historyKey),
      ],
    );
  }

  // ============================================================
  // ANIMATED NAV ICON
  // ============================================================

  Widget _buildNavIcon({
    required IconData icon,
    required IconData activeIcon,
    required bool selected,
  }) {
    return AnimatedScale(
      scale: selected ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        transitionBuilder: (
          child,
          animation,
        ) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          selected ? activeIcon : icon,
          key: ValueKey(selected),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,

        title: FadeTransition(
          opacity: _appBarFade,
          child: SlideTransition(
            position: _appBarSlide,
            child: const Text(
              'CrabLens',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),

        // ======================================================
        // ABOUT BUTTON
        // ======================================================

        actions: [
          FadeTransition(
            opacity: _appBarFade,
            child: ScaleTransition(
              scale: _appBarFade,
              child: IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                tooltip: 'About CrabLens',
                onPressed: _openAboutScreen,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // MAIN CONTENT
      // ========================================================

      body: ClipRect(
        child: FadeTransition(
          opacity: _pageFade,
          child: SlideTransition(
            position: _pageSlide,
            child: _buildCurrentPage(),
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: _currentIndex,

        selectedItemColor:
            AppColors.primary,

        unselectedItemColor:
            Colors.grey.shade500,

        type:
            BottomNavigationBarType.fixed,

        onTap: _onTabChanged,

        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              icon:
                  Icons.dashboard_outlined,
              activeIcon:
                  Icons.dashboard,
              selected:
                  _currentIndex == 0,
            ),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            icon: _buildNavIcon(
              icon:
                  Icons.history_outlined,
              activeIcon:
                  Icons.history,
              selected:
                  _currentIndex == 1,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}