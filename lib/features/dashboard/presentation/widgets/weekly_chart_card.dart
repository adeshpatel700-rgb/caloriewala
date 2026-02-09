import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/spacing.dart';
import '../providers/dashboard_provider.dart';

class WeeklyChartCard extends ConsumerWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStats = ref.watch(weeklyStatsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyStats.map((stat) {
                final date = stat['date'] as DateTime;
                final consumed = stat['consumed'] as double;
                final goal =
                    ref.read(currentGoalProvider)?.dailyCalorieGoal ?? 2000;
                final percentage = (consumed / goal).clamp(0.0, 1.5);

                return _BarItem(
                  day: _getDayLabel(date),
                  percentage: percentage,
                  calories: consumed,
                  isToday: _isToday(date),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[date.weekday % 7];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _BarItem extends StatefulWidget {
  final String day;
  final double percentage;
  final double calories;
  final bool isToday;

  const _BarItem({
    required this.day,
    required this.percentage,
    required this.calories,
    required this.isToday,
  });

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.calories > 0)
          Text(
            widget.calories.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 32,
              height: 100 * widget.percentage * _animation.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: widget.isToday
                      ? [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ]
                      : [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: widget.isToday
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: widget.isToday ? FontWeight.bold : FontWeight.normal,
            color: widget.isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
