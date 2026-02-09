import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Local on-device food recognition using ML Kit
/// No API calls, completely free, works offline
class LocalFoodRecognizer {
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(
      confidenceThreshold: 0.6, // 60% confidence minimum for better accuracy
    ),
  );

  /// Recognize food items from image locally
  /// Returns list of detected items with confidence scores
  Future<LocalRecognitionResult> recognizeFood(File imageFile) async {
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
        // It's food but too generic - provide helpful context
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

    // Inference rules: combine generic labels to make specific suggestions
    if (labelTexts.contains('pasta') || labelTexts.contains('noodle')) {
      final conf = labels
          .firstWhere((l) =>
              l.label.toLowerCase().contains('pasta') ||
              l.label.toLowerCase().contains('noodle'))
          .confidence;
      inferred.add(RecognizedFoodItem(name: 'Pasta', confidence: conf));
    }

    if (labelTexts.contains('rice') || labelTexts.contains('grain')) {
      final conf = labels
          .firstWhere((l) =>
              l.label.toLowerCase().contains('rice') ||
              l.label.toLowerCase().contains('grain'))
          .confidence;
      inferred.add(RecognizedFoodItem(name: 'Rice', confidence: conf));
    }

    if (labelTexts.contains('bread') || labelTexts.contains('baked goods')) {
      final conf = labels
          .firstWhere((l) =>
              l.label.toLowerCase().contains('bread') ||
              l.label.toLowerCase().contains('baked'))
          .confidence;
      inferred.add(RecognizedFoodItem(name: 'Bread', confidence: conf));
    }

    if ((labelTexts.contains('vegetable') || labelTexts.contains('produce')) &&
        (labelTexts.contains('salad') || labelTexts.contains('greens'))) {
      inferred.add(RecognizedFoodItem(name: 'Salad', confidence: 0.7));
    }

    if (labelTexts.contains('meat') ||
        labelTexts.contains('chicken') ||
        labelTexts.contains('beef') ||
        labelTexts.contains('pork')) {
      final meatLabel = labels.firstWhere((l) =>
          l.label.toLowerCase().contains('meat') ||
          l.label.toLowerCase().contains('chicken') ||
          l.label.toLowerCase().contains('beef') ||
          l.label.toLowerCase().contains('pork'));
      inferred.add(RecognizedFoodItem(
          name: _capitalize(meatLabel.label),
          confidence: meatLabel.confidence));
    }

    return inferred;
  }

  /// Map ML Kit label to specific food name
  String? _mapToSpecificFood(String label, List<ImageLabel> allLabels) {
    final lower = label.toLowerCase();

    // Direct food mappings (specific items)
    final directFoods = {
      'pizza': 'Pizza',
      'burger': 'Burger',
      'sandwich': 'Sandwich',
      'salad': 'Salad',
      'soup': 'Soup',
      'pasta': 'Pasta',
      'noodle': 'Noodles',
      'rice': 'Rice',
      'biryani': 'Biryani',
      'curry': 'Curry',
      'chicken': 'Chicken',
      'fish': 'Fish',
      'steak': 'Steak',
      'egg': 'Eggs',
      'omelette': 'Omelette',
      'pancake': 'Pancakes',
      'waffle': 'Waffles',
      'toast': 'Toast',
      'cereal': 'Cereal',
      'yogurt': 'Yogurt',
      'smoothie': 'Smoothie',
      'juice': 'Juice',
      'coffee': 'Coffee',
      'tea': 'Tea',
      'cake': 'Cake',
      'cookie': 'Cookies',
      'chocolate': 'Chocolate',
      'ice cream': 'Ice Cream',
      'fruit': 'Fruits',
      'apple': 'Apple',
      'banana': 'Banana',
      'orange': 'Orange',
      'strawberry': 'Strawberries',
      'grapes': 'Grapes',
      'watermelon': 'Watermelon',
      // Indian foods
      'dosa': 'Dosa',
      'idli': 'Idli',
      'vada': 'Vada',
      'samosa': 'Samosa',
      'pakora': 'Pakora',
      'paratha': 'Paratha',
      'roti': 'Roti',
      'naan': 'Naan',
      'chapati': 'Chapati',
      'dal': 'Dal',
      'paneer': 'Paneer',
      'tandoori': 'Tandoori',
      'kebab': 'Kebab',
      'tikka': 'Tikka',
      'masala': 'Masala',
      'korma': 'Korma',
      'vindaloo': 'Vindaloo',
      'chutney': 'Chutney',
      'raita': 'Raita',
      'gulab jamun': 'Gulab Jamun',
      'jalebi': 'Jalebi',
      'ladoo': 'Ladoo',
      'halwa': 'Halwa',
    };

    // Check direct mappings
    for (final entry in directFoods.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Category-based inference (if we see category + specific type)
    if (lower.contains('bread') || lower.contains('baked')) {
      return 'Bread';
    }

    if (lower.contains('meat') && !_isGenericLabel(label)) {
      return 'Meat';
    }

    return null;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Check if label is too generic to be useful
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
      'produce', // too generic
      'vegetable', // too generic without specific type
      'staple food', // too generic
      'fast food', // category, not specific
      'junk food', // category
      'comfort food', // category
      'snack food', // category
      'natural foods', // too vague
      'whole food', // too vague
      'superfood', // marketing term
      'animal product', // too generic
      'plant', // not specific enough
      'leaf vegetable', // need specifics
      'root vegetable', // need specifics
      'baked goods', // need specifics
      'dairy product', // need specifics
      'grain', // too generic
      'legume', // too generic
      'seafood', // too generic
    ];
    final lowerLabel = label.toLowerCase().trim();
    return genericTerms
        .any((term) => lowerLabel == term || lowerLabel == '${term}s');
  }

  /// Check if label is food-related
  bool _isFoodRelated(String label) {
    final foodKeywords = [
      'food',
      'dish',
      'meal',
      'cuisine',
      'bread',
      'rice',
      'meat',
      'chicken',
      'fish',
      'vegetable',
      'fruit',
      'salad',
      'soup',
      'curry',
      'pasta',
      'pizza',
      'burger',
      'sandwich',
      'dessert',
      'cake',
      'snack',
      'beverage',
      'drink',
      'plate',
      'bowl',
      'breakfast',
      'lunch',
      'dinner',
      'eating',
      'cooked',
      'fried',
      'baked',
      'grilled',
      'roasted',
      'steamed',
      'boiled',
      'raw',
      // Indian foods
      'roti',
      'chapati',
      'naan',
      'paratha',
      'dosa',
      'idli',
      'biryani',
      'dal',
      'sabzi',
      'paneer',
      'samosa',
      'pakora',
      'chutney',
      'raita',
      'tandoori',
      'masala',
      'tikka',
      'kebab',
      'korma',
      'vindaloo',
      // Western foods
      'steak',
      'bacon',
      'sausage',
      'egg',
      'cheese',
      'butter',
      'cream',
      'milk',
      'yogurt',
      // Asian foods
      'noodle',
      'sushi',
      'ramen',
      'dumpling',
      'wonton',
      'tempura',
      'tofu',
      'kimchi',
      // Mexican foods
      'taco',
      'burrito',
      'quesadilla',
      'enchilada',
      'salsa',
      'guacamole',
      // Italian foods
      'spaghetti',
      'lasagna',
      'ravioli',
      'risotto',
      'gnocchi',
      // Fruits and vegetables
      'apple',
      'banana',
      'orange',
      'tomato',
      'potato',
      'carrot',
      'onion',
      'garlic',
      'spinach',
      'broccoli',
      'lettuce',
      'cucumber',
      // Common categories
      'cereal',
      'oatmeal',
      'porridge',
      'pancake',
      'waffle',
      'muffin',
      'croissant',
      'bagel',
      'cookie',
      'brownie',
      'doughnut',
      'ice cream',
      'pudding',
    ];

    final lowerLabel = label.toLowerCase();
    return foodKeywords.any((keyword) => lowerLabel.contains(keyword));
  }

  /// Clean up resources
  void dispose() {
    _imageLabeler.close();
  }
}

/// Result of local food recognition
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

/// A single recognized food item with confidence
class RecognizedFoodItem {
  final String name;
  final double confidence;

  RecognizedFoodItem({
    required this.name,
    required this.confidence,
  });

  /// Convert to display string with confidence percentage
  String toDisplayString() {
    return '$name (${(confidence * 100).toStringAsFixed(0)}% confident)';
  }
}
