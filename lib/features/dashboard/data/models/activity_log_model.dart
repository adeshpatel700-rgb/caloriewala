import 'package:hive/hive.dart';

part 'activity_log_model.g.dart';

@HiveType(typeId: 2)
class ActivityLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String activityType; // walking, running, cycling, gym, yoga, sports

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final double caloriesBurned;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final double? distance; // in km

  @HiveField(7)
  final int? steps;

  ActivityLogModel({
    required this.id,
    required this.timestamp,
    required this.activityType,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes,
    this.distance,
    this.steps,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'activityType': activityType,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'notes': notes,
        'distance': distance,
        'steps': steps,
      };

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      ActivityLogModel(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        activityType: json['activityType'],
        durationMinutes: json['durationMinutes'],
        caloriesBurned: json['caloriesBurned'].toDouble(),
        notes: json['notes'],
        distance: json['distance']?.toDouble(),
        steps: json['steps'],
      );
}
