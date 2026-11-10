import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_litert/flutter_litert.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> labels = [];

  int _outputSize = 0;

  // Minimum confidence required for a prediction.
  static const double confidenceThreshold = 0.60;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/model_unquant.tflite',
      );

      final labelData = await rootBundle.loadString(
        'assets/model/labels.txt',
      );

      labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      _outputSize = _interpreter!
          .getOutputTensor(0)
          .shape
          .last;

      print('MODEL LOADED');
      print('Labels: $labels');
      print('Number of Labels: ${labels.length}');
      print('Model Output Size: $_outputSize');
    } catch (e) {
      print('MODEL LOAD ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> classifyImage(
    String imagePath,
  ) async {
    if (_interpreter == null) {
      throw Exception('Interpreter not loaded');
    }

    final imageBytes = File(imagePath).readAsBytesSync();

    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // Resize image to model input size.
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
    );

    // Create input tensor.
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Convert pixels to normalized RGB values.
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);

        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    // Create output tensor.
    final output = List.generate(
      1,
      (_) => List.filled(
        _outputSize,
        0.0,
      ),
    );

    // Run the model.
    _interpreter!.run(
      input,
      output,
    );

    // Find highest confidence.
    int maxIndex = 0;
    double maxConfidence = -1.0;

    for (int i = 0; i < _outputSize; i++) {
      final confidence = output[0][i];

      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        maxIndex = i;
      }
    }

    // Get predicted label.
    String label = 'Unknown';

    if (labels.isNotEmpty && maxIndex < labels.length) {
      label = labels[maxIndex];
    }

    // Normalize label for checking.
    final normalizedLabel = label
        .toLowerCase()
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // Check if model explicitly predicted "Not a Crab".
    final isNotACrab = normalizedLabel == 'not a crab';

    // Check confidence.
    final isConfident = maxConfidence >= confidenceThreshold;

    // Final crab decision.
    //
    // A result is accepted as a crab only when:
    // 1. It is NOT the "Not a Crab" class.
    // 2. Confidence is at least 80%.
    final isCrab = !isNotACrab && isConfident;

    // Debug information.
    print('--------------------------------');
    print('MODEL PREDICTION');
    print('Label: $label');
    print(
      'Confidence: '
      '${maxConfidence.toStringAsFixed(4)}',
    );
    print(
      'Confidence %: '
      '${(maxConfidence * 100).toStringAsFixed(2)}%',
    );
    print('Index: $maxIndex');
    print('Is Not a Crab: $isNotACrab');
    print('Is Confident: $isConfident');
    print('Is Crab: $isCrab');
    print('--------------------------------');

    return {
      'label': label,
      'confidence': maxConfidence,
      'isCrab': isCrab,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}