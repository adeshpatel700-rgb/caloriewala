import 'package:equatable/equatable.dart';

/// Represents nutritional information for a meal
class NutritionInfo extends Equatable {
  final double totalCalories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String healthNote;
  final String disclaimer;

  const NutritionInfo({
    required this.totalCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.healthNote,
    required this.disclaimer,
  });

  /// Get protein percentage of total calories
  double get proteinPercentage {
    final proteinCalories = proteinGrams * 4; // 4 cal/g
    return totalCalories > 0 ? (proteinCalories / totalCalories) * 100 : 0;
  }

  /// Get carbs percentage of total calories
  double get carbsPercentage {
    final carbsCalories = carbsGrams * 4; // 4 cal/g
    return totalCalories > 0 ? (carbsCalories / totalCalories) * 100 : 0;
  }

  /// Get fat percentage of total calories
  double get fatPercentage {
    final fatCalories = fatGrams * 9; // 9 cal/g
    return totalCalories > 0 ? (fatCalories / totalCalories) * 100 : 0;
  }

  @override
  List<Object?> get props => [
        totalCalories,
        proteinGrams,
        carbsGrams,
        fatGrams,
        healthNote,
        disclaimer,
      ];
}
