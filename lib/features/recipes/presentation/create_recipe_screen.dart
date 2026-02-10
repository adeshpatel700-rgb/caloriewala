import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_components.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../data/models/recipe_model.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel? existingRecipe;

  const CreateRecipeScreen({super.key, this.existingRecipe});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  final _instructionsController = TextEditingController();
  final List<RecipeIngredientModel> _ingredients = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      _nameController.text = widget.existingRecipe!.name;
      _servingsController.text = widget.existingRecipe!.servings.toString();
      _instructionsController.text = widget.existingRecipe!.instructions ?? '';
      _ingredients.addAll(widget.existingRecipe!.ingredients);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingRecipe != null ? 'Edit Recipe' : 'Create Recipe',
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppDimensions.paddingMd,
          children: [
            // Recipe name
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipe Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      hintText: 'e.g., Chicken Biryani',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Servings',
                      hintText: '4',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(value!) == null) return 'Enter a number';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Ingredients section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Ingredients',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _showAddIngredientDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_ingredients.isEmpty) ...[
                    const SizedBox(height: AppDimensions.md),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            'No ingredients added yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppDimensions.sm),
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      return StaggeredListAnimation(
                        position: index,
                        child: _IngredientTile(
                          ingredient: ingredient,
                          onDelete: () => setState(() {
                            _ingredients.removeAt(index);
                          }),
                        ),
                      );
                    }),
                    const SizedBox(height: AppDimensions.sm),
                    _NutritionSummary(ingredients: _ingredients),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Instructions (optional)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      hintText: 'Add cooking instructions...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddIngredientDialog() async {
    final nameController = TextEditingController();
    final portionController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    final result = await showDialog<RecipeIngredientModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g., Chicken Breast',
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextField(
                controller: portionController,
                decoration: const InputDecoration(
                  labelText: 'Portion',
                  hintText: 'e.g., 200g or 2 cups',
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  hintText: '165',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: TextField(
                      controller: fatController,
                      decoration: const InputDecoration(
                        labelText: 'Fat (g)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  caloriesController.text.isNotEmpty) {
                final ingredient = RecipeIngredientModel(
                  foodName: nameController.text,
                  portion: portionController.text,
                  calories: double.tryParse(caloriesController.text) ?? 0,
                  proteinGrams: double.tryParse(proteinController.text) ?? 0,
                  carbsGrams: double.tryParse(carbsController.text) ?? 0,
                  fatGrams: double.tryParse(fatController.text) ?? 0,
                );
                Navigator.pop(context, ingredient);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final recipe = RecipeModel(
      id: widget.existingRecipe?.id,
      name: _nameController.text,
      ingredients: _ingredients,
      servings: int.parse(_servingsController.text),
      instructions: _instructionsController.text.isEmpty
          ? null
          : _instructionsController.text,
      isFavorite: widget.existingRecipe?.isFavorite ?? false,
      usageCount: widget.existingRecipe?.usageCount ?? 0,
    );

    await ref.read(storageServiceProvider).saveRecipe(recipe);
    ref.invalidate(recipesProvider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingRecipe != null ? 'Recipe updated' : 'Recipe created',
          ),
        ),
      );
    }
  }
}

class _IngredientTile extends StatelessWidget {
  final RecipeIngredientModel ingredient;
  final VoidCallback onDelete;

  const _IngredientTile({
    required this.ingredient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: ListTile(
        title: Text(ingredient.foodName),
        subtitle: Text(
          '${ingredient.portion} • ${ingredient.calories.toInt()} cal',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final List<RecipeIngredientModel> ingredients;

  const _NutritionSummary({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        ingredients.fold<double>(0, (sum, i) => sum + i.calories);
    final totalProtein =
        ingredients.fold<double>(0, (sum, i) => sum + i.proteinGrams);
    final totalCarbs =
        ingredients.fold<double>(0, (sum, i) => sum + i.carbsGrams);
    final totalFat = ingredients.fold<double>(0, (sum, i) => sum + i.fatGrams);

    return Container(
      padding: AppDimensions.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Nutrition',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              _NutrientBadge(
                label: 'Calories',
                value: totalCalories.toInt().toString(),
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.xs),
              _NutrientBadge(
                label: 'Protein',
                value: '${totalProtein.toInt()}g',
                color: AppColors.protein,
              ),
              const SizedBox(width: AppDimensions.xs),
              _NutrientBadge(
                label: 'Carbs',
                value: '${totalCarbs.toInt()}g',
                color: AppColors.carbs,
              ),
              const SizedBox(width: AppDimensions.xs),
              _NutrientBadge(
                label: 'Fat',
                value: '${totalFat.toInt()}g',
                color: AppColors.fat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutrientBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
