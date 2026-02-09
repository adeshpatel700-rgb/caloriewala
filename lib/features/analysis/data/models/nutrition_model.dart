import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/nutrition_info.dart';

part 'nutrition_model.g.dart';

/// Data model for NutritionInfo with JSON serialization
@JsonSerializable()
class NutritionModel {
  @JsonKey(name: 'total_calories')
  final double totalCalories;
  @JsonKey(name: 'protein_g')
  final double proteinGrams;
  @JsonKey(name: 'carbs_g')
  final double carbsGrams;
  @JsonKey(name: 'fat_g')
  final double fatGrams;
  @JsonKey(name: 'health_note')
  final String healthNote;
  final String disclaimer;

  const NutritionModel({
    required this.totalCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.healthNote,
    required this.disclaimer,
  });

  /// Convert to domain entity
  NutritionInfo toEntity() {
    return NutritionInfo(
      totalCalories: totalCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      healthNote: healthNote,
      disclaimer: disclaimer,
    );
  }

  /// Create from domain entity
  factory NutritionModel.fromEntity(NutritionInfo entity) {
    return NutritionModel(
      totalCalories: entity.totalCalories,
      proteinGrams: entity.proteinGrams,
      carbsGrams: entity.carbsGrams,
      fatGrams: entity.fatGrams,
      healthNote: entity.healthNote,
      disclaimer: entity.disclaimer,
    );
  }

  factory NutritionModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionModelFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionModelToJson(this);
}
