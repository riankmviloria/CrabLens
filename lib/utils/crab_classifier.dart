import '../core/data/crab_database.dart';
import '../models/crab_info.dart';

class CrabClassifier {
  /// Minimum confidence required before
  /// accepting a classification.
  static const double unknownThreshold = 0.60;

  /// Label used by the TFLite model for images
  /// that do not contain a crab.
  static const String notACrabLabel = 'Not a Crab';

  /// Converts the model label into the corresponding
  /// crab information.
  ///
  /// Returns null when the label is not supported
  /// or when the result is "Not a Crab".
  static CrabInfo? getCrabInfo(String label) {
    final normalizedLabel = label
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // ============================================================
    // NOT A CRAB
    // ============================================================

    if (normalizedLabel == 'not a crab') {
      return null;
    }

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

    if (normalizedLabel == 'three spot crab') {
      return CrabDatabase.getCrab(
        'Portunus sanguinolentus',
      );
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

    if (normalizedLabel == 'seven eleven crab') {
      return CrabDatabase.getCrab('Carpilius maculatus');
    }

    // ============================================================
    // UNKNOWN
    // ============================================================

    return null;
  }

  /// Returns true when the model label belongs
  /// to one of the supported crab species.
  static bool isKnownSpecies(String label) {
    final normalizedLabel = label
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // "Not a Crab" is never a known species.
    if (normalizedLabel == 'not a crab') {
      return false;
    }

    return getCrabInfo(label) != null;
  }

  /// Converts 0.0–1.0 confidence to percentage.
  static double confidencePercentage(
    double confidence,
  ) {
    return confidence * 100;
  }

  /// Determines whether the confidence is high enough
  /// to accept the classification.
  static bool isConfident(
    double confidence, {
    double threshold = unknownThreshold,
  }) {
    return confidence >= threshold;
  }

  /// Determines whether the result should be treated
  /// as Unknown Species / Not a Crab.
  static bool isUnknown(
    String label,
    double confidence, {
    double threshold = unknownThreshold,
  }) {
    return !isKnownSpecies(label) ||
        confidence < threshold;
  }

  /// Determines whether the prediction should be accepted
  /// as a valid crab classification.
  static bool isValidCrab(
    String label,
    double confidence, {
    double threshold = unknownThreshold,
  }) {
    return isKnownSpecies(label) &&
        confidence >= threshold;
  }

  /// Determines whether the model explicitly classified
  /// the image as "Not a Crab".
  static bool isNotACrab(String label) {
    final normalizedLabel = label
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    return normalizedLabel == 'not a crab';
  }
}