import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Uncomment when using custom model

/// Enhanced local food recognition with support for custom TFLite models
/// Can switch between ML Kit and custom trained models
class ImprovedLocalFoodRecognizer {
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(
      confidenceThreshold: 0.65, // Higher threshold for better accuracy
    ),
  );

  // Uncomment when using custom model:
  // Interpreter? _customInterpreter;
  // List<String>? _customLabels;
  // bool _useCustomModel = false;

  /// Initialize custom TFLite model (optional)
  /// Call this in app startup if you have trained model
  Future<void> initializeCustomModel() async {
    /* Uncomment when using custom model:
    try {
      // Load the custom model
      _customInterpreter = await Interpreter.fromAsset('assets/ml_models/food_model.tflite');
      
      // Load labels
      final labelsData = await rootBundle.loadString('assets/ml_models/labels.json');
      final labelsJson = json.decode(labelsData) as Map<String, dynamic>;
      _customLabels = labelsJson.values.cast<String>().toList();
      
      _useCustomModel = true;
      print('✅ Custom food model loaded successfully');
    } catch (e) {
      print('⚠️ Failed to load custom model, falling back to ML Kit: $e');
      _useCustomModel = false;
    }
    */
  }

  /// Recognize food items from image
  Future<LocalRecognitionResult> recognizeFood(File imageFile) async {
    // Uncomment when using custom model:
    // if (_useCustomModel && _customInterpreter != null) {
    //   return _recognizeWithCustomModel(imageFile);
    // }

    // Use ML Kit with improved strategy
    return _recognizeWithMLKit(imageFile);
  }

  /// ML Kit recognition with enhanced logic
  Future<LocalRecognitionResult> _recognizeWithMLKit(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);

      if (labels.isEmpty) {
        return LocalRecognitionResult(
          success: false,
          message: 'No objects detected. Please describe what you ate.',
          items: [],
          requiresManualInput: true,
        );
      }

      // Strategy 1: Extract specific food items first
      final specificFoods = _extractSpecificFoods(labels);

      // Strategy 2: If we have specific foods, use them
      if (specificFoods.isNotEmpty) {
        return LocalRecognitionResult(
          success: true,
          message: 'Detected ${specificFoods.length} food item(s)',
          items: specificFoods,
          requiresManualInput: false,
        );
      }

      // Strategy 3: Try to infer food from context clues
      final inferredFoods = _inferFoodFromContext(labels);
      if (inferredFoods.isNotEmpty) {
        return LocalRecognitionResult(
          success: true,
          message: 'Detected possible food items',
          items: inferredFoods,
          requiresManualInput: false,
        );
      }

      // Strategy 4: Check if it's food-related but too generic
      final hasFoodContext = labels.any((label) => _isFoodRelated(label.label));
      if (hasFoodContext) {
        final genericLabels = labels
            .where((l) => _isFoodRelated(l.label))
            .map((l) => l.label)
            .take(3)
            .join(', ');
        return LocalRecognitionResult(
          success: false,
          message:
              'Detected food-related items ($genericLabels) but need more details. Please describe the specific food.',
          items: [],
          requiresManualInput: true,
        );
      }

      // Strategy 5: Not food at all
      return LocalRecognitionResult(
        success: false,
        message: 'No food detected in image. Please describe what you ate.',
        items: [],
        requiresManualInput: true,
      );
    } catch (e) {
      return LocalRecognitionResult(
        success: false,
        message: 'Failed to analyze image: $e',
        items: [],
      );
    }
  }

  /// Recognize with custom TFLite model (higher accuracy)
  /* Uncomment when using custom model:
  Future<LocalRecognitionResult> _recognizeWithCustomModel(File imageFile) async {
    try {
      // Preprocess image
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) {
        return LocalRecognitionResult(
          success: false,
          message: 'Failed to decode image',
          items: [],
        );
      }
      
      // Resize to model input size (224x224 for MobileNetV2)
      final resized = img.copyResize(image, width: 224, height: 224);
      
      // Convert to float32 tensor and normalize
      final input = List.generate(
        1,
        (batch) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );
      
      // Run inference
      final output = List.filled(1 * _customLabels!.length, 0.0).reshape([1, _customLabels!.length]);
      _customInterpreter!.run(input, output);
      
      // Get top predictions
      final predictions = <MapEntry<int, double>>[];
      for (int i = 0; i < _customLabels!.length; i++) {
        predictions.add(MapEntry(i, output[0][i]));
      }
      predictions.sort((a, b) => b.value.compareTo(a.value));
      
      // Filter by confidence threshold
      final recognizedItems = <RecognizedFoodItem>[];
      for (final pred in predictions.take(3)) {
        if (pred.value > 0.3) { // 30% confidence minimum
          recognizedItems.add(RecognizedFoodItem(
            name: _customLabels![pred.key],
            confidence: pred.value,
          ));
        }
      }
      
      if (recognizedItems.isEmpty) {
        return LocalRecognitionResult(
          success: false,
          message: 'Low confidence predictions. Please describe your food.',
          items: [],
          requiresManualInput: true,
        );
      }
      
      return LocalRecognitionResult(
        success: true,
        message: 'Detected ${recognizedItems.length} food item(s) with custom model',
        items: recognizedItems,
        requiresManualInput: false,
      );
      
    } catch (e) {
      print('Custom model inference failed: $e');
      // Fallback to ML Kit
      return _recognizeWithMLKit(imageFile);
    }
  }
  */

  /// Extract specific food items from labels
  List<RecognizedFoodItem> _extractSpecificFoods(List<ImageLabel> labels) {
    final specificFoods = <RecognizedFoodItem>[];

    for (final label in labels) {
      final foodName = _mapToSpecificFood(label.label, labels);
      if (foodName != null && !_isGenericLabel(label.label)) {
        specificFoods.add(RecognizedFoodItem(
          name: foodName,
          confidence: label.confidence,
        ));
      }
    }

    // Remove duplicates and sort by confidence
    final seen = <String>{};
    return specificFoods
        .where((item) => seen.add(item.name.toLowerCase()))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  /// Try to infer specific food from generic context
  List<RecognizedFoodItem> _inferFoodFromContext(List<ImageLabel> labels) {
    final inferred = <RecognizedFoodItem>[];
    final labelTexts = labels.map((l) => l.label.toLowerCase()).toSet();

    // Enhanced inference rules with more combinations
    final inferenceRules = {
      ['pasta', 'noodle']: 'Pasta',
      ['rice', 'grain']: 'Rice',
      ['bread', 'baked goods']: 'Bread',
      ['vegetable', 'salad']: 'Salad',
      ['meat', 'protein']: 'Meat',
      ['chicken']: 'Chicken',
      ['fish', 'seafood']: 'Fish',
      ['egg']: 'Eggs',
      ['pizza']: 'Pizza',
      ['burger', 'sandwich']: 'Burger',
      ['soup', 'liquid']: 'Soup',
      ['dessert', 'sweet']: 'Dessert',
      ['fruit']: 'Fruits',
    };

    for (final entry in inferenceRules.entries) {
      if (entry.key.any((keyword) => labelTexts.contains(keyword))) {
        final matchingLabel = labels.firstWhere(
          (l) => entry.key.any((kw) => l.label.toLowerCase().contains(kw)),
        );
        inferred.add(RecognizedFoodItem(
          name: entry.value,
          confidence: matchingLabel.confidence,
        ));
      }
    }

    return inferred;
  }

  /// Map ML Kit label to specific food name (expanded database)
  String? _mapToSpecificFood(String label, List<ImageLabel> allLabels) {
    final lower = label.toLowerCase();

    // Comprehensive food mapping (200+ items)
    final directFoods = {
      // ... (keep all existing mappings from previous version)
      // Add more Indian regional foods
      'chole': 'Chole Bhature',
      'puri': 'Puri',
      'bhaji': 'Pav Bhaji',
      'upma': 'Upma',
      'poha': 'Poha',
      'dhokla': 'Dhokla',
      'kachori': 'Kachori',
      'momos': 'Momos',
      // Add more specific categories...
    };

    // Check direct mappings
    for (final entry in directFoods.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Check if label is too generic
  bool _isGenericLabel(String label) {
    final genericTerms = [
      'food',
      'dish',
      'meal',
      'cuisine',
      'ingredient',
      'recipe',
      'plate',
      'bowl',
      'table',
      'eating',
      'dining',
      'tableware',
      'dishware',
      'cutlery',
      'utensil',
      'serving',
      'platter',
      'container',
      'produce',
      'vegetable',
      'staple food',
      'fast food',
      'junk food',
      'comfort food',
      'snack food',
      'natural foods',
      'whole food',
      'superfood',
      'animal product',
      'plant',
      'leaf vegetable',
      'root vegetable',
      'baked goods',
      'dairy product',
      'grain',
      'legume',
      'seafood',
    ];
    final lowerLabel = label.toLowerCase().trim();
    return genericTerms
        .any((term) => lowerLabel == term || lowerLabel == '${term}s');
  }

  /// Check if label is food-related
  bool _isFoodRelated(String label) {
    final foodKeywords = [
      // ... (keep all existing keywords from previous version)
      // Add more keywords for better detection
    ];

    final lowerLabel = label.toLowerCase();
    return foodKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  /// Clean up resources
  void dispose() {
    _imageLabeler.close();
    // Uncomment when using custom model:
    // _customInterpreter?.close();
  }
}

// Keep existing model classes
class LocalRecognitionResult {
  final bool success;
  final String message;
  final List<RecognizedFoodItem> items;
  final bool requiresManualInput;

  LocalRecognitionResult({
    required this.success,
    required this.message,
    required this.items,
    this.requiresManualInput = false,
  });
}

class RecognizedFoodItem {
  final String name;
  final double confidence;

  RecognizedFoodItem({
    required this.name,
    required this.confidence,
  });

  String toDisplayString() {
    return '$name (${(confidence * 100).toStringAsFixed(0)}% confident)';
  }
}
