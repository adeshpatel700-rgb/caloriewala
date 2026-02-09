import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/design/spacing.dart';

class CalorieProgressRing extends StatefulWidget {
  final double consumed;
  final double burned;
  final double goal;
  final double netCalories;

  const CalorieProgressRing({
    super.key,
    required this.consumed,
    required this.burned,
    required this.goal,
    required this.netCalories,
  });

  @override
  State<CalorieProgressRing> createState() => _CalorieProgressRingState();
}

class _CalorieProgressRingState extends State<CalorieProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final progress = (widget.netCalories / widget.goal).clamp(0.0, 1.0);
    final remaining = widget.goal - widget.netCalories;
    final isOverGoal = widget.netCalories > widget.goal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            width: 220,
            height: 220,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RingPainter(
                    progress: progress * _animation.value,
                    isOverGoal: isOverGoal,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.netCalories.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 200, 70),
                              ),
                          ),
                        ),
                        Text(
                          isOverGoal
                              ? 'Over goal by ${(widget.netCalories - widget.goal).toStringAsFixed(0)}'
                              : '${remaining.toStringAsFixed(0)} remaining',
                          style: TextStyle(
                            fontSize: 14,
                            color: isOverGoal
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.restaurant,
                label: 'Consumed',
                value: widget.consumed.toStringAsFixed(0),
                color: Theme.of(context).colorScheme.primary,
              ),
              _StatItem(
                icon: Icons.local_fire_department,
                label: 'Burned',
                value: widget.burned.toStringAsFixed(0),
                color: Theme.of(context).colorScheme.error,
              ),
              _StatItem(
                icon: Icons.flag_outlined,
                label: 'Goal',
                value: widget.goal.toStringAsFixed(0),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isOverGoal;

  _RingPainter({
    required this.progress,
    required this.isOverGoal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 16.0;

    // Background circle (using a neutral gray that works in both modes)
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc - Note: CustomPainter doesn't have context, colors passed from widget would be better
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: isOverGoal
            ? [const Color(0xFFEF5350), const Color(0xFFFF9800)]
            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isOverGoal != isOverGoal;
  }
}
