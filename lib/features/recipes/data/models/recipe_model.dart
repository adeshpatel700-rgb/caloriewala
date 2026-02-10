import 'package:uuid/uuid.dart';

/// Model for recipe ingredient
class RecipeIngredientModel {
  final String foodName;
  final String portion; // e.g., "2 cups", "100g", "1 medium"
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  RecipeIngredientModel({
    required this.foodName,
    required this.portion,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'portion': portion,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
    };
  }

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      foodName: json['foodName'] as String,
      portion: json['portion'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinGrams: (json['proteinGrams'] as num).toDouble(),
      carbsGrams: (json['carbsGrams'] as num).toDouble(),
      fatGrams: (json['fatGrams'] as num).toDouble(),
    );
  }
}

/// Model for saved recipes
class RecipeModel {
  final String id;
  final String name;
  final List<RecipeIngredientModel> ingredients;
  final int servings;
  final String? instructions; // Optional cooking instructions
  final String? imageUrl; // Optional recipe image
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int usageCount; // How many times this recipe was logged
  final bool isFavorite;

  RecipeModel({
    String? id,
    required this.name,
    required this.ingredients,
    required this.servings,
    this.instructions,
    this.imageUrl,
    DateTime? createdAt,
    this.lastUsedAt,
    this.usageCount = 0,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Calculate total nutrition for entire recipe
  double get totalCalories =>
      ingredients.fold(0, (sum, ing) => sum + ing.calories);

  double get totalProtein =>
      ingredients.fold(0, (sum, ing) => sum + ing.proteinGrams);

  double get totalCarbs =>
      ingredients.fold(0, (sum, ing) => sum + ing.carbsGrams);

  double get totalFat => ingredients.fold(0, (sum, ing) => sum + ing.fatGrams);

  // Nutrition per serving
  double get caloriesPerServing => totalCalories / servings;
  double get proteinPerServing => totalProtein / servings;
  double get carbsPerServing => totalCarbs / servings;
  double get fatPerServing => totalFat / servings;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'servings': servings,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'usageCount': usageCount,
      'isFavorite': isFavorite,
    };
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ingredients: (json['ingredients'] as List)
          .map((i) => RecipeIngredientModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      servings: json['servings'] as int,
      instructions: json['instructions'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      usageCount: json['usageCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  RecipeModel copyWith({
    String? id,
    String? name,
    List<RecipeIngredientModel>? ingredients,
    int? servings,
    String? instructions,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? usageCount,
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      servings: servings ?? this.servings,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
