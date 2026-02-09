import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/animations/staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_components.dart';
import '../../dashboard/data/models/meal_log_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
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
    final allMeals = ref.watch(storageServiceProvider).getAllMeals();
    final favoriteMeals = ref.watch(storageServiceProvider).getFavoriteMeals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        elevation: 0,
        scrolledUnderElevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'All Meals'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMealList(allMeals, showFavorites: false),
          _buildMealList(favoriteMeals, showFavorites: true),
        ],
      ),
    );
  }

  Widget _buildMealList(
    List<MealLogModel> meals, {
    required bool showFavorites,
  }) {
    if (meals.isEmpty) {
      return AppEmptyState(
        icon: showFavorites ? Icons.favorite_border : Icons.restaurant_menu,
        title: showFavorites ? 'No Favorites Yet' : 'No Meals Logged',
        subtitle: showFavorites
            ? 'Mark meals as favorites to see them here'
            : 'Start tracking your meals to see them here',
      );
    }

    // Group meals by date
    final groupedMeals = <String, List<MealLogModel>>{};
    for (final meal in meals) {
      final dateKey = DateFormat('yyyy-MM-dd').format(meal.timestamp);
      groupedMeals.putIfAbsent(dateKey, () => []).add(meal);
    }

    final sortedDates = groupedMeals.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return ListView.builder(
      padding: AppDimensions.paddingMd,
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateMeals = groupedMeals[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.sm,
                horizontal: AppDimensions.xs,
              ),
              child: Text(
                _formatDateHeader(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ...dateMeals.asMap().entries.map((entry) {
              final index = entry.key;
              final meal = entry.value;
              return StaggeredListAnimation(
                position: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: _MealCard(meal: meal),
                ),
              );
            }),
            const SizedBox(height: AppDimensions.sm),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final mealDate = DateTime(date.year, date.month, date.day);

    if (mealDate == today) {
      return 'Today';
    } else if (mealDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }
}

class _MealCard extends ConsumerWidget {
  final MealLogModel meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: AppDimensions.paddingSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(meal.mealCategory).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              _getCategoryIcon(meal.mealCategory),
              color: _getCategoryColor(meal.mealCategory),
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.foodItems.join(', '),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (meal.isFavorite)
                      const Icon(
                        Icons.favorite,
                        size: AppDimensions.iconSm,
                        color: AppColors.error,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.mealCategory} • ${DateFormat('h:mm a').format(meal.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    _NutrientChip(
                      label: '${meal.totalCalories.toInt()} cal',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.xxs),
                    _NutrientChip(
                      label: 'P: ${meal.proteinGrams.toInt()}g',
                      color: AppColors.protein,
                    ),
                    const SizedBox(width: AppDimensions.xxs),
                    _NutrientChip(
                      label: 'C: ${meal.carbsGrams.toInt()}g',
                      color: AppColors.carbs,
                    ),
                    const SizedBox(width: AppDimensions.xxs),
                    _NutrientChip(
                      label: 'F: ${meal.fatGrams.toInt()}g',
                      color: AppColors.fat,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'breakfast' => Icons.free_breakfast,
      'lunch' => Icons.lunch_dining,
      'dinner' => Icons.dinner_dining,
      'snack' => Icons.cookie,
      _ => Icons.restaurant,
    };
  }

  Color _getCategoryColor(String category) {
    return switch (category.toLowerCase()) {
      'breakfast' => const Color(0xFFFFB74D),
      'lunch' => const Color(0xFF4CAF50),
      'dinner' => const Color(0xFF42A5F5),
      'snack' => const Color(0xFFAB47BC),
      _ => const Color(0xFF6750A4),
    };
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
