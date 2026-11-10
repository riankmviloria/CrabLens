import 'dart:io';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/crab_info.dart';

class CrabShareCard extends StatelessWidget {
  final CrabInfo? info;
  final String speciesName;
  final String imagePath;
  final String confidence;
  final bool isToxic;

  const CrabShareCard({
    super.key,
    required this.info,
    required this.speciesName,
    required this.imagePath,
    required this.confidence,
    required this.isToxic,
  });

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // Resolve nullable CrabInfo once.
    // This prevents nullable access throughout the widget.
    // ------------------------------------------------------------

    final String commonName =
        info?.common ?? speciesName;

    final String localName =
        info?.local ?? 'Not specified';

    final String scientificName =
        info?.scientific ?? speciesName;

    final String description =
        info?.description ??
        'Information not available in offline database.';

    final String habitat =
        info?.habitat ?? 'Unknown';

    final String characteristics =
        info?.characteristics ?? '';

    final String risk =
        info?.risk ?? 'Unknown';

    final String handling =
        info?.handling ?? 'Caution';

    final String firstAid =
        info?.firstAid ??
        'Consult medical professionals';

    final Color accent =
        isToxic
            ? Colors.red.shade400
            : AppColors.primary;

    final Color background =
        isToxic
            ? const Color(0xFF111111)
            : Colors.white;

    final Color cardBackground =
        isToxic
            ? const Color(0xFF1A1A1A)
            : Colors.white;

    final Color primaryText =
        isToxic
            ? Colors.white
            : AppColors.textPrimary;

    final Color secondaryText =
        isToxic
            ? Colors.grey.shade300
            : Colors.grey.shade800;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isToxic
                ? Colors.red.shade800
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color:
                        accent.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: Icon(
                    Icons.waves_rounded,
                    color: accent,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CrabLens',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.w900,
                          color: primaryText,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Crab Classification Result',
                        style: TextStyle(
                          fontSize: 15,
                          color: isToxic
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isToxic)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withValues(alpha: 0.14),
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.red
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .warning_amber_rounded,
                          color:
                              Colors.red.shade400,
                          size: 20,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          'TOXIC SPECIES',
                          style: TextStyle(
                            color:
                                Colors.red.shade400,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // ======================================================
            // IMAGE
            // ======================================================

            Container(
              width: double.infinity,
              height: 500,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToxic
                    ? const Color(0xFF0D0D0D)
                    : Colors.grey.shade50,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: isToxic
                      ? Colors.red.shade800
                      : Colors.grey.shade200,
                ),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(17),
                child: Container(
                  color: isToxic
                      ? const Color(0xFF080808)
                      : Colors.grey.shade100,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder:
                        (_, __, ___) {
                      return Icon(
                        Icons
                            .image_not_supported_outlined,
                        size: 70,
                        color: isToxic
                            ? Colors.red.shade300
                            : Colors.grey.shade400,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ======================================================
            // SPECIES
            // ======================================================

            Text(
              commonName,
              style: TextStyle(
                fontSize: 38,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: primaryText,
              ),
            ),

            const SizedBox(height: 8),

            if (localName.isNotEmpty)
              Text(
                localName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w500,
                  color: isToxic
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),

            const SizedBox(height: 5),

            Text(
              scientificName,
              style: TextStyle(
                fontSize: 20,
                fontStyle:
                    FontStyle.italic,
                color: accent,
              ),
            ),

            const SizedBox(height: 24),

            // ======================================================
            // BASIC DETAILS
            // ======================================================

            _detailCard(
              background: cardBackground,
              accent: accent,
              primaryText: primaryText,
              secondaryText: secondaryText,
              children: [
                _detailRow(
                  icon: Icons.label_outline,
                  label: 'Common name',
                  value: commonName,
                  accent: accent,
                  primaryText:
                      primaryText,
                  secondaryText:
                      secondaryText,
                ),

                const SizedBox(height: 18),

                _detailRow(
                  icon:
                      Icons.location_on_outlined,
                  label: 'Local name',
                  value: localName,
                  accent: accent,
                  primaryText:
                      primaryText,
                  secondaryText:
                      secondaryText,
                ),

                const SizedBox(height: 18),

                _detailRow(
                  icon:
                      Icons.auto_awesome,
                  label:
                      'Classification Confidence',
                  value: confidence,
                  accent: accent,
                  primaryText:
                      primaryText,
                  secondaryText:
                      secondaryText,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ======================================================
            // ABOUT
            // ======================================================

            _sectionTitle(
              'About this crab',
              primaryText,
            ),

            const SizedBox(height: 15),

            _informationCard(
              icon:
                  Icons.description_outlined,
              title: 'Description',
              content: description,
              accent: accent,
              cardBackground:
                  cardBackground,
              primaryText:
                  primaryText,
              secondaryText:
                  secondaryText,
            ),

            _informationCard(
              icon: Icons.water_outlined,
              title: 'Habitat',
              content: habitat,
              accent: accent,
              cardBackground:
                  cardBackground,
              primaryText:
                  primaryText,
              secondaryText:
                  secondaryText,
            ),

            if (characteristics.isNotEmpty)
              _informationCard(
                icon:
                    Icons.search_rounded,
                title: 'Characteristics',
                content:
                    characteristics,
                accent: accent,
                cardBackground:
                    cardBackground,
                primaryText:
                    primaryText,
                secondaryText:
                    secondaryText,
              ),

            const SizedBox(height: 18),

            // ======================================================
            // SAFETY
            // ======================================================

            if (isToxic)
              _buildToxicSafety(
                risk: risk,
                handling: handling,
                firstAid: firstAid,
              )
            else
              _buildNormalSafety(
                risk: risk,
                handling: handling,
                firstAid: firstAid,
              ),

            const SizedBox(height: 30),

            // ======================================================
            // FOOTER
            // ======================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(
                top: 22,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isToxic
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color:
                        Colors.grey.shade500,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Classified using CrabLens. '
                      'For reference and educational purposes.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isToxic
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    Color textColor,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w900,
        color: textColor,
      ),
    );
  }

  // ============================================================
  // DETAIL CARD
  // ============================================================

  Widget _detailCard({
    required Color background,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: isToxic
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                accent.withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _informationCard({
    required IconData icon,
    required String title,
    required String content,
    required Color accent,
    required Color cardBackground,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isToxic
              ? Colors.grey.shade800
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color: primaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOXIC SAFETY
  // ============================================================

  Widget _buildToxicSafety({
    required String risk,
    required String handling,
    required String firstAid,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF210D0D),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.red.shade800,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAFETY WARNING',
                      style: TextStyle(
                        color:
                            Colors.red.shade400,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'DO NOT CONSUME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'This species may contain dangerous '
            'toxins. Do not consume this crab based '
            'solely on visual classification.',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 15,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 18),

          _safetyRow(
            'Risk',
            risk,
          ),

          const SizedBox(height: 10),

          _safetyRow(
            'Handling',
            handling,
          ),

          const SizedBox(height: 10),

          _safetyRow(
            'First Aid',
            firstAid,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL SAFETY
  // ============================================================

  Widget _buildNormalSafety({
    required String risk,
    required String handling,
    required String firstAid,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Text(
                'SAFETY & HANDLING',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 0.5,
                  color:
                      Colors.green.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _normalSafetyRow(
            'Risk',
            risk,
          ),

          const SizedBox(height: 10),

          _normalSafetyRow(
            'Handling',
            handling,
          ),

          const SizedBox(height: 10),

          _normalSafetyRow(
            'First Aid',
            firstAid,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOXIC SAFETY ROW
  // ============================================================

  Widget _safetyRow(
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black
            .withValues(alpha: 0.25),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color:
                    Colors.red.shade300,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL SAFETY ROW
  // ============================================================

  Widget _normalSafetyRow(
    String label,
    String value,
  ) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14.5,
          height: 1.45,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}