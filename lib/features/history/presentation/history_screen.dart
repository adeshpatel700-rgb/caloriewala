import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/app_components.dart';
import '../../dashboard/data/models/meal_log_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppPalette.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text('History',
                    style: AppText.h1.copyWith(color: AppPalette.text)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppPalette.accent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.accent.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: AppText.labelMd.copyWith(
                        fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    unselectedLabelStyle: AppText.labelMd,
                    labelColor: Colors.black,
                    unselectedLabelColor: AppPalette.textSec,
                    tabs: const [
                      Tab(text: 'Log'),
                      Tab(text: 'Favorites'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(
                  children: [
                    _MealList(favOnly: false),
                    _MealList(favOnly: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealList extends ConsumerWidget {
  final bool favOnly;
  const _MealList({required this.favOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = favOnly
        ? ref.watch(favoriteMealsProvider)
        : ref.watch(mealHistoryProvider);

    if (meals.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: favOnly ? Icons.favorite_border_rounded : Icons.receipt_long_rounded,
          title: favOnly ? 'No favorites yet' : 'No history found',
          subtitle: favOnly
              ? 'Save your favorite meals to see them here'
              : 'Logged meals will appear here in chronological order',
        ),
      );
    }

    // Group by date
    final grouped = <String, List<MealLogModel>>{};
    for (final meal in meals) {
      final key = DateFormat('yyyy-MM-dd').format(meal.timestamp);
      grouped.putIfAbsent(key, () => []).add(meal);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: sortedKeys.length,
      itemBuilder: (ctx, i) {
        final dayKey = sortedKeys[i];
        final dayMeals = grouped[dayKey]!;
        final date = DateTime.parse(dayKey);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Row(
                children: [
                  Text(
                    isToday ? 'TODAY' : DateFormat('EEE, MMM d').format(date).toUpperCase(),
                    style: AppText.labelXs.copyWith(
                      color: AppPalette.textTert,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Divider(color: AppPalette.border, thickness: 1)),
                  const SizedBox(width: 12),
                  Text(
                    '${dayMeals.fold<double>(0, (s, m) => s + m.totalCalories).toStringAsFixed(0)} kcal',
                    style: AppText.labelXs.copyWith(
                      color: AppPalette.textSec,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...dayMeals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MealCard(meal: meal),
            )),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealLogModel meal;
  const _MealCard({required this.meal});

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'breakfast': return AppPalette.breakfast;
      case 'lunch':     return AppPalette.lunch;
      case 'dinner':    return AppPalette.dinner;
      case 'snack':     return AppPalette.snack;
      default:          return AppPalette.accent;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'breakfast': return Icons.wb_sunny_rounded;
      case 'lunch':     return Icons.restaurant_rounded;
      case 'dinner':    return Icons.nights_stay_rounded;
      case 'snack':     return Icons.cookie_rounded;
      default:          return Icons.flatware_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(meal.mealCategory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withOpacity(0.2)),
                ),
                child: Icon(_categoryIcon(meal.mealCategory), size: 20, color: catColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(meal.mealCategory,
                            style: AppText.labelSm.copyWith(
                                color: catColor, fontWeight: FontWeight.bold)),
                        Text(DateFormat('h:mm a').format(meal.timestamp),
                            style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(meal.foodItems.join(', '),
                        style: AppText.bodyLg.copyWith(
                            color: AppPalette.text, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _NutrientBadge(
                label: '${meal.proteinGrams.toStringAsFixed(0)}g P',
                color: AppPalette.protein,
              ),
              const SizedBox(width: 8),
              _NutrientBadge(
                label: '${meal.carbsGrams.toStringAsFixed(0)}g C',
                color: AppPalette.carbs,
              ),
              const SizedBox(width: 8),
              _NutrientBadge(
                label: '${meal.fatGrams.toStringAsFixed(0)}g F',
                color: AppPalette.fat,
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(meal.totalCalories.toStringAsFixed(0),
                      style: AppText.numberSm.copyWith(
                          color: AppPalette.accent, fontSize: 18)),
                  const SizedBox(width: 2),
                  Text('KCAL', 
                      style: AppText.labelXs.copyWith(
                          color: AppPalette.textTert, fontWeight: FontWeight.bold)),
                ],
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
  final Color color;
  const _NutrientBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: AppText.labelXs.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
