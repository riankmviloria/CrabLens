import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import 'crab_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // ==========================================
    // HISTORY ENTRANCE ANIMATION
    // ==========================================
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOAD HISTORY
  // ==========================================
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> historyStrings =
        prefs.getStringList('scan_history') ?? [];

    final List<Map<String, dynamic>> loadedHistory = [];

    for (final item in historyStrings) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map<String, dynamic>) {
          loadedHistory.add(decoded);
        }
      } catch (e) {
        debugPrint('Invalid history item skipped: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _history = loadedHistory.reversed.toList();
    });

    // Restart the entrance animation whenever history
    // is refreshed from Dashboard or pull-to-refresh.
    _animationController
      ..reset()
      ..forward();
  }

  // ==========================================
  // OPEN CRAB DETAIL
  // ==========================================
  void _openCrabDetail({
    required String species,
    required String imagePath,
  }) {
    if (imagePath.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) {
          return CrabDetailScreen(
            speciesName: species,
            imagePath: imagePath,
            confidence: 'From History',
          );
        },
        transitionsBuilder: (
          _,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // EMPTY HISTORY
  // ==========================================
  Widget _buildEmptyState() {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    return Center(
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.75,
            end: 1.0,
          ).animate(animation),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 45,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No history yet',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your crab scans will appear here\n'
                  'after you identify a crab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Start scanning',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HISTORY CARD ANIMATION
  // ==========================================
  Widget _buildAnimatedCard({
    required int index,
    required Map<String, dynamic> item,
  }) {
    final String species =
        item['species']?.toString() ?? 'Unknown Species';

    final String imagePath =
        item['imagePath']?.toString() ?? '';

    final String date =
        item['date']?.toString() ?? '';

    final bool isToxic =
        item['isToxic'] == true;

    // Stagger each card.
    final double start =
        (index * 0.08).clamp(0.0, 0.65);

    final double end =
        (start + 0.35).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: _HistoryCard(
          species: species,
          imagePath: imagePath,
          date: date,
          isToxic: isToxic,
          onTap: () {
            _openCrabDetail(
              species: species,
              imagePath: imagePath,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: loadHistory,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          10,
          14,
          10,
          20,
        ),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return _buildAnimatedCard(
            index: index,
            item: _history[index],
          );
        },
      ),
    );
  }
}

// ============================================================
// HISTORY CARD
// ============================================================

class _HistoryCard extends StatefulWidget {
  final String species;
  final String imagePath;
  final String date;
  final bool isToxic;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.species,
    required this.imagePath,
    required this.date,
    required this.isToxic,
    required this.onTap,
  });

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.025,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final scale = 1.0 - _pressController.value;

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // ==========================================
                // CRAB IMAGE
                // ==========================================
                Hero(
                  tag: 'history_${widget.imagePath}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imagePath.isNotEmpty
                        ? Image.file(
                            File(widget.imagePath),
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                ),

                const SizedBox(width: 13),

                // ==========================================
                // SPECIES INFORMATION
                // ==========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.species,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ==========================================
                // STATUS
                // ==========================================
                _AnimatedStatusIcon(
                  isToxic: widget.isToxic,
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 62,
      height: 62,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 25,
      ),
    );
  }
}

// ============================================================
// ANIMATED STATUS ICON
// ============================================================

class _AnimatedStatusIcon extends StatefulWidget {
  final bool isToxic;

  const _AnimatedStatusIcon({
    required this.isToxic,
  });

  @override
  State<_AnimatedStatusIcon> createState() =>
      _AnimatedStatusIconState();
}

class _AnimatedStatusIconState
    extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: widget.isToxic
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.green.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isToxic
              ? Icons.warning_amber_rounded
              : Icons.check_circle,
          color: widget.isToxic
              ? AppColors.primary
              : Colors.green,
          size: 21,
        ),
      ),
    );
  }
}