import 'package:flutter/material.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';

class MacroBreakdownCard extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  const MacroBreakdownCard({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
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
              Text('Macros', style: AppText.h3.copyWith(fontSize: 18)),
              Text('Daily Goals', 
                  style: AppText.labelSm.copyWith(color: AppPalette.textTert)),
            ],
          ),
          const SizedBox(height: 20),
          _MacroPill(
            label: 'Protein',
            value: protein,
            goal: proteinGoal,
            color: AppPalette.protein,
          ),
          const SizedBox(height: 16),
          _MacroPill(
            label: 'Carbs',
            value: carbs,
            goal: carbsGoal,
            color: AppPalette.carbs,
          ),
          const SizedBox(height: 16),
          _MacroPill(
            label: 'Fat',
            value: fat,
            goal: fatGoal,
            color: AppPalette.fat,
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatefulWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  State<_MacroPill> createState() => _MacroPillState();
}

class _MacroPillState extends State<_MacroPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
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
    final goal = widget.goal > 0 ? widget.goal : 1.0;
    final pct = (widget.value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(widget.label,
                    style: AppText.labelMd.copyWith(
                        color: AppPalette.textSec, fontWeight: FontWeight.normal)),
              ],
            ),
            Text(
              '${widget.value.toStringAsFixed(0)} / ${widget.goal.toStringAsFixed(0)}g',
              style: AppText.bodySm.copyWith(
                  color: AppPalette.text, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 6, color: AppPalette.surfaceTop),
                FractionallySizedBox(
                  widthFactor: pct * _anim.value,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
