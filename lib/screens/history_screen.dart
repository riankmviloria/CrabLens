import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import 'crab_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];

  String _selectedFilter = 'All';

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final historyStrings = prefs.getStringList('scan_history') ?? [];

    final List<Map<String, dynamic>> loadedHistory = [];

    for (final item in historyStrings) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map) {
          loadedHistory.add(Map<String, dynamic>.from(decoded));
        }
      } catch (e) {
        debugPrint('Invalid history item skipped: $e');
      }
    }

    loadedHistory.sort((a, b) {
      final dateA = _getDateTime(a);
      final dateB = _getDateTime(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    if (!mounted) return;

    setState(() {
      _history = loadedHistory;
    });

    _animationController
      ..reset()
      ..forward();
  }

  // ============================================================
  // DELETE HISTORY ITEM
  // ============================================================

  Future<void> _deleteHistoryItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete history?'),
        content: Text(
          'Remove ${_getCommonName(item)} from your scan history? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('scan_history') ?? [];
      final target = jsonEncode(item);

      // Remove only one matching entry, even when duplicates exist.
      final index = saved.indexWhere((raw) {
        try {
          final decoded = jsonDecode(raw);
          return decoded is Map &&
              jsonEncode(Map<String, dynamic>.from(decoded)) == target;
        } catch (_) {
          return false;
        }
      });

      if (index == -1) {
        await loadHistory();
        return;
      }

      saved.removeAt(index);
      final success = await prefs.setStringList('scan_history', saved);
      if (!success) throw Exception('Failed to save updated history');

      if (!mounted) return;
      await loadHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History item deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete history: $e')),
      );
    }
  }

  // ============================================================
  // DELETE ALL HISTORY
  // ============================================================

  Future<void> _deleteAllHistory() async {
    if (_history.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all history?'),
        content: const Text(
          'This will permanently remove all scan records from your history. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove('scan_history');
      if (!success) throw Exception('Failed to clear saved history');

      if (!mounted) return;
      setState(() {
        _history.clear();
      });
      _animationController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All scan history deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete all history: $e')),
      );
    }
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime? _getDateTime(Map<String, dynamic> item) {
    final timestamp = item['timestamp'];

    if (timestamp != null) {
      final milliseconds = int.tryParse(timestamp.toString());

      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    }

    final date = item['date']?.toString();

    if (date != null && date.isNotEmpty) {
      return DateTime.tryParse(date);
    }

    return null;
  }

  String _formatTime(Map<String, dynamic> item) {
    final dateTime = _getDateTime(item);

    if (dateTime == null) {
      return item['time']?.toString() ?? '';
    }

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _getDateGroup(Map<String, dynamic> item) {
    final date = _getDateTime(item);

    if (date == null) return 'Earlier';

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final scanDate = DateTime(date.year, date.month, date.day);

    if (scanDate == today) return 'Today';

    if (scanDate == yesterday) return 'Yesterday';

    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  // ============================================================
  // STATUS BASED ON TOXIC CLASSIFICATION
  // ============================================================

  String _getStatus(Map<String, dynamic> item) {
    // No crab detected.
    if (item['isCrab'] == false) {
      return 'No Crab';
    }

    // Toxic crab = Non-edible.
    if (item['isToxic'] == true) {
      return 'Non-edible';
    }

    // Non-toxic crab = Edible.
    return 'Edible';
  }

  // ============================================================
  // SPECIES INFORMATION
  // ============================================================

  String _getCommonName(Map<String, dynamic> item) {
    if (_getStatus(item) == 'No Crab') {
      return 'No crab detected';
    }

    final commonName = item['commonName']?.toString().trim() ?? '';
    if (commonName.isNotEmpty) return commonName;

    final species = item['species']?.toString().trim() ?? '';
    if (species.isNotEmpty) return species;

    return 'Unknown Species';
  }

  String _getScientificName(Map<String, dynamic> item) {
    if (_getStatus(item) == 'No Crab') {
      return 'Try a clearer photo';
    }

    return item['scientificName']?.toString() ??
        item['scientific']?.toString() ??
        '';
  }

  String _getConfidence(Map<String, dynamic> item) {
    if (_getStatus(item) == 'No Crab') {
      return '';
    }

    final confidence = item['confidence']?.toString() ?? '';

    if (confidence.isEmpty || confidence == 'N/A') {
      return '';
    }

    return confidence.contains('%') ? confidence : '$confidence%';
  }

  String _getImagePath(Map<String, dynamic> item) {
    return item['imagePath']?.toString() ?? '';
  }

  // ============================================================
  // FILTER HISTORY
  // ============================================================

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'All') {
      return _history;
    }

    return _history.where((item) {
      return _getStatus(item) == _selectedFilter;
    }).toList();
  }

  // ============================================================
  // GROUP HISTORY BY DATE
  // ============================================================

  Map<String, List<Map<String, dynamic>>> _groupHistory() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in _filteredHistory) {
      final group = _getDateGroup(item);

      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(item);
    }

    return grouped;
  }

  // ============================================================
  // OPEN CRAB DETAIL
  // ============================================================

  void _openCrabDetail(Map<String, dynamic> item) {
    if (_getStatus(item) == 'No Crab') return;

    final imagePath = _getImagePath(item);

    if (imagePath.isEmpty || !File(imagePath).existsSync()) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) {
          return CrabDetailScreen(
            speciesName: _getCommonName(item),
            imagePath: imagePath,
            confidence: item['confidence']?.toString() ?? 'N/A',
          );
        },
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
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

  // ============================================================
  // FILTER TABS
  // ============================================================

  Widget _buildFilterTabs() {
    const filters = ['All', 'Edible', 'Non-edible'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });

              _animationController
                ..reset()
                ..forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DATE HEADER
  // ============================================================

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 13, left: 3),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(String status) {
    final Color color;
    final Color background;

    switch (status) {
      case 'Edible':
        color = Colors.green.shade800;
        background = Colors.green.withValues(alpha: 0.12);
        break;

      case 'Non-edible':
        color = Colors.red.shade800;
        background = Colors.red.withValues(alpha: 0.12);
        break;

      default:
        color = Colors.blueGrey.shade800;
        background = Colors.blueGrey.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        status,
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder({required bool isNoCrab}) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        isNoCrab ? Icons.hide_image_outlined : Icons.image_outlined,
        size: 27,
        color: AppColors.primary.withValues(alpha: 0.75),
      ),
    );
  }

  // ============================================================
  // HISTORY IMAGE
  // ============================================================

  Widget _buildHistoryImage(Map<String, dynamic> item) {
    final imagePath = _getImagePath(item);
    final isNoCrab = _getStatus(item) == 'No Crab';

    if (imagePath.isEmpty || !File(imagePath).existsSync()) {
      return _buildImagePlaceholder(isNoCrab: isNoCrab);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.file(
        File(imagePath),
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildImagePlaceholder(isNoCrab: isNoCrab);
        },
      ),
    );
  }

  // ============================================================
  // HISTORY ITEM
  // ============================================================

  Widget _buildHistoryItem({
    required Map<String, dynamic> item,
    required int index,
  }) {
    final status = _getStatus(item);
    final commonName = _getCommonName(item);
    final scientificName = _getScientificName(item);
    final confidence = _getConfidence(item);
    final time = _formatTime(item);

    final isNoCrab = status == 'No Crab';

    final start = (index * 0.08).clamp(0.0, 0.60);
    final end = (start + 0.40).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: InkWell(
          onTap: isNoCrab ? null : () => _openCrabDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
            child: Row(
              children: [
                _buildHistoryImage(item),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        scientificName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isNoCrab
                              ? Colors.grey.shade600
                              : Colors.black87,
                          fontStyle: isNoCrab
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        confidence.isNotEmpty ? '$time · $confidence' : time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Stack the status badge and delete action vertically to
                // prevent the Non-edible badge from being clipped on narrow screens.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStatusBadge(status),
                    SizedBox(
                      height: 36,
                      width: 40,
                      child: IconButton(
                        tooltip: 'Delete history',
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.red.shade600,
                        iconSize: 21,
                        padding: EdgeInsets.zero,
                        onPressed: () => _deleteHistoryItem(item),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 42,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No history yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              'Your crab scans will appear here\n'
              'after you classify a crab.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NO FILTER RESULTS
  // ============================================================

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 12),

            Text(
              'No ${_selectedFilter.toLowerCase()} scans found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN HISTORY CONTENT
  // ============================================================

  Widget _buildHistoryContent() {
    final groupedHistory = _groupHistory();

    final groups = groupedHistory.entries.toList();

    if (groups.isEmpty) {
      return _history.isEmpty ? _buildEmptyState() : _buildNoResults();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 25),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(group.key),

            ...List.generate(group.value.length, (index) {
              final item = group.value[index];

              return Column(
                children: [
                  _buildHistoryItem(item: item, index: index),

                  if (index != group.value.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.7,
                      color: Colors.grey.withValues(alpha: 0.18),
                      indent: 80,
                    ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _history.isEmpty ? null : _deleteAllHistory,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 19),
                  label: const Text('Delete all'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildFilterTabs(),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: loadHistory,
            child: _buildHistoryContent(),
          ),
        ),
      ],
    );
  }
}
