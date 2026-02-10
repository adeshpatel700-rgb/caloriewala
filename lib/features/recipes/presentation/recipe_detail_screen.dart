import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/animations/staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_components.dart';
import '../../analysis/data/models/food_item_model.dart';
import '../../analysis/presentation/result_screen.dart';
import '../../dashboard/data/models/meal_log_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../dashboard/presentation/widgets/meal_category_selector.dart';
import '../data/models/recipe_model.dart';
import 'create_recipe_screen.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context)
                  .push(
                PageTransitions.slideFromRight(
                  CreateRecipeScreen(existingRecipe: recipe),
                ),
              )
                  .then((_) {
                // Recipe might have been edited
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe header
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.8),
                              AppColors.primary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${recipe.servings} Servings',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            if (recipe.usageCount > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Used ${recipe.usageCount} times',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Nutrition summary (per serving)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition Per Serving',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _NutritionCard(
                          label: 'Calories',
                          value: recipe.caloriesPerServing.toInt().toString(),
                          color: AppColors.primary,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Expanded(
                        child: _NutritionCard(
                          label: 'Protein',
                          value: '${recipe.proteinPerServing.toInt()}g',
                          color: AppColors.protein,
                          icon: Icons.fitness_center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _NutritionCard(
                          label: 'Carbs',
                          value: '${recipe.carbsPerServing.toInt()}g',
                          color: AppColors.carbs,
                          icon: Icons.grain,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Expanded(
                        child: _NutritionCard(
                          label: 'Fat',
                          value: '${recipe.fatPerServing.toInt()}g',
                          color: AppColors.fat,
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Ingredients
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.checklist,
                        size: AppDimensions.iconMd,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Text(
                        'Ingredients',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  ...recipe.ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return StaggeredListAnimation(
                      position: index,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.xs,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.xs),
                            Expanded(
                              child: Text(
                                '${ingredient.foodName} (${ingredient.portion})',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${ingredient.calories.toInt()} cal',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            if (recipe.instructions != null) ...[
              const SizedBox(height: AppDimensions.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: AppDimensions.iconMd,
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Text(
                          'Instructions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      recipe.instructions!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.md),

            // Action buttons
            ScaleOnTap(
              child: FilledButton.icon(
                onPressed: () => _useRecipeForLogging(context, ref),
                icon: const Icon(Icons.restaurant),
                label: const Text('Log This Recipe'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.sm),

            ScaleOnTap(
              child: OutlinedButton.icon(
                onPressed: () => _quickLogRecipe(context, ref),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Quick Add to Today'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _useRecipeForLogging(BuildContext context, WidgetRef ref) {
    // Convert recipe to food items for the result screen
    final foodItems = [
      FoodItemModel(
        name: recipe.name,
        portion: '1 serving',
      ),
    ];

    // Increment usage count
    ref.read(storageServiceProvider).incrementRecipeUsage(recipe.id);

    Navigator.of(context).push(
      PageTransitions.slideFromRight(ResultScreen(foodItems: foodItems)),
    );
  }

  Future<void> _quickLogRecipe(BuildContext context, WidgetRef ref) async {
    final category = await MealCategorySelector.show(context);
    if (category != null) {
      // Save meal directly with recipe nutrition info
      final meal = MealLogModel(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        mealCategory: category,
        foodItems: [recipe.name],
        totalCalories: recipe.caloriesPerServing,
        proteinGrams: recipe.proteinPerServing,
        carbsGrams: recipe.carbsPerServing,
        fatGrams: recipe.fatPerServing,
        isFavorite: false,
      );

      await ref.read(storageServiceProvider).saveMeal(meal);

      // Increment usage count
      await ref.read(storageServiceProvider).incrementRecipeUsage(recipe.id);

      // Refresh dashboard
      ref.invalidate(dailyMealsProvider);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipe.name} added to $category'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingSm,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
