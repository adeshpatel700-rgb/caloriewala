import 'package:uuid/uuid.dart';

/// Model for tracking water intake
class WaterLogModel {
  final String id;
  final DateTime timestamp;
  final int milliliters; // Amount of water in ml
  final String? note; // Optional note (e.g., "Glass", "Bottle")

  WaterLogModel({
    String? id,
    required this.timestamp,
    required this.milliliters,
    this.note,
  }) : id = id ?? const Uuid().v4();

  // Preset amounts
  static const int smallGlass = 200; // 200ml
  static const int mediumGlass = 250; // 250ml
  static const int largeGlass = 350; // 350ml
  static const int bottle = 500; // 500ml
  static const int largeBotlle = 1000; // 1L

  // Daily goal (recommended)
  static const int dailyGoalMl = 2500; // 2.5L recommended

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'milliliters': milliliters,
      'note': note,
    };
  }

  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      milliliters: json['milliliters'] as int,
      note: json['note'] as String?,
    );
  }

  // Helper method to get formatted amount
  String getFormattedAmount() {
    if (milliliters >= 1000) {
      return '${(milliliters / 1000).toStringAsFixed(1)}L';
    }
    return '${milliliters}ml';
  }

  // Copy with method
  WaterLogModel copyWith({
    String? id,
    DateTime? timestamp,
    int? milliliters,
    String? note,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      milliliters: milliliters ?? this.milliliters,
      note: note ?? this.note,
    );
  }
}
