import 'package:equatable/equatable.dart';

/// Represents a single food item detected or entered by user
class FoodItem extends Equatable {
  final String name;
  final String? hindiName;
  final String portion;
  final String confidence; // 'high', 'medium', 'low'

  const FoodItem({
    required this.name,
    this.hindiName,
    required this.portion,
    this.confidence = 'medium',
  });

  /// Create a copy with modified fields
  FoodItem copyWith({
    String? name,
    String? hindiName,
    String? portion,
    String? confidence,
  }) {
    return FoodItem(
      name: name ?? this.name,
      hindiName: hindiName ?? this.hindiName,
      portion: portion ?? this.portion,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Convert to user-friendly display string
  String toDisplayString() {
    final nameDisplay = hindiName != null ? '$name ($hindiName)' : name;
    return '$nameDisplay - $portion';
  }

  @override
  List<Object?> get props => [name, hindiName, portion, confidence];

  @override
  String toString() => toDisplayString();
}
