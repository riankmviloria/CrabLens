import '../core/data/crab_database.dart';
import '../models/crab_info.dart';

class CrabClassifier {
  /// Converts the raw label returned by the TFLite model
  /// into the corresponding crab information.
  ///
  /// The model currently has 13 classes.
  static CrabInfo? getCrabInfo(String label) {
    final normalizedLabel = label
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // ============================================================
    // SAFE / COMMERCIAL CRABS
    // ============================================================

    if (normalizedLabel == 'alimango') {
      return CrabDatabase.getCrab('Scylla serrata');
    }

    if (normalizedLabel == 'orange mud crab') {
      return CrabDatabase.getCrab('Scylla olivacea');
    }

    if (normalizedLabel == 'purple mud crab') {
      return CrabDatabase.getCrab('Scylla tranquebarica');
    }

    if (normalizedLabel == 'alimasag') {
      return CrabDatabase.getCrab('Portunus pelagicus');
    }

    if (normalizedLabel == 'three spot crab' ||
        normalizedLabel == 'three-spot crab') {
      return CrabDatabase.getCrab('Portunus sanguinolentus');
    }

    if (normalizedLabel == 'spanner crab' ||
        normalizedLabel == 'spanner crab frog crab') {
      return CrabDatabase.getCrab('Ranina ranina');
    }

    if (normalizedLabel == 'mangrove crab') {
      return CrabDatabase.getCrab('Thalamita crenata');
    }

    if (normalizedLabel == 'crucifix crab') {
      return CrabDatabase.getCrab('Charybdis feriata');
    }

    // ============================================================
    // DANGEROUS / POISONOUS CRABS
    // ============================================================

    if (normalizedLabel == 'devil crab' ||
        normalizedLabel == 'killer crab') {
      return CrabDatabase.getCrab('Zosimus aeneus');
    }

    if (normalizedLabel == 'mosaic crab' ||
        normalizedLabel == 'mosaic reef crab') {
      return CrabDatabase.getCrab('Lophozozymus pictor');
    }

    if (normalizedLabel == 'floral egg crab') {
      return CrabDatabase.getCrab('Atergatis floridus');
    }

    if (normalizedLabel == 'xanthid crab') {
      return CrabDatabase.getCrab('Platypodia granulosa');
    }

    if (normalizedLabel == 'seven eleven crab' ||
        normalizedLabel == 'seven-eleven crab') {
      return CrabDatabase.getCrab('Carpilius maculatus');
    }

    return null;
  }

  /// Converts a confidence value from 0.0–1.0
  /// into a percentage.
  static double confidencePercentage(double confidence) {
    return confidence * 100;
  }

  /// Determines whether the model result is confident enough
  /// to be shown to the user.
  static bool isConfident(
    double confidence, {
    double threshold = 0.60,
  }) {
    return confidence >= threshold;
  }
}