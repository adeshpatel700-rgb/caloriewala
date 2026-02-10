import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meal_log_model.dart';
import '../../data/models/calorie_goal_model.dart';
import '../../data/models/activity_log_model.dart';
import '../../data/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Current goal provider
final currentGoalProvider = StateProvider<CalorieGoalModel?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getCurrentGoal();
});

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Daily meals provider
final dailyMealsProvider = Provider<List<MealLogModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return storage.getMealsForDate(selectedDate);
});

// Daily activities provider
final dailyActivitiesProvider = Provider<List<ActivityLogModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return storage.getActivitiesForDate(selectedDate);
});

// Daily stats provider
final dailyStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return storage.getDailyStats(selectedDate);
});

// Weekly stats provider
final weeklyStatsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getWeeklyStats();
});

// Favorite meals provider
final favoriteMealsProvider = Provider<List<MealLogModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFavoriteMeals();
});

// History provider (all meals)
final mealHistoryProvider = Provider<List<MealLogModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllMeals();
});

// Activity history provider
final activityHistoryProvider = Provider<List<ActivityLogModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllActivities();
});

// Daily water intake provider
final dailyWaterIntakeProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return await storage.getTotalWaterForDate(selectedDate);
});

// Water logs provider
final waterLogsProvider = FutureProvider((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getWaterLogs();
});

// Recipes provider
final recipesProvider = FutureProvider((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getRecipes();
});

// Favorite recipes provider
final favoriteRecipesProvider = FutureProvider((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getFavoriteRecipes();
});
