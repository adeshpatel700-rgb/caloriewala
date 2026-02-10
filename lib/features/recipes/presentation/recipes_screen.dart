import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/animations/staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_components.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../data/models/recipe_model.dart';
import 'create_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        elevation: 0,
        scrolledUnderElevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'All Recipes'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: recipesAsync.when(
        data: (recipes) {
          final favoriteRecipes = recipes.where((r) => r.isFavorite).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRecipesList(recipes, showEmpty: true),
              _buildRecipesList(favoriteRecipes, isFavorites: true),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRecipe(),
        icon: const Icon(Icons.add),
        label: const Text('New Recipe'),
      ),
    );
  }

  Widget _buildRecipesList(
    List<RecipeModel> recipes, {
    bool isFavorites = false,
    bool showEmpty = false,
  }) {
    if (recipes.isEmpty) {
      return AppEmptyState(
        icon: isFavorites ? Icons.favorite_border : Icons.restaurant_menu,
        title: isFavorites ? 'No Favorite Recipes' : 'No Recipes Yet',
        subtitle: isFavorites
            ? 'Mark recipes as favorites to see them here'
            : 'Create your first recipe to get started',
        actionText: !isFavorites ? 'Create Recipe' : null,
        onAction: !isFavorites ? _navigateToCreateRecipe : null,
      );
    }

    return ListView.builder(
      padding: AppDimensions.paddingMd,
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return StaggeredListAnimation(
          position: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: _RecipeCard(
              recipe: recipe,
              onTap: () => _navigateToRecipeDetail(recipe),
              onDelete: () => _deleteRecipe(recipe),
              onToggleFavorite: () => _toggleFavorite(recipe),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCreateRecipe() {
    Navigator.of(context)
        .push(
      PageTransitions.slideFromBottom(const CreateRecipeScreen()),
    )
        .then((_) {
      // Refresh recipes list
      ref.invalidate(recipesProvider);
    });
  }

  void _navigateToRecipeDetail(RecipeModel recipe) {
    Navigator.of(context)
        .push(
      PageTransitions.slideFromRight(RecipeDetailScreen(recipe: recipe)),
    )
        .then((_) {
      // Refresh recipes list
      ref.invalidate(recipesProvider);
    });
  }

  Future<void> _deleteRecipe(RecipeModel recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(storageServiceProvider).deleteRecipe(recipe.id);
      ref.invalidate(recipesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(RecipeModel recipe) async {
    final updated = recipe.copyWith(isFavorite: !recipe.isFavorite);
    await ref.read(storageServiceProvider).saveRecipe(updated);
    ref.invalidate(recipesProvider);
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      child: AppCard(
        onTap: onTap,
        padding: AppDimensions.paddingSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Recipe icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),

                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              recipe.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: recipe.isFavorite
                                  ? AppColors.error
                                  : Theme.of(context).colorScheme.onSurface,
                              size: AppDimensions.iconSm,
                            ),
                            onPressed: onToggleFavorite,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recipe.ingredients.length} ingredients • ${recipe.servings} servings',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      if (recipe.usageCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Used ${recipe.usageCount} times',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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

            const SizedBox(height: AppDimensions.sm),

            // Nutrition per serving
            Row(
              children: [
                _NutrientChip(
                  label: '${recipe.caloriesPerServing.toInt()} cal',
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.xxs),
                _NutrientChip(
                  label: 'P: ${recipe.proteinPerServing.toInt()}g',
                  color: AppColors.protein,
                ),
                const SizedBox(width: AppDimensions.xxs),
                _NutrientChip(
                  label: 'C: ${recipe.carbsPerServing.toInt()}g',
                  color: AppColors.carbs,
                ),
                const SizedBox(width: AppDimensions.xxs),
                _NutrientChip(
                  label: 'F: ${recipe.fatPerServing.toInt()}g',
                  color: AppColors.fat,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: AppColors.error,
                  iconSize: AppDimensions.iconSm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;

  const _NutrientChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
