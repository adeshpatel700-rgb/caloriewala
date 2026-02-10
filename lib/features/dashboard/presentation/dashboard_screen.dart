import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/design/spacing.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../app_shell.dart';
import '../../home/presentation/home_screen.dart';
import '../../recipes/presentation/recipes_screen.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/calorie_progress_ring.dart';
import 'widgets/macro_breakdown_card.dart';
import 'widgets/meal_timeline_card.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/weekly_chart_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dailyStats = ref.watch(dailyStatsProvider);
    final currentGoal = ref.watch(currentGoalProvider);
    final meals = ref.watch(dailyMealsProvider);
    final activities = ref.watch(dailyActivitiesProvider);

    final caloriesConsumed = dailyStats['consumed'] as double;
    final caloriesBurned = dailyStats['burned'] as double;
    final netCalories = dailyStats['net'] as double;
    final goalCalories = currentGoal?.dailyCalorieGoal ?? 2000;

    final isToday = DateFormat('yyyy-MM-dd').format(selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
              isToday
                  ? 'Today'
                  : DateFormat('MMM d, yyyy').format(selectedDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _selectDate(context),
          ),
          const ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          ref.invalidate(dailyStatsProvider);
          ref.invalidate(dailyMealsProvider);
          ref.invalidate(dailyActivitiesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            // Calorie Progress Ring
            CalorieProgressRing(
              consumed: caloriesConsumed,
              burned: caloriesBurned,
              netCalories: netCalories,
              goal: goalCalories,
            ),

            const SizedBox(height: Spacing.lg),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.restaurant_menu,
                    label: 'My Recipes',
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransitions.slideFromRight(const RecipesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.track_changes,
                    label: 'Set Goals',
                    onTap: () {
                      // TODO: Navigate to goals screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Goals coming soon!')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: Spacing.lg),

            // Macro Breakdown
            AppSectionHeader(
              title: 'Macronutrients',
              icon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: Spacing.sm),
            MacroBreakdownCard(
              protein: dailyStats['protein'] as double,
              carbs: dailyStats['carbs'] as double,
              fat: dailyStats['fat'] as double,
              proteinGoal: currentGoal?.proteinGoal ?? 150,
              carbsGoal: currentGoal?.carbsGoal ?? 250,
              fatGoal: currentGoal?.fatGoal ?? 65,
            ),

            const SizedBox(height: Spacing.lg),

            // Water Tracker
            const AppSectionHeader(
              title: 'Water Tracking',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: Spacing.sm),
            const WaterTrackerCard(),

            const SizedBox(height: Spacing.lg),

            // Weekly Chart
            AppSectionHeader(
              title: 'Weekly Progress',
              subtitle: 'Last 7 days',
              icon: Icons.trending_up,
            ),
            const SizedBox(height: Spacing.sm),
            WeeklyChartCard(),

            const SizedBox(height: Spacing.lg),

            // Meal Timeline
            AppSectionHeader(
              title: 'Today\'s Activity',
              subtitle:
                  '${meals.length} meals • ${activities.length} activities',
              icon: Icons.timeline,
            ),
            const SizedBox(height: Spacing.sm),
            MealTimelineCard(
              meals: meals,
              activities: activities,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: isToday
          ? FilledButton.icon(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).state = 1;
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Log Meal'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
