import 'package:hive/hive.dart';

part 'calorie_goal_model.g.dart';

@HiveType(typeId: 1)
class CalorieGoalModel extends HiveObject {
  @HiveField(0)
  final double dailyCalorieGoal;

  @HiveField(1)
  final double proteinGoal;

  @HiveField(2)
  final double carbsGoal;

  @HiveField(3)
  final double fatGoal;

  @HiveField(4)
  final String goalType; // weight_loss, weight_gain, maintain

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final double? currentWeight;

  @HiveField(7)
  final double? targetWeight;

  @HiveField(8)
  final double? heightCm;

  @HiveField(9)
  final int? age;

  @HiveField(10)
  final String? gender; // male, female, other

  @HiveField(11)
  final String?
      activityLevel; // sedentary, light, moderate, active, very_active

  CalorieGoalModel({
    required this.dailyCalorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.goalType,
    required this.createdAt,
    this.currentWeight,
    this.targetWeight,
    this.heightCm,
    this.age,
    this.gender,
    this.activityLevel,
  });

  double get bmi {
    if (currentWeight == null || heightCm == null) return 0;
    final heightM = heightCm! / 100;
    return currentWeight! / (heightM * heightM);
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }
}
