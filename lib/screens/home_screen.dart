import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/data/crab_facts.dart';
import '../models/crab_info.dart';
import '../services/tflite_service.dart';
import '../utils/crab_classifier.dart';
import 'crab_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TFLiteService _tflite = TFLiteService();

  late String _currentFact;

  List<String> _recentImages = [];

  bool _modelLoading = true;
  bool _modelLoaded = false;

  // ============================================================
  // HOME SCREEN ANIMATION
  // ============================================================

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _currentFact = CrabFacts.facts[Random().nextInt(CrabFacts.facts.length)];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    loadRecentScans();
    _loadModel();

    // Start the entrance animation after the first frame.
    // This makes sure the initial HomeScreen is rendered first
    // before the animation begins.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController.forward(from: 0.0);
    });
  }

  // ============================================================
  // ANIMATED SECTION
  // ============================================================

  Widget _animatedSection({
    required Widget child,
    required double start,
    double slideDistance = 0.10,
  }) {
    final fadeSlideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        start,
        min(start + 0.38, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: Offset(0, slideDistance),
      end: Offset.zero,
    ).animate(fadeSlideAnimation);

    final scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          start,
          min(start + 0.38, 1.0),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return FadeTransition(
      opacity: fadeSlideAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // LOAD AI MODEL
  // ============================================================

  Future<void> _loadModel() async {
    try {
      await _tflite.loadModel();

      if (!mounted) return;

      setState(() {
        _modelLoading = false;
        _modelLoaded = true;
      });

      debugPrint(
        'CrabLens AI ready. '
        'Loaded ${_tflite.labels.length} labels.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _modelLoading = false;
        _modelLoaded = false;
      });

      debugPrint('MODEL LOAD ERROR: $e');
    }
  }

  // ============================================================
  // LOAD RECENT SCANS
  // ============================================================

  Future<void> loadRecentScans() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> historyStrings =
        prefs.getStringList('scan_history') ?? [];

    final List<String> images = [];

    for (final item in historyStrings) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map<String, dynamic>) {
          final imagePath = decoded['imagePath'];

          if (imagePath is String && imagePath.isNotEmpty) {
            images.add(imagePath);
          }
        }
      } catch (e) {
        debugPrint('Invalid history record skipped: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _recentImages = images.reversed.take(4).toList();
    });
  }

  // ============================================================
  // SAVE SCAN TO HISTORY
  // ============================================================

  Future<void> _saveToHistory(
    String path,
    String species,
    bool isToxic,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> history =
        prefs.getStringList('scan_history') ?? [];

    history.add(
      jsonEncode({
        'species': species,
        'imagePath': path,
        'isToxic': isToxic,
        'date':
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      }),
    );

    await prefs.setStringList('scan_history', history);

    await loadRecentScans();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // GREETING
          // ======================================================

          _animatedSection(
            start: 0.00,
            child: const Text(
              'Good Day!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ======================================================
          // SUBTITLE
          // ======================================================

          _animatedSection(
            start: 0.08,
            child: const Text(
              'Identify crab species and check safety.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // DID YOU KNOW
          // ======================================================

          _animatedSection(
            start: 0.18,
            child: _buildFactCard(),
          ),

          const SizedBox(height: 28),

          // ======================================================
          // ACTION BUTTONS
          // ======================================================

          _animatedSection(
            start: 0.36,
            child: Row(
              children: [
                Expanded(
                  child: _actionCard(
                    context,
                    'Capture',
                    Icons.camera_alt,
                    ImageSource.camera,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _actionCard(
                    context,
                    'Upload',
                    Icons.cloud_upload,
                    ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // RECENT SCANS
          // ======================================================

          _animatedSection(
            start: 0.54,
            child: _buildRecentScans(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DID YOU KNOW
  // ============================================================

  Widget _buildFactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Did you know?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _currentFact,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT SCANS
  // ============================================================

  Widget _buildRecentScans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        _recentImages.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No recent scans.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _recentImages.length,
                itemBuilder: (context, index) {
                  return _buildRecentImage(
                    _recentImages[index],
                  );
                },
              ),
      ],
    );
  }

  // ============================================================
  // RECENT IMAGE
  // ============================================================

  Widget _buildRecentImage(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    ImageSource source,
  ) {
    final bool disabled = _modelLoading || !_modelLoaded;

    return InkWell(
      onTap: disabled
          ? () {
              if (_modelLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please wait while CrabLens AI is loading.',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'AI model is unavailable. Please restart the app.',
                    ),
                  ),
                );
              }
            }
          : () => _handleImage(context, source),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 32,
              ),

              const SizedBox(height: 5),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE HANDLING
  // ============================================================

  Future<void> _handleImage(
    BuildContext context,
    ImageSource source,
  ) async {
    if (!_modelLoaded) {
      return;
    }

    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // ==========================================================
    // SHOW SCANNING UI
    // ==========================================================

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) {
        return _ScanningDialog(
          imagePath: image.path,
          speciesCount: _tflite.labels.length,
        );
      },
    );

    try {
      // ========================================================
      // RUN TFLITE + MINIMUM SCAN DISPLAY TIME
      // ========================================================

      final results = await Future.wait([
        _tflite.classifyImage(image.path),
        Future.delayed(
          const Duration(milliseconds: 1600),
        ),
      ]);

      final result = results[0] as Map<String, dynamic>;

      // ========================================================
      // CLOSE SCANNER
      // ========================================================

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // ========================================================
      // RESULT LABEL
      // ========================================================

      final String label =
          (result['label'] ?? 'Unknown').toString().trim();

      final double confidence =
          double.tryParse(
                result['confidence'].toString(),
              ) ??
              0.0;

      debugPrint(
        'TFLITE RESULT: $label | '
        'Confidence: $confidence',
      );

      // ========================================================
      // FIND SPECIES
      // ========================================================

      final CrabInfo? crabInfo =
          CrabClassifier.getCrabInfo(label);

      // ========================================================
      // LOW CONFIDENCE
      // ========================================================

      if (!CrabClassifier.isConfident(confidence)) {
        if (!context.mounted) {
          return;
        }

        _showLowConfidence(
          context,
          label,
          confidence,
        );

        return;
      }

      // ========================================================
      // UNKNOWN
      // ========================================================

      if (crabInfo == null) {
        if (!context.mounted) {
          return;
        }

        _showUnknownResult(
          context,
          label,
          confidence,
        );

        return;
      }

      debugPrint(
        'MAPPED SPECIES: ${crabInfo.scientific}',
      );

      // ========================================================
      // SHOW REDESIGNED RESULT
      // ========================================================

      if (!context.mounted) {
        return;
      }

      _showResult(
        context,
        image.path,
        crabInfo,
        confidence,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to identify image: $e',
            ),
          ),
        );
      }

      debugPrint('TFLITE ERROR: $e');
    }
  }

  // ============================================================
  // LOW CONFIDENCE
  // ============================================================

  void _showLowConfidence(
    BuildContext context,
    String label,
    double confidence,
  ) {
    final percentage =
        CrabClassifier.confidencePercentage(
          confidence,
        ).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            SizedBox(width: 8),
            Text('Low Confidence'),
          ],
        ),
        content: Text(
          'The AI is not confident enough '
          'about this identification.\n\n'
          'Detected: $label\n'
          'Confidence: $percentage%\n\n'
          'Please take another clear photo '
          'with the crab fully visible.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UNKNOWN RESULT
  // ============================================================

  void _showUnknownResult(
    BuildContext context,
    String label,
    double confidence,
  ) {
    final percentage =
        CrabClassifier.confidencePercentage(
          confidence,
        ).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Colors.orange,
            ),
            SizedBox(width: 8),
            Text('Unknown Species'),
          ],
        ),
        content: Text(
          'The AI detected "$label", '
          'but this species is not available '
          'in the CrabLens database.\n\n'
          'Confidence: $percentage%',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOXICITY
  // ============================================================

  bool _isToxic(CrabInfo crabInfo) {
    final edibility =
        crabInfo.edibility.toUpperCase();

    return edibility.contains('DANGEROUS') ||
        edibility.contains('POISONOUS') ||
        edibility.contains('TOXIC') ||
        edibility.contains('DEADLY');
  }

  // ============================================================
  // EDIBILITY
  // ============================================================

  bool _isEdible(CrabInfo crabInfo) {
    final edibility =
        crabInfo.edibility.toUpperCase();

    return edibility.contains('SAFE') ||
        edibility.contains('EDIBLE') ||
        edibility.contains('COMMERCIAL');
  }

  // ============================================================
  // REDESIGNED RESULT
  // ============================================================

  void _showResult(
    BuildContext context,
    String path,
    CrabInfo crabInfo,
    double confidence,
  ) {
    final bool isToxic = _isToxic(crabInfo);

    final bool isEdible = _isEdible(crabInfo);

    final double percentage =
        CrabClassifier.confidencePercentage(
          confidence,
        );

    final String confidenceText =
        percentage.toStringAsFixed(1);

    // ==========================================================
    // SAVE HISTORY
    // ==========================================================

    _saveToHistory(
      path,
      crabInfo.scientific,
      isToxic,
    );

    // ==========================================================
    // SAFETY HAPTIC WARNING
    // ==========================================================

    // Vibrate when the species is NOT edible.
    // Edible species remain silent.
    if (!isEdible) {
      HapticFeedback.heavyImpact();

      Future.delayed(
        const Duration(milliseconds: 350),
        () {
          if (context.mounted) {
            HapticFeedback.heavyImpact();
          }
        },
      );
    }

    // ==========================================================
    // SHOW CUSTOM RESULT DIALOG
    // ==========================================================

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) {
        return _CrabResultDialog(
          imagePath: path,
          crabInfo: crabInfo,
          confidence: percentage,
          isToxic: isToxic,
          isEdible: isEdible,
          onViewDetails: () {
            Navigator.of(context).pop();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CrabDetailScreen(
                  speciesName: crabInfo.scientific,
                  imagePath: path,
                  confidence: '$confidenceText%',
                ),
              ),
            );
          },
          onScanAnother: () {
            Navigator.of(context).pop();

            Future.microtask(() {
              if (context.mounted) {
                _handleImage(
                  context,
                  ImageSource.camera,
                );
              }
            });
          },
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    _tflite.dispose();

    super.dispose();
  }
}

// =================================================================
// CRAB RESULT DIALOG
// =================================================================

class _CrabResultDialog extends StatefulWidget {
  final String imagePath;
  final CrabInfo crabInfo;
  final double confidence;
  final bool isToxic;
  final bool isEdible;

  final VoidCallback onViewDetails;
  final VoidCallback onScanAnother;

  const _CrabResultDialog({
    required this.imagePath,
    required this.crabInfo,
    required this.confidence,
    required this.isToxic,
    required this.isEdible,
    required this.onViewDetails,
    required this.onScanAnother,
  });

  @override
  State<_CrabResultDialog> createState() =>
      _CrabResultDialogState();
}

class _CrabResultDialogState
    extends State<_CrabResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = widget.isToxic
        ? Colors.red.shade700
        : widget.isEdible
            ? Colors.green.shade600
            : AppColors.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 35,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildImage(accentColor),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          20,
                        ),
                        child: Column(
                          children: [
                            _buildResultLabel(accentColor),

                            const SizedBox(height: 12),

                            Text(
                              widget.crabInfo.common,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 5),

                            if (widget.crabInfo.local.isNotEmpty)
                              Text(
                                widget.crabInfo.local,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                            const SizedBox(height: 4),

                            Text(
                              widget.crabInfo.scientific,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildConfidenceCard(
                              accentColor,
                            ),

                            const SizedBox(height: 14),

                            _buildSafetyCard(
                              accentColor,
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    widget.onViewDetails,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      accentColor,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .menu_book_outlined,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'View Species Details',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 9),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton(
                                onPressed:
                                    widget.onScanAnother,
                                style:
                                    TextButton.styleFrom(
                                  foregroundColor:
                                      accentColor,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .camera_alt_outlined,
                                      size: 19,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'Scan Another',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT IMAGE
  // ============================================================

  Widget _buildImage(Color accentColor) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.15,
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 65,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
        ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.60, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 15,
          bottom: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'CrabLens AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESULT LABEL
  // ============================================================

  Widget _buildResultLabel(Color accentColor) {
    String text;
    IconData icon;

    if (widget.isToxic) {
      text = 'SAFETY WARNING';
      icon = Icons.warning_amber_rounded;
    } else if (widget.isEdible) {
      text = 'IDENTIFICATION RESULT';
      icon = Icons.check_circle_outline;
    } else {
      text = 'IDENTIFICATION RESULT';
      icon = Icons.verified_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIDENCE CARD
  // ============================================================

  Widget _buildConfidenceCard(Color accentColor) {
    final double value =
        (widget.confidence / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    backgroundColor:
                        Colors.grey.shade200,
                    color: accentColor,
                  ),
                ),
                Text(
                  '${widget.confidence.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Confidence',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.confidence >= 90
                      ? 'Very confident identification'
                      : widget.confidence >= 75
                          ? 'Confident identification'
                          : 'Moderate confidence',
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
    );
  }

  // ============================================================
  // SAFETY CARD
  // ============================================================

  Widget _buildSafetyCard(Color accentColor) {
    if (widget.isToxic) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.red.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'DO NOT CONSUME',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.red.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'This species may contain '
                    'dangerous toxins. Do not eat '
                    'based solely on this identification.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget.isEdible) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.green.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                    'EDIBLE SPECIES',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.green.shade800,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'This species is classified as '
                    'edible in the CrabLens database.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.blueGrey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIES IDENTIFIED',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Species information is available '
                  'in the CrabLens database.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// =================================================================
// AI SCANNING DIALOG
// =================================================================

class _ScanningDialog extends StatefulWidget {
  final String imagePath;
  final int speciesCount;

  const _ScanningDialog({
    required this.imagePath,
    required this.speciesCount,
  });

  @override
  State<_ScanningDialog> createState() =>
      _ScanningDialogState();
}

class _ScanningDialogState
    extends State<_ScanningDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _statusTimer;

  int _statusIndex = 0;

  final List<String> _statuses = [
    'Analyzing image...',
    'Detecting crab features...',
    'Comparing species...',
    'Identifying species...',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scanAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);

    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (!mounted) return;

        setState(() {
          _statusIndex =
              (_statusIndex + 1) % _statuses.length;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.biotech,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  'CrabLens AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              'Scanning your crab image',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),

                    Container(
                      color: Colors.black
                          .withValues(alpha: 0.12),
                    ),

                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(
                            0,
                            (_scanAnimation.value * 2) -
                                1,
                          ),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 3,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.9),
                              blurRadius: 14,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScanFramePainter(),
                      ),
                    ),

                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                _pulseAnimation.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white
                                .withValues(alpha: 0.94),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.45),
                                blurRadius: 18,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.center_focus_strong,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: 250),
              child: Text(
                _statuses[_statusIndex],
                key: ValueKey(_statusIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const _ScanningDots(),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.memory,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    'TFLite AI • '
                    '${widget.speciesCount} species',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
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

  @override
  void dispose() {
    _statusTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }
}

// =================================================================
// SCANNING DOTS
// =================================================================

class _ScanningDots extends StatefulWidget {
  const _ScanningDots();

  @override
  State<_ScanningDots> createState() =>
      _ScanningDotsState();
}

class _ScanningDotsState
    extends State<_ScanningDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) {
              final double offset =
                  index * 0.25;

              final double value =
                  (_controller.value + offset) %
                      1.0;

              double opacity;

              if (value < 0.5) {
                opacity =
                    0.25 +
                    (value * 2 * 0.75);
              } else {
                opacity =
                    1.0 -
                    ((value - 0.5) * 2 * 0.75);
              }

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// =================================================================
// SCANNING FRAME
// =================================================================

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    const double margin = 9;
    const double cornerLength = 27;
    const double strokeWidth = 3;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // TOP LEFT

    canvas.drawLine(
      const Offset(
        margin,
        margin,
      ),
      const Offset(
        margin + cornerLength,
        margin,
      ),
      paint,
    );

    canvas.drawLine(
      const Offset(
        margin,
        margin,
      ),
      const Offset(
        margin,
        margin + cornerLength,
      ),
      paint,
    );

    // TOP RIGHT

    canvas.drawLine(
      Offset(
        size.width -
            margin -
            cornerLength,
        margin,
      ),
      Offset(
        size.width - margin,
        margin,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        size.width - margin,
        margin,
      ),
      Offset(
        size.width - margin,
        margin + cornerLength,
      ),
      paint,
    );

    // BOTTOM LEFT

    canvas.drawLine(
      Offset(
        margin,
        size.height - margin,
      ),
      Offset(
        margin + cornerLength,
        size.height - margin,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        margin,
        size.height -
            margin -
            cornerLength,
      ),
      Offset(
        margin,
        size.height - margin,
      ),
      paint,
    );

    // BOTTOM RIGHT

    canvas.drawLine(
      Offset(
        size.width -
            margin -
            cornerLength,
        size.height - margin,
      ),
      Offset(
        size.width - margin,
        size.height - margin,
      ),
      paint,
    );

    canvas.drawLine(
      Offset(
        size.width - margin,
        size.height -
            margin -
            cornerLength,
      ),
      Offset(
        size.width - margin,
        size.height - margin,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}