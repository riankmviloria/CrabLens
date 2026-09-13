import 'dart:io';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/data/crab_database.dart';
import '../models/crab_info.dart';

class CrabDetailScreen extends StatefulWidget {
  final String speciesName;
  final String imagePath;
  final String confidence;

  const CrabDetailScreen({
    super.key,
    required this.speciesName,
    required this.imagePath,
    required this.confidence,
  });

  @override
  State<CrabDetailScreen> createState() => _CrabDetailScreenState();
}

class _CrabDetailScreenState extends State<CrabDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _imageFade;
  late Animation<double> _imageScale;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _identityFade;
  late Animation<Offset> _identitySlide;

  late Animation<double> _confidenceFade;

  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  late Animation<double> _safetyFade;
  late Animation<Offset> _safetySlide;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // ============================================================
    // IMAGE
    // ============================================================

    _imageFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.30,
        curve: Curves.easeOut,
      ),
    );

    _imageScale = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.40,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ============================================================
    // TITLE
    // ============================================================

    _titleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.18,
        0.45,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.18,
          0.50,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ============================================================
    // IDENTITY
    // ============================================================

    _identityFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.32,
        0.60,
        curve: Curves.easeOut,
      ),
    );

    _identitySlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.32,
          0.60,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ============================================================
    // CONFIDENCE
    // ============================================================

    _confidenceFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.45,
        0.68,
        curve: Curves.easeOut,
      ),
    );

    // ============================================================
    // CONTENT
    // ============================================================

    _contentFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.55,
        0.88,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.55,
          0.88,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ============================================================
    // SAFETY
    // ============================================================

    _safetyFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.68,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _safetySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.68,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final CrabInfo? info = _findCrab(widget.speciesName);

    final bool isToxic = _isToxic(info);

    return Scaffold(
      backgroundColor:
          isToxic ? const Color(0xFF111111) : Colors.white,

      appBar: _buildAppBar(isToxic),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            FadeTransition(
              opacity: _imageFade,
              child: ScaleTransition(
                scale: _imageScale,
                child: _buildImageCard(
                  isToxic: isToxic,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // SPECIES TITLE
            // ======================================================

            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: _buildSpeciesTitle(
                  info: info,
                  isToxic: isToxic,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // IDENTITY
            // ======================================================

            FadeTransition(
              opacity: _identityFade,
              child: SlideTransition(
                position: _identitySlide,
                child: _buildIdentityCard(
                  info: info,
                  isToxic: isToxic,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ======================================================
            // AI CONFIDENCE
            // ======================================================

            FadeTransition(
              opacity: _confidenceFade,
              child: _buildConfidenceCard(
                isToxic: isToxic,
              ),
            ),

            const SizedBox(height: 26),

            // ======================================================
            // INFORMATION
            // ======================================================

            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _buildInformationSection(
                  info: info,
                  isToxic: isToxic,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ======================================================
            // SAFETY
            // ======================================================

            FadeTransition(
              opacity: _safetyFade,
              child: SlideTransition(
                position: _safetySlide,
                child: _buildSafetySection(
                  info: info,
                  isToxic: isToxic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(bool isToxic) {
    return AppBar(
      backgroundColor:
          isToxic ? const Color(0xFF111111) : Colors.white,
      foregroundColor:
          isToxic ? Colors.white : AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        isToxic ? 'Safety Alert' : 'Species Details',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard({
    required bool isToxic,
  }) {
    return Container(
      width: double.infinity,
      height: 270,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isToxic
            ? const Color(0xFF1A1A1A)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToxic
              ? Colors.red.shade800
              : Colors.grey.shade200,
          width: isToxic ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isToxic
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: isToxic
              ? const Color(0xFF0D0D0D)
              : Colors.grey.shade100,
          child: Image.file(
            File(widget.imagePath),

            // IMPORTANT:
            // Show the entire crab. Do not crop.
            fit: BoxFit.contain,

            width: double.infinity,
            height: double.infinity,

            errorBuilder: (_, __, ___) {
              return Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: isToxic
                    ? Colors.red.shade300
                    : Colors.grey.shade400,
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SPECIES TITLE
  // ============================================================

  Widget _buildSpeciesTitle({
    required CrabInfo? info,
    required bool isToxic,
  }) {
    final Color accent =
        isToxic ? Colors.red.shade400 : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isToxic)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  'TOXIC SPECIES',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),

        Text(
          info?.common ?? widget.speciesName,
          style: TextStyle(
            fontSize: 29,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: isToxic
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        if (info?.local != null &&
            info!.local.isNotEmpty)
          Text(
            info.local,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isToxic
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),

        const SizedBox(height: 4),

        Text(
          info?.scientific ?? widget.speciesName,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: accent,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IDENTITY CARD
  // ============================================================

  Widget _buildIdentityCard({
    required CrabInfo? info,
    required bool isToxic,
  }) {
    return _card(
      isToxic: isToxic,
      child: Column(
        children: [
          _identityRow(
            icon: Icons.label_outline,
            label: 'Common name',
            value: info?.common ?? widget.speciesName,
            isToxic: isToxic,
          ),

          const SizedBox(height: 13),

          _identityRow(
            icon: Icons.location_on_outlined,
            label: 'Local name',
            value: info?.local ?? 'Not specified',
            isToxic: isToxic,
          ),
        ],
      ),
    );
  }

  Widget _identityRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isToxic,
  }) {
    final Color accent =
        isToxic ? Colors.red.shade400 : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isToxic
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isToxic
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONFIDENCE
  // ============================================================

  Widget _buildConfidenceCard({
    required bool isToxic,
  }) {
    final Color accent =
        isToxic ? Colors.red.shade400 : AppColors.primary;

    return _card(
      isToxic: isToxic,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: accent,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    color: isToxic
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.confidence,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isToxic
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.verified_outlined,
            color: accent,
            size: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformationSection({
    required CrabInfo? info,
    required bool isToxic,
  }) {
    final Color accent =
        isToxic ? Colors.red.shade400 : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this crab',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isToxic
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 13),

        _infoCard(
          icon: Icons.description_outlined,
          title: 'Description',
          content: info?.description ??
              'Information not available in offline database.',
          accent: accent,
          isToxic: isToxic,
        ),

        _infoCard(
          icon: Icons.water_outlined,
          title: 'Habitat',
          content: info?.habitat ?? 'Unknown',
          accent: accent,
          isToxic: isToxic,
        ),

        if (info?.characteristics != null &&
            info!.characteristics.isNotEmpty)
          _infoCard(
            icon: Icons.search_rounded,
            title: 'Characteristics',
            content: info.characteristics,
            accent: accent,
            isToxic: isToxic,
          ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color accent,
    required bool isToxic,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToxic
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToxic
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isToxic
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            content,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: isToxic
                  ? Colors.grey.shade300
                  : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFETY
  // ============================================================

  Widget _buildSafetySection({
    required CrabInfo? info,
    required bool isToxic,
  }) {
    if (isToxic) {
      return _buildToxicSafety(info);
    }

    return _buildNormalSafety(info);
  }

  // ============================================================
  // TOXIC SAFETY
  // ============================================================

  Widget _buildToxicSafety(CrabInfo? info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF210D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.shade800,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAFETY WARNING',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'DO NOT CONSUME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'This species may contain dangerous '
            'toxins. Do not consume this crab based '
            'solely on visual identification.',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          _toxicDetail(
            'Risk',
            info?.risk ?? 'Unknown',
          ),

          const SizedBox(height: 10),

          _toxicDetail(
            'Handling',
            info?.handling ?? 'Avoid unnecessary contact',
          ),

          const SizedBox(height: 10),

          _toxicDetail(
            'First Aid',
            info?.firstAid ??
                'Consult medical professionals immediately',
          ),
        ],
      ),
    );
  }

  Widget _toxicDetail(
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 13,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.red.shade300,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL SAFETY
  // ============================================================

  Widget _buildNormalSafety(CrabInfo? info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                'SAFETY & HANDLING',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _normalDetail(
            'Risk',
            info?.risk ?? 'Unknown',
          ),

          const SizedBox(height: 8),

          _normalDetail(
            'Handling',
            info?.handling ?? 'Caution',
          ),

          const SizedBox(height: 8),

          _normalDetail(
            'First Aid',
            info?.firstAid ??
                'Consult medical professionals',
          ),
        ],
      ),
    );
  }

  Widget _normalDetail(
    String label,
    String value,
  ) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13.5,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _card({
    required bool isToxic,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToxic
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToxic
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
        boxShadow: isToxic
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }

  // ============================================================
  // FIND CRAB
  // ============================================================

  CrabInfo? _findCrab(String label) {
    final normalizedLabel = _normalize(label);

    final directMatch = CrabDatabase.crabs[label];

    if (directMatch != null) {
      return directMatch;
    }

    for (final crab in CrabDatabase.getAllCrabs()) {
      final scientific = _normalize(crab.scientific);
      final common = _normalize(crab.common);
      final local = _normalize(crab.local);

      if (normalizedLabel == scientific ||
          normalizedLabel == common ||
          normalizedLabel == local) {
        return crab;
      }
    }

    switch (normalizedLabel) {
      case 'alimango':
        return CrabDatabase.getCrab('Scylla serrata');

      case 'alimasag':
        return CrabDatabase.getCrab('Portunus pelagicus');

      case 'devil crab':
        return CrabDatabase.getCrab('Zosimus aeneus');

      case 'mosaic crab':
        return CrabDatabase.getCrab('Lophozozymus pictor');

      case 'floral egg crab':
        return CrabDatabase.getCrab('Atergatis floridus');

      case 'xanthid crab':
        return CrabDatabase.getCrab('Platypodia granulosa');

      case 'seven eleven crab':
        return CrabDatabase.getCrab('Carpilius maculatus');

      case 'purple mud crab':
        return CrabDatabase.getCrab('Scylla tranquebarica');

      case 'three spot crab':
        return CrabDatabase.getCrab('Portunus sanguinolentus');

      case 'spanner crab':
        return CrabDatabase.getCrab('Ranina ranina');

      case 'mangrove crab':
        return CrabDatabase.getCrab('Thalamita crenata');

      case 'orange mud crab':
        return CrabDatabase.getCrab('Scylla olivacea');

      case 'crucifix crab':
        return CrabDatabase.getCrab('Charybdis feriata');
    }

    return null;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // TOXICITY
  // ============================================================

  bool _isToxic(CrabInfo? info) {
    if (info == null) {
      return false;
    }

    final edibility = info.edibility.toUpperCase();

    return edibility.contains('DANGEROUS') ||
        edibility.contains('POISONOUS') ||
        edibility.contains('TOXIC') ||
        edibility.contains('DEADLY');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}