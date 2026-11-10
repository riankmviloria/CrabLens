// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/widgets.dart';

// import '../lib/services/tflite_service.dart';
// import '../lib/services/crablens_batch_evaluator.dart';

// Future<void> main(List<String> args) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   print('========================================');
//   print('CRABLENS ALL-CRAB BATCH EVALUATOR');
//   print('========================================');

//   String? photosDirectory;
//   String? outputDirectory;

//   if (args.length >= 2) {
//     photosDirectory = args[0];
//     outputDirectory = args[1];
//   } else {
//     print('Select the parent folder containing all crab species.');

//     photosDirectory = await FilePicker.getDirectoryPath(
//       dialogTitle: 'Select All Crab Photos Folder',
//       initialDirectory:
//           '/Users/rhenzeltherenzelei/Dev/crablens_local_batch/photos',
//     );

//     if (photosDirectory == null) {
//       print('Photo folder selection cancelled.');
//       return;
//     }

//     print('Selected photos: $photosDirectory');

//     outputDirectory = await FilePicker.getDirectoryPath(
//       dialogTitle: 'Select Batch Results Folder',
//       initialDirectory:
//           '/Users/rhenzeltherenzelei/Dev/crablens_new_model_batch/results',
//     );

//     if (outputDirectory == null) {
//       print('Output folder selection cancelled.');
//       return;
//     }
//   }

//   final photosRoot = Directory(photosDirectory);

//   if (!await photosRoot.exists()) {
//     stderr.writeln('ERROR: Photos folder not found: $photosDirectory');
//     exitCode = 1;
//     return;
//   }

//   await Directory(outputDirectory).create(recursive: true);

//   final classifier = TFLiteService();

//   try {
//     print('\nLoading CrabLens model...');
//     await classifier.loadModel();

//     print('Model loaded successfully.');
//     print('Evaluating all crab species...');

//     final evaluator = CrabLensBatchEvaluator(classifier);

//     final result = await evaluator.evaluate(
//       photosDirectory: photosDirectory,
//       outputDirectory: outputDirectory,
//     );

//     print('\n========================================');
//     print('ALL-CRAB EVALUATION SUMMARY');
//     print('========================================');
//     print('Processed: ${result['processed']}');
//     print('Correct: ${result['correct']}');
//     print('Selected (correct, >= 90%): ${result['selected']}');
//     print('Errors: ${result['errors']}');
//     print('CSV: ${result['csvPath']}');
//     print('Selected photos: ${result['selectedDirectory']}');
//     print('========================================');

//     exitCode = (result['errors'] as int) == 0 ? 0 : 1;
//   } catch (e, stackTrace) {
//     stderr.writeln('BATCH EVALUATION FAILED: $e');
//     stderr.writeln(stackTrace);
//     exitCode = 1;
//   } finally {
//     classifier.dispose();
//     print('Batch evaluator finished.');
//   }
// }