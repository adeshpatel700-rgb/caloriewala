import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/groq_api_service.dart';
import '../../data/models/food_item_model.dart';
import '../../data/models/nutrition_model.dart';
import '../../../../core/errors/exceptions.dart';

// Provider for Groq API service
final groqApiServiceProvider = Provider<GroqApiService>((ref) {
  return GroqApiService();
});

// State for image analysis
class ImageAnalysisState {
  final bool isLoading;
  final List<FoodItemModel>? foodItems;
  final String? error;

  const ImageAnalysisState({
    this.isLoading = false,
    this.foodItems,
    this.error,
  });

  ImageAnalysisState copyWith({
    bool? isLoading,
    List<FoodItemModel>? foodItems,
    String? error,
  }) {
    return ImageAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      foodItems: foodItems ?? this.foodItems,
      error: error,
    );
  }
}

// Provider for image analysis
class ImageAnalysisNotifier extends StateNotifier<ImageAnalysisState> {
  final GroqApiService _apiService;

  ImageAnalysisNotifier(this._apiService) : super(const ImageAnalysisState());

  Future<void> analyzeImage(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final foodItems = await _apiService.analyzeImage(imageFile);
      state = state.copyWith(
        isLoading: false,
        foodItems: foodItems,
      );
    } on ValidationException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Analyze food from text description
  Future<void> analyzeText(String description) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final foodItems = await _apiService.analyzeTextDescription(description);
      state = state.copyWith(
        isLoading: false,
        foodItems: foodItems,
      );
    } on ValidationException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void updateFoodItem(int index, FoodItemModel updatedItem) {
    if (state.foodItems != null) {
      final updatedList = List<FoodItemModel>.from(state.foodItems!);
      updatedList[index] = updatedItem;
      state = state.copyWith(foodItems: updatedList);
    }
  }

  void removeFoodItem(int index) {
    if (state.foodItems != null) {
      final updatedList = List<FoodItemModel>.from(state.foodItems!);
      updatedList.removeAt(index);
      state = state.copyWith(foodItems: updatedList);
    }
  }

  void addFoodItem(FoodItemModel item) {
    final currentItems = state.foodItems ?? [];
    state = state.copyWith(
      foodItems: [...currentItems, item],
    );
  }
}

final imageAnalysisProvider =
    StateNotifierProvider<ImageAnalysisNotifier, ImageAnalysisState>((ref) {
  final apiService = ref.watch(groqApiServiceProvider);
  return ImageAnalysisNotifier(apiService);
});

// State for nutrition calculation
class NutritionState {
  final bool isLoading;
  final NutritionModel? nutrition;
  final String? error;

  const NutritionState({
    this.isLoading = false,
    this.nutrition,
    this.error,
  });

  NutritionState copyWith({
    bool? isLoading,
    NutritionModel? nutrition,
    String? error,
  }) {
    return NutritionState(
      isLoading: isLoading ?? this.isLoading,
      nutrition: nutrition ?? this.nutrition,
      error: error,
    );
  }
}

// Provider for nutrition calculation
class NutritionNotifier extends StateNotifier<NutritionState> {
  final GroqApiService _apiService;

  NutritionNotifier(this._apiService) : super(const NutritionState());

  Future<void> calculateNutrition(List<FoodItemModel> foodItems) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final nutrition = await _apiService.calculateNutrition(foodItems);
      state = state.copyWith(
        isLoading: false,
        nutrition: nutrition,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void reset() {
    state = const NutritionState();
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final apiService = ref.watch(groqApiServiceProvider);
  return NutritionNotifier(apiService);
});
