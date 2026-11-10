
import 'dart:io';

import 'tflite_service.dart';

class CrabLensBatchEvaluator {
  final TFLiteService classifier;

  CrabLensBatchEvaluator(this.classifier);

  static const double selectionThreshold = 0.90;

  static const Set<String> supportedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
  };

  String normalizeLabel(String label) {
    var value = label.trim();

    // Handle labels such as "0 Alimango" or "0: Alimango".
    value = value.replaceFirst(
      RegExp(r'^\d+\s*:?\s+'),
      '',
    );

    return value
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String escapeCsv(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }

  Future<Map<String, dynamic>> evaluate({
    required String photosDirectory,
    required String outputDirectory,
  }) async {
    final photosRoot = Directory(photosDirectory);
    final outputRoot = Directory(outputDirectory);

    if (!await photosRoot.exists()) {
      throw Exception('Photos directory does not exist.');
    }

    await outputRoot.create(recursive: true);

    final selectedRoot = Directory(
      '${outputRoot.path}${Platform.pathSeparator}'
      'high_confidence_correct',
    );

    await selectedRoot.create(recursive: true);

    final csvFile = File(
      '${outputRoot.path}${Platform.pathSeparator}results.csv',
    );

    final rows = <String>[
      'filename,actual_species,predicted_species,'
          'confidence_percent,correct,selected',
    ];

    var processed = 0;
    var correct = 0;
    var selected = 0;
    var errors = 0;

    final files = await photosRoot
        .list(recursive: true, followLinks: false)
        .where((entity) => entity is File)
        .cast<File>()
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final extension =
          '.${file.path.split('.').last.toLowerCase()}';

      if (!supportedExtensions.contains(extension)) {
        continue;
      }

      // The parent folder identifies the expected species.
      final actualLabel =
          file.parent.path.split(Platform.pathSeparator).last;

      try {
        // Reuses the existing Flutter classifier exactly.
        final result = await classifier.classifyImage(file.path);

        final predictedLabel = result['label'] as String;
        final confidence =
            (result['confidence'] as num).toDouble();

        final isCorrect =
            normalizeLabel(actualLabel) ==
            normalizeLabel(predictedLabel);

        final isSelected =
            isCorrect && confidence >= selectionThreshold;

        processed++;

        if (isCorrect) {
          correct++;
        }

        if (isSelected) {
          final destinationFolder = Directory(
            '${selectedRoot.path}'
            '${Platform.pathSeparator}$actualLabel',
          );

          await destinationFolder.create(recursive: true);

          var destinationPath =
              '${destinationFolder.path}'
              '${Platform.pathSeparator}'
              '${file.uri.pathSegments.last}';

          if (await File(destinationPath).exists()) {
            final timestamp = DateTime.now().microsecondsSinceEpoch;
            final filename = file.uri.pathSegments.last;
            final dot = filename.lastIndexOf('.');
            final stem = dot > 0 ? filename.substring(0, dot) : filename;
            final suffix = dot > 0 ? filename.substring(dot) : '';

            destinationPath =
                '${destinationFolder.path}'
                '${Platform.pathSeparator}'
                '${stem}_$timestamp$suffix';
          }

          await file.copy(destinationPath);
          selected++;
        }

        rows.add([
          escapeCsv(file.uri.pathSegments.last),
          escapeCsv(actualLabel),
          escapeCsv(predictedLabel),
          (confidence * 100).toStringAsFixed(2),
          isCorrect ? 'yes' : 'no',
          isSelected ? 'yes' : 'no',
        ].join(','));

        print(
          '${file.uri.pathSegments.last}: '
          '$predictedLabel '
          '(${(confidence * 100).toStringAsFixed(2)}%) '
          '| correct=$isCorrect | selected=$isSelected',
        );
      } catch (e) {
        errors++;

        rows.add([
          escapeCsv(file.uri.pathSegments.last),
          escapeCsv(actualLabel),
          '',
          '',
          '',
          'error: ${escapeCsv(e.toString())}',
        ].join(','));

        print('Error processing ${file.path}: $e');
      }
    }

    await csvFile.writeAsString(
      '${rows.join('\n')}\n',
      flush: true,
    );

    return {
      'processed': processed,
      'correct': correct,
      'selected': selected,
      'errors': errors,
      'csvPath': csvFile.path,
      'selectedDirectory': selectedRoot.path,
    };
  }
}
