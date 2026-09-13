import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.25,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.25,
          curve: Curves.easeOut,
        ),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.12,
          0.38,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _titleFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.12,
          0.38,
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedSection({
    required Widget child,
    required int index,
  }) {
    final start = 0.20 + (index * 0.07);
    final end = (start + 0.22).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
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
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const teamMembers = [
      'Eli Edon',
      'Anthony Eglesias',
      'Hero Elayda',
      'Cresza Joy Mojar',
      'Jhapil Taneo',
    ];

    // Species generally considered edible.
    const edibleSpecies = [
      'Alimango',
      'Alimasag',
      'Purple Mud Crab',
      'Three-Spot Crab',
      'Spanner Crab',
      'Mangrove Crab',
      'Orange Mud Crab',
      'Crucifix Crab',
    ];

    // Species that should not be presented as safe to eat.
    // The wording intentionally uses "Potentially Toxic" rather than
    // claiming that every species is definitively poisonous.
    const toxicSpecies = [
      'Devil Crab',
      'Mosaic Crab',
      'Floral Egg Crab',
      'Xanthid Crab',
      'Seven Eleven Crab',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About CrabLens'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ─────────────────────────────────────────────
              // APP LOGO
              // ─────────────────────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─────────────────────────────────────────────
              // TITLE
              // ─────────────────────────────────────────────
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    children: [
                      const Text(
                        'CrabLens',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'AI-Powered Crab Identification',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────────────────────
              // ABOUT THE APP
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 0,
                child: _sectionCard(
                  icon: Icons.info_outline,
                  title: 'About the App',
                  child: const Text(
                    'CrabLens is an AI-powered mobile application designed '
                    'to help users identify different crab species through '
                    'image recognition. Simply capture or upload an image '
                    'of a crab and CrabLens analyzes its visual features '
                    'using a TensorFlow Lite machine learning model.',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // AI TECHNOLOGY
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 1,
                child: _sectionCard(
                  icon: Icons.psychology_outlined,
                  title: 'AI Technology',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CrabLens uses an on-device TensorFlow Lite '
                        'classification model trained to recognize crab '
                        'species based on their visual characteristics.',
                      ),
                      const SizedBox(height: 14),
                      const _InfoRow(
                        icon: Icons.memory_outlined,
                        label: 'Technology',
                        value: 'TensorFlow Lite',
                      ),
                      const _InfoRow(
                        icon: Icons.smartphone_outlined,
                        label: 'Processing',
                        value: 'On-device AI',
                      ),
                      const _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Species',
                        value: '13 supported species',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // SUPPORTED SPECIES
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 2,
                child: _sectionCard(
                  icon: Icons.science_outlined,
                  title: 'Supported Species',
                  subtitle: 'Species currently recognized by CrabLens',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─────────────────────────────────
                      // EDIBLE SPECIES
                      // ─────────────────────────────────
                      _SpeciesCategoryHeader(
                        icon: Icons.restaurant_outlined,
                        title: 'Edible Species',
                        subtitle:
                            'Generally considered suitable for consumption',
                        color: Colors.green.shade700,
                        backgroundColor: Colors.green.shade50,
                      ),

                      const SizedBox(height: 12),

                      for (int i = 0; i < edibleSpecies.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == edibleSpecies.length - 1
                                ? 20
                                : 10,
                          ),
                          child: _SpeciesItem(
                            number: i + 1,
                            name: edibleSpecies[i],
                            isEdible: true,
                          ),
                        ),

                      // ─────────────────────────────────
                      // NOT EDIBLE / POTENTIALLY TOXIC
                      // ─────────────────────────────────
                      _SpeciesCategoryHeader(
                        icon: Icons.warning_amber_rounded,
                        title: 'Not Edible / Potentially Toxic',
                        subtitle:
                            'Do not consume based on AI identification alone',
                        color: Colors.red.shade700,
                        backgroundColor: Colors.red.shade50,
                      ),

                      const SizedBox(height: 12),

                      for (int i = 0; i < toxicSpecies.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == toxicSpecies.length - 1
                                ? 0
                                : 10,
                          ),
                          child: _SpeciesItem(
                            number: i + 1,
                            name: toxicSpecies[i],
                            isEdible: false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // SAFETY DISCLAIMER
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safety Disclaimer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'CrabLens is intended for educational and '
                              'identification purposes only. AI predictions '
                              'should not be treated as a definitive '
                              'identification or safety guarantee.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // PROJECT INFORMATION
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 4,
                child: _sectionCard(
                  icon: Icons.school_outlined,
                  title: 'Project Information',
                  child: const Column(
                    children: [
                      _InfoRow(
                        icon: Icons.school_outlined,
                        label: 'Project Type',
                        value: 'Student Thesis Project',
                      ),
                      _InfoRow(
                        icon: Icons.smartphone_outlined,
                        label: 'Platform',
                        value: 'Flutter',
                      ),
                      _InfoRow(
                        icon: Icons.auto_awesome_outlined,
                        label: 'Core Feature',
                        value: 'AI Crab Identification',
                      ),
                      _InfoRow(
                        icon: Icons.memory_outlined,
                        label: 'AI Model',
                        value: 'TensorFlow Lite',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────
              // PROJECT TEAM
              // ─────────────────────────────────────────────
              _animatedSection(
                index: 5,
                child: _sectionCard(
                  icon: Icons.groups_outlined,
                  title: 'Project Team',
                  subtitle: 'The students behind CrabLens',
                  child: Column(
                    children: [
                      for (int i = 0; i < teamMembers.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == teamMembers.length - 1
                                ? 0
                                : 12,
                          ),
                          child: _TeamMemberItem(
                            index: i,
                            name: teamMembers[i],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────────────────────
              // FOOTER
              // ─────────────────────────────────────────────
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(
                    0.72,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.biotech_outlined,
                      color: AppColors.primary.withValues(alpha: 0.6),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Designed, developed, and researched\n'
                      'as a student project.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2026 CrabLens',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION CARD
  // ─────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPECIES CATEGORY HEADER
// ─────────────────────────────────────────────

class _SpeciesCategoryHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color backgroundColor;

  const _SpeciesCategoryHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: color.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPECIES ITEM
// ─────────────────────────────────────────────

class _SpeciesItem extends StatelessWidget {
  final int number;
  final String name;
  final bool isEdible;

  const _SpeciesItem({
    required this.number,
    required this.name,
    required this.isEdible,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        isEdible ? Colors.green.shade700 : Colors.red.shade700;

    final Color backgroundColor =
        isEdible ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            isEdible
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TEAM MEMBER ITEM
// ─────────────────────────────────────────────

class _TeamMemberItem extends StatefulWidget {
  final int index;
  final String name;

  const _TeamMemberItem({
    required this.index,
    required this.name,
  });

  @override
  State<_TeamMemberItem> createState() => _TeamMemberItemState();
}

class _TeamMemberItemState extends State<_TeamMemberItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(
      Duration(
        milliseconds: 750 + (widget.index * 130),
      ),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${widget.index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.school_outlined,
                color: AppColors.primary.withValues(alpha: 0.65),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}