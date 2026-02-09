import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/food_item.dart';

part 'food_item_model.g.dart';

/// Data model for FoodItem with JSON serialization
@JsonSerializable()
class FoodItemModel {
  final String name;
  @JsonKey(name: 'hindi_name')
  final String? hindiName;
  final String portion;
  final String confidence;

  const FoodItemModel({
    required this.name,
    this.hindiName,
    required this.portion,
    this.confidence = 'medium',
  });

  /// Convert to domain entity
  FoodItem toEntity() {
    return FoodItem(
      name: name,
      hindiName: hindiName,
      portion: portion,
      confidence: confidence,
    );
  }

  /// Create from domain entity
  factory FoodItemModel.fromEntity(FoodItem entity) {
    return FoodItemModel(
      name: entity.name,
      hindiName: entity.hindiName,
      portion: entity.portion,
      confidence: entity.confidence,
    );
  }

  factory FoodItemModel.fromJson(Map<String, dynamic> json) =>
      _$FoodItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemModelToJson(this);
}
