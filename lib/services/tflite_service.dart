import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> labels = [];

  int _outputSize = 0;

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

      // Get the actual output size from the model.
      _outputSize = _interpreter!
          .getOutputTensor(0)
          .shape
          .last;

      print('MODEL LOADED');
      print('Labels: $labels');
      print('Model Output Size: $_outputSize');
    } catch (e) {
      print('MODEL LOAD ERROR: $e');
    }
  }

  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (_interpreter == null) {
      throw Exception('Interpreter not loaded');
    }

    final imageBytes = File(imagePath).readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      return {
        'label': 'Unknown',
        'confidence': 0.0,
      };
    }

    // Resize image to the model's expected input size.
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
    );

    // Prepare input tensor.
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

    // Convert RGB values from 0-255 to 0.0-1.0.
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);

        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    // Prepare output tensor.
    final output = List.generate(
      1,
      (_) => List.filled(_outputSize, 0.0),
    );

    // Run inference.
    _interpreter!.run(input, output);

    // Find the class with the highest confidence.
    int maxIndex = 0;
    double maxConfidence = -1.0;

    for (int i = 0; i < _outputSize; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    String label = 'Unknown';

    if (labels.isNotEmpty && maxIndex < labels.length) {
      label = labels[maxIndex];
    }

    return {
      'label': label,
      'confidence': maxConfidence,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}