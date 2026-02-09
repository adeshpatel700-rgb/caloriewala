import 'package:hive/hive.dart';

part 'meal_log_model.g.dart';

@HiveType(typeId: 0)
class MealLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String mealCategory; // breakfast, lunch, dinner, snack

  @HiveField(3)
  final List<String> foodItems;

  @HiveField(4)
  final double totalCalories;

  @HiveField(5)
  final double proteinGrams;

  @HiveField(6)
  final double carbsGrams;

  @HiveField(7)
  final double fatGrams;

  @HiveField(8)
  final String? imageBase64;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final bool isFavorite;

  @HiveField(11)
  final String? favoriteName;

  MealLogModel({
    required this.id,
    required this.timestamp,
    required this.mealCategory,
    required this.foodItems,
    required this.totalCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.imageBase64,
    this.notes,
    this.isFavorite = false,
    this.favoriteName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'mealCategory': mealCategory,
        'foodItems': foodItems,
        'totalCalories': totalCalories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'imageBase64': imageBase64,
        'notes': notes,
        'isFavorite': isFavorite,
        'favoriteName': favoriteName,
      };

  factory MealLogModel.fromJson(Map<String, dynamic> json) => MealLogModel(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        mealCategory: json['mealCategory'],
        foodItems: List<String>.from(json['foodItems']),
        totalCalories: json['totalCalories'].toDouble(),
        proteinGrams: json['proteinGrams'].toDouble(),
        carbsGrams: json['carbsGrams'].toDouble(),
        fatGrams: json['fatGrams'].toDouble(),
        imageBase64: json['imageBase64'],
        notes: json['notes'],
        isFavorite: json['isFavorite'] ?? false,
        favoriteName: json['favoriteName'],
      );
}
