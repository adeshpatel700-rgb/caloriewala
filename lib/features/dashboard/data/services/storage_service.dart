import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_log_model.dart';
import '../models/calorie_goal_model.dart';
import '../models/activity_log_model.dart';
import '../models/water_log_model.dart';
import '../../../recipes/data/models/recipe_model.dart';

class StorageService {
  static const String _mealsBoxName = 'meals';
  static const String _goalsBoxName = 'goals';
  static const String _activitiesBoxName = 'activities';

  static Future<void> init() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MealLogModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CalorieGoalModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ActivityLogModelAdapter());
      }

      // Open boxes
      await Hive.openBox<MealLogModel>(_mealsBoxName);
      await Hive.openBox<CalorieGoalModel>(_goalsBoxName);
      await Hive.openBox<ActivityLogModel>(_activitiesBoxName);
    } catch (e) {
      print('Error initializing storage: $e');
    }
  }

  // Meal operations
  Box<MealLogModel> get _mealsBox => Hive.box<MealLogModel>(_mealsBoxName);

  Future<void> saveMeal(MealLogModel meal) async {
    await _mealsBox.put(meal.id, meal);
  }

  Future<void> deleteMeal(String id) async {
    await _mealsBox.delete(id);
  }

  List<MealLogModel> getAllMeals() {
    return _mealsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MealLogModel> getMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _mealsBox.values
        .where((meal) =>
            meal.timestamp.isAfter(startOfDay) &&
            meal.timestamp.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MealLogModel> getMealsForDateRange(DateTime start, DateTime end) {
    return _mealsBox.values
        .where((meal) =>
            meal.timestamp.isAfter(start) && meal.timestamp.isBefore(end))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<MealLogModel> getFavoriteMeals() {
    return _mealsBox.values.where((meal) => meal.isFavorite).toList();
  }

  // Goal operations
  Box<CalorieGoalModel> get _goalsBox =>
      Hive.box<CalorieGoalModel>(_goalsBoxName);

  Future<void> saveGoal(CalorieGoalModel goal) async {
    await _goalsBox.put('current_goal', goal);
  }

  CalorieGoalModel? getCurrentGoal() {
    return _goalsBox.get('current_goal');
  }

  // Activity operations
  Box<ActivityLogModel> get _activitiesBox =>
      Hive.box<ActivityLogModel>(_activitiesBoxName);

  Future<void> saveActivity(ActivityLogModel activity) async {
    await _activitiesBox.put(activity.id, activity);
  }

  Future<void> deleteActivity(String id) async {
    await _activitiesBox.delete(id);
  }

  List<ActivityLogModel> getAllActivities() {
    return _activitiesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<ActivityLogModel> getActivitiesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _activitiesBox.values
        .where((activity) =>
            activity.timestamp.isAfter(startOfDay) &&
            activity.timestamp.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Stats
  Map<String, dynamic> getDailyStats(DateTime date) {
    final meals = getMealsForDate(date);
    final activities = getActivitiesForDate(date);

    final totalCaloriesConsumed =
        meals.fold<double>(0, (sum, meal) => sum + meal.totalCalories);
    final totalProtein =
        meals.fold<double>(0, (sum, meal) => sum + meal.proteinGrams);
    final totalCarbs =
        meals.fold<double>(0, (sum, meal) => sum + meal.carbsGrams);
    final totalFat = meals.fold<double>(0, (sum, meal) => sum + meal.fatGrams);
    final totalCaloriesBurned = activities.fold<double>(
        0, (sum, activity) => sum + activity.caloriesBurned);

    return {
      'consumed': totalCaloriesConsumed,
      'burned': totalCaloriesBurned,
      'net': totalCaloriesConsumed - totalCaloriesBurned,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'meals': meals.length,
      'activities': activities.length,
    };
  }

  List<Map<String, dynamic>> getWeeklyStats() {
    final today = DateTime.now();
    final stats = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      stats.add({
        'date': date,
        ...getDailyStats(date),
      });
    }

    return stats;
  }

  // Water intake operations
  static const String _waterLogsKey = 'water_logs';

  Future<void> saveWaterLog(WaterLogModel waterLog) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWaterLogs();
    logs.add(waterLog);
    final jsonList = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_waterLogsKey, jsonEncode(jsonList));
  }

  Future<void> deleteWaterLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWaterLogs();
    logs.removeWhere((log) => log.id == id);
    final jsonList = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_waterLogsKey, jsonEncode(jsonList));
  }

  Future<List<WaterLogModel>> getWaterLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_waterLogsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => WaterLogModel.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<WaterLogModel>> getWaterLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final allLogs = await getWaterLogs();
    return allLogs
        .where((log) =>
            log.timestamp.isAfter(startOfDay) &&
            log.timestamp.isBefore(endOfDay))
        .toList();
  }

  Future<int> getTotalWaterForDate(DateTime date) async {
    final logs = await getWaterLogsForDate(date);
    return logs.fold<int>(0, (sum, log) => sum + log.milliliters);
  }

  // Recipe operations
  static const String _recipesKey = 'recipes';

  Future<void> saveRecipe(RecipeModel recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();

    // Remove existing recipe with same ID if updating
    recipes.removeWhere((r) => r.id == recipe.id);
    recipes.add(recipe);

    final jsonList = recipes.map((r) => r.toJson()).toList();
    await prefs.setString(_recipesKey, jsonEncode(jsonList));
  }

  Future<void> deleteRecipe(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();
    recipes.removeWhere((r) => r.id == id);
    final jsonList = recipes.map((r) => r.toJson()).toList();
    await prefs.setString(_recipesKey, jsonEncode(jsonList));
  }

  Future<List<RecipeModel>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recipesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<RecipeModel>> getFavoriteRecipes() async {
    final recipes = await getRecipes();
    return recipes.where((r) => r.isFavorite).toList();
  }

  Future<RecipeModel?> getRecipeById(String id) async {
    final recipes = await getRecipes();
    try {
      return recipes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> incrementRecipeUsage(String id) async {
    final recipe = await getRecipeById(id);
    if (recipe != null) {
      final updated = recipe.copyWith(
        usageCount: recipe.usageCount + 1,
        lastUsedAt: DateTime.now(),
      );
      await saveRecipe(updated);
    }
  }
}
