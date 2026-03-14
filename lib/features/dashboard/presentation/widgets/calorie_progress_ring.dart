import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';

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
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final net = widget.netCalories;
    final goal = widget.goal > 0 ? widget.goal : 2000.0;
    final progress = (net / goal).clamp(0.0, 1.5);
    final remaining = goal - net;
    final isOver = net > goal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ring
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              width: 210,
              height: 210,
              child: CustomPaint(
                painter: _RingPainter(
                    progress: (progress * _anim.value).clamp(0.0, 1.5),
                    isOver: isOver),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        net.toStringAsFixed(0),
                        style: AppText.numberLg.copyWith(
                          color: isOver ? AppPalette.error : AppPalette.accent,
                          fontSize: 48,
                        ),
                      ),
                      Text('KCAL NET', 
                          style: AppText.labelXs.copyWith(
                              color: AppPalette.textTert, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOver 
                              ? AppPalette.error.withOpacity(0.1) 
                              : AppPalette.surfaceTop,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isOver 
                                ? AppPalette.error.withOpacity(0.2) 
                                : AppPalette.border,
                          ),
                        ),
                        child: Text(
                          isOver
                              ? '${(net - goal).toStringAsFixed(0)} kcal over'
                              : '${remaining.toStringAsFixed(0)} kcal left',
                          style: AppText.labelSm.copyWith(
                            color: isOver ? AppPalette.error : AppPalette.textSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              _StatItem(
                icon: Icons.restaurant_rounded,
                label: 'Eaten',
                value: widget.consumed.toStringAsFixed(0),
                color: AppPalette.accent,
              ),
              _VDivider(),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Burned',
                value: widget.burned.toStringAsFixed(0),
                color: AppPalette.error,
              ),
              _VDivider(),
              _StatItem(
                icon: Icons.track_changes_rounded,
                label: 'Goal',
                value: goal.toStringAsFixed(0),
                color: AppPalette.textTert,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppPalette.border.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color.withOpacity(0.8)),
          const SizedBox(height: 6),
          Text(value,
              style: AppText.numberSm.copyWith(
                color: AppPalette.text, 
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: AppText.labelXs.copyWith(
                color: AppPalette.textTert,
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isOver;

  const _RingPainter({required this.progress, required this.isOver});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 16.0;

    // Track
    final trackPaint = Paint()
      ..color = AppPalette.surfaceTop
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: isOver
            ? [AppPalette.error, const Color(0xFFFF8E8E), AppPalette.error]
            : [AppPalette.accent, const Color(0xFFFFA500), AppPalette.accent],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.001, 1.0);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Over-goal indicator (glow effect)
    if (isOver && progress > 1.0) {
      final glowPaint = Paint()
        ..color = AppPalette.error.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isOver != isOver;
}
