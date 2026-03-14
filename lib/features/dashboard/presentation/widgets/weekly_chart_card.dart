import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';

class WeeklyChartCard extends ConsumerWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final goalInfo = ref.read(currentGoalProvider);
    final goal = (goalInfo?.dailyCalorieGoal ?? 2000).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Progress', style: AppText.h3.copyWith(fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceTop,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Goal: ${goal.toStringAsFixed(0)} kcal',
                    style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weeklyStats.map((stat) {
                final date = stat['date'] as DateTime;
                final consumed = (stat['consumed'] as num? ?? 0).toDouble();
                final pct = (consumed / goal).clamp(0.01, 1.2);
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                
                return Expanded(
                  child: _Bar(
                    day: _dayLabel(date),
                    percentage: pct,
                    calories: consumed,
                    isToday: isToday,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[date.weekday % 7];
  }
}

class _Bar extends StatefulWidget {
  final String day;
  final double percentage;
  final double calories;
  final bool isToday;

  const _Bar({
    required this.day,
    required this.percentage,
    required this.calories,
    required this.isToday,
  });

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.calories > 0) 
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Opacity(
              opacity: _anim.value,
              child: Text(
                widget.calories > 999 
                    ? '${(widget.calories/1000).toStringAsFixed(1)}k' 
                    : widget.calories.toStringAsFixed(0),
                style: AppText.labelXs.copyWith(
                  color: widget.isToday ? AppPalette.accent : AppPalette.textTert,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            width: 32,
            height: (80 * widget.percentage * _anim.value).clamp(4.0, 80.0),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: widget.isToday 
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppPalette.accent, Color(0xFFFFAA00)],
                    )
                  : null,
              color: widget.isToday ? null : AppPalette.surfaceTop,
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isToday ? [
                BoxShadow(
                  color: AppPalette.accent.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
              border: widget.isToday
                  ? null
                  : Border.all(color: AppPalette.border),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.day,
          style: AppText.labelXs.copyWith(
            color: widget.isToday ? AppPalette.accent : AppPalette.textTert,
            fontWeight: widget.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
