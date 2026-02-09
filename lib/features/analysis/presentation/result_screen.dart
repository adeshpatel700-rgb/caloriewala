import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/staggered_animations.dart';
import '../data/models/food_item_model.dart';
import 'providers/analysis_provider.dart';
import '../../dashboard/data/models/meal_log_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../dashboard/presentation/widgets/meal_category_selector.dart';

/// Result screen displaying nutrition information
class ResultScreen extends ConsumerStatefulWidget {
  final List<FoodItemModel> foodItems;

  const ResultScreen({
    super.key,
    required this.foodItems,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Calculate nutrition on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionProvider.notifier).calculateNutrition(widget.foodItems);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Results'),
      ),
      body: SafeArea(
        child: nutritionState.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calculating nutrition...'),
                  ],
                ),
              )
            : nutritionState.error != null
                ? _ErrorView(
                    error: nutritionState.error!,
                    onRetry: () {
                      ref
                          .read(nutritionProvider.notifier)
                          .calculateNutrition(widget.foodItems);
                    },
                  )
                : nutritionState.nutrition != null
                    ? _SuccessView(
                        nutrition: nutritionState.nutrition!,
                        foodItems: widget.foodItems,
                        animation: _animationController,
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  final dynamic nutrition;
  final List<FoodItemModel> foodItems;
  final AnimationController animation;

  const _SuccessView({
    required this.nutrition,
    required this.foodItems,
    required this.animation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calorie Display
          _CalorieCard(
            calories: nutrition.totalCalories,
            animation: animation,
          ),

          const SizedBox(height: 24),

          // Macros Breakdown
          _MacrosCard(
            protein: nutrition.proteinGrams,
            carbs: nutrition.carbsGrams,
            fat: nutrition.fatGrams,
            proteinPercent: nutrition.toEntity().proteinPercentage,
            carbsPercent: nutrition.toEntity().carbsPercentage,
            fatPercent: nutrition.toEntity().fatPercentage,
            animation: animation,
          ),

          const SizedBox(height: 24),

          // Health Note
          _HealthNoteCard(healthNote: nutrition.healthNote),

          const SizedBox(height: 24),

          // Food Items Summary
          _FoodItemsSummary(foodItems: foodItems),

          const SizedBox(height: 24),

          // Disclaimer
          _DisclaimerCard(disclaimer: nutrition.disclaimer),

          const SizedBox(height: 24),

          // Action Buttons
          ScaleOnTap(
            child: ElevatedButton.icon(
              onPressed: () async {
                final category = await MealCategorySelector.show(context);
                if (category != null && context.mounted) {
                  await _saveMeal(
                    context,
                    category,
                    ref,
                    nutrition,
                    foodItems,
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Meal'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          ScaleOnTap(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Analyze Another'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieCard extends StatelessWidget {
  final double calories;
  final AnimationController animation;

  const _CalorieCard({
    required this.calories,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Calories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(calories * animation.value).toInt()}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'kcal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MacrosCard extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final AnimationController animation;

  const _MacrosCard({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _MacroRow(
              label: 'Protein',
              value: protein,
              unit: 'g',
              percentage: proteinPercent,
              color: const Color(0xFFE57373),
              animation: animation,
            ),
            const SizedBox(height: 16),
            _MacroRow(
              label: 'Carbs',
              value: carbs,
              unit: 'g',
              percentage: carbsPercent,
              color: const Color(0xFF81C784),
              animation: animation,
            ),
            const SizedBox(height: 16),
            _MacroRow(
              label: 'Fat',
              value: fat,
              unit: 'g',
              percentage: fatPercent,
              color: const Color(0xFFFFB74D),
              animation: animation,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double percentage;
  final Color color;
  final AnimationController animation;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.percentage,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit (${percentage.toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100) * animation.value,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HealthNoteCard extends StatelessWidget {
  final String healthNote;

  const _HealthNoteCard({required this.healthNote});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                healthNote,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodItemsSummary extends StatelessWidget {
  final List<FoodItemModel> foodItems;

  const _FoodItemsSummary({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Meal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...foodItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.name} - ${item.portion}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  final String disclaimer;

  const _DisclaimerCard({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              disclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to save meal
Future<void> _saveMeal(
  BuildContext context,
  String category,
  WidgetRef ref,
  dynamic nutrition,
  List<FoodItemModel> foodItems,
) async {
  try {
    final storageService = ref.read(storageServiceProvider);

    final mealLog = MealLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      mealCategory: category,
      foodItems: foodItems.map((item) => item.name).toList(),
      totalCalories: nutrition.totalCalories,
      proteinGrams: nutrition.proteinGrams,
      carbsGrams: nutrition.carbsGrams,
      fatGrams: nutrition.fatGrams,
      imageBase64: null, // We can add image capture later
      notes: '',
      isFavorite: false,
      favoriteName: null,
    );

    await storageService.saveMeal(mealLog);

    // Invalidate providers to refresh dashboard and history
    ref.invalidate(dailyMealsProvider);
    ref.invalidate(dailyStatsProvider);
    ref.invalidate(weeklyStatsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Meal saved to $category!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Dashboard',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
