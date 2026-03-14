import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/typography.dart';
import '../../../core/animations/page_transitions.dart';
import '../../app_shell.dart';
import '../../root_widget.dart';
import '../../settings/presentation/settings_screen.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/calorie_progress_ring.dart';
import 'widgets/macro_breakdown_card.dart';
import 'widgets/meal_timeline_card.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/weekly_chart_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate     = ref.watch(selectedDateProvider);
    final dailyStats       = ref.watch(dailyStatsProvider);
    final dailyMeals       = ref.watch(dailyMealsProvider);
    final dailyActivities  = ref.watch(dailyActivitiesProvider);
    final userName         = ref.watch(userNameProvider);

    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(selectedDate, now);

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: RefreshIndicator(
        color: AppPalette.accent,
        backgroundColor: AppPalette.surface,
        onRefresh: () async {
          ref.invalidate(dailyStatsProvider);
          ref.invalidate(dailyMealsProvider);
          ref.invalidate(dailyActivitiesProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 64, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(userName),
                            style: AppText.bodyMd.copyWith(
                                color: AppPalette.textSec, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isToday ? 'Today' : DateFormat('EEEE, MMM d').format(selectedDate),
                            style: AppText.h1.copyWith(color: AppPalette.text),
                          ),
                        ],
                      ),
                    ),
                    _DateNav(
                      onPrev: () => ref.read(selectedDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 1)),
                      onNext: isToday ? null : () =>
                          ref.read(selectedDateProvider.notifier).state =
                              selectedDate.add(const Duration(days: 1)),
                    ),
                    const SizedBox(width: 8),
                    _HeaderAction(
                      icon: Icons.settings_rounded,
                      onTap: () => Navigator.push(context, 
                          PageTransitions.slideFromRight(const SettingsScreen())),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content Sections ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  
                  // Calorie Ring
                  CalorieProgressRing(
                    consumed: (dailyStats['consumed'] as num? ?? 0).toDouble(),
                    burned:   (dailyStats['burned']   as num? ?? 0).toDouble(),
                    goal:     (dailyStats['goal']     as num? ?? 2000).toDouble(),
                    netCalories: (dailyStats['net']   as num? ?? 0).toDouble(),
                  ),
                  const SizedBox(height: 12),

                  // Macros
                  MacroBreakdownCard(
                    protein:      (dailyStats['protein']     as num? ?? 0).toDouble(),
                    carbs:        (dailyStats['carbs']       as num? ?? 0).toDouble(),
                    fat:          (dailyStats['fat']         as num? ?? 0).toDouble(),
                    proteinGoal:  (dailyStats['proteinGoal'] as num? ?? 150).toDouble(),
                    carbsGoal:    (dailyStats['carbsGoal']   as num? ?? 250).toDouble(),
                    fatGoal:      (dailyStats['fatGoal']     as num? ?? 65).toDouble(),
                  ),
                  const SizedBox(height: 12),

                  // Water
                  const WaterTrackerCard(),
                  const SizedBox(height: 12),

                  // Weekly Chart
                  WeeklyChartCard(),
                  const SizedBox(height: 24),

                  // Timeline Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Log", style: AppText.h3),
                        TextButton(
                          onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                          style: TextButton.styleFrom(
                            foregroundColor: AppPalette.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('View History'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meal Timeline
                  MealTimelineCard(meals: dailyMeals, activities: dailyActivities),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final prefix = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return name.isEmpty ? '$prefix 👋' : '$prefix, $name 👋';
  }
}

class _DateNav extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  const _DateNav({required this.onPrev, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceTop,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Container(width: 1, height: 20, color: AppPalette.border),
          _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext, enabled: onNext != null),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  const _NavBtn({required this.icon, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppPalette.textSec : AppPalette.textTert,
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppPalette.surfaceTop,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.border),
        ),
        child: Icon(icon, size: 20, color: AppPalette.textSec),
      ),
    );
  }
}
