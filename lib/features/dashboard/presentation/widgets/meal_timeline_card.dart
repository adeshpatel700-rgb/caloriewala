import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/data/models/meal_log_model.dart';
import '../../../dashboard/data/models/activity_log_model.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';

class MealTimelineCard extends StatelessWidget {
  final List<MealLogModel> meals;
  final List<ActivityLogModel> activities;

  const MealTimelineCard({
    super.key,
    required this.meals,
    required this.activities,
  });

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
      case 'breakfast': return Icons.free_breakfast_outlined;
      case 'lunch':     return Icons.lunch_dining_outlined;
      case 'dinner':    return Icons.dinner_dining_outlined;
      case 'snack':     return Icons.cookie_outlined;
      default:          return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty && activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surfaceTop,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  size: 40, color: AppPalette.textTert),
            ),
            const SizedBox(height: 16),
            Text('Your timeline is empty', 
                style: AppText.h3.copyWith(color: AppPalette.text)),
            const SizedBox(height: 8),
            Text("Track your first meal to see it here",
                style: AppText.bodyMd.copyWith(color: AppPalette.textTert),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    // Merge + sort (Optimized)
    final items = [
      ...meals.map((m) => {'type': 'meal', 'data': m, 'time': m.timestamp}),
      ...activities.map((a) => {'type': 'activity', 'data': a, 'time': a.timestamp}),
    ]..sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          
          if (item['type'] == 'meal') {
            final meal = item['data'] as MealLogModel;
            final color = _categoryColor(meal.mealCategory);
            return _TimelineRow(
              isLast: isLast,
              accentColor: color,
              icon: _categoryIcon(meal.mealCategory),
              time: DateFormat('h:mm a').format(meal.timestamp),
              title: meal.mealCategory,
              subtitle: meal.foodItems.join(', '),
              badge: '${meal.totalCalories.toStringAsFixed(0)} kcal',
              badgeColor: color,
            );
          } else {
            final act = item['data'] as ActivityLogModel;
            return _TimelineRow(
              isLast: isLast,
              accentColor: AppPalette.error,
              icon: Icons.run_circle_outlined,
              time: DateFormat('h:mm a').format(act.timestamp),
              title: act.activityType,
              subtitle: '${act.durationMinutes} min activity',
              badge: '-${act.caloriesBurned.toStringAsFixed(0)} kcal',
              badgeColor: AppPalette.error,
            );
          }
        },
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final bool isLast;
  final Color accentColor;
  final IconData icon;
  final String time;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  const _TimelineRow({
    required this.isLast,
    required this.accentColor,
    required this.icon,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left timeline column
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppPalette.border,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20, bottom: isLast ? 24 : 12, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: AppText.bodyLg.copyWith(
                                    color: AppPalette.text,
                                    fontWeight: FontWeight.bold)),
                            Text(time,
                                style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: badgeColor.withOpacity(0.2)),
                        ),
                        child: Text(badge,
                            style: AppText.labelSm.copyWith(
                                color: badgeColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle,
                      style: AppText.bodyMd.copyWith(
                          color: AppPalette.textSec, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
