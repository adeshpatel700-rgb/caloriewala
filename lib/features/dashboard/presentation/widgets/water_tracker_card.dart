import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/staggered_animations.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/water_log_model.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/widgets/app_components.dart';

class WaterTrackerCard extends ConsumerStatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  ConsumerState<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends ConsumerState<WaterTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterAsync = ref.watch(dailyWaterIntakeProvider);

    return waterAsync.when(
      data: (ml) => _buildCard(ml),
      loading: () => Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(BorderSide(color: AppPalette.border)),
        ),
        child: const Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppPalette.water,
            ),
          ),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(int ml) {
    const goal = WaterLogModel.dailyGoalMl;
    final pct = (ml / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.water.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: AppPalette.water.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, size: 18, color: AppPalette.water),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hydration', style: AppText.h3.copyWith(fontSize: 18)),
                  Text('${(pct * 100).toStringAsFixed(0)}% of daily goal', 
                      style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
                ],
              ),
              const Spacer(),
              Text('$ml / $goal', 
                  style: AppText.h4.copyWith(color: AppPalette.water, fontSize: 18)),
              Text(' ml', style: AppText.labelSm.copyWith(color: AppPalette.textTert)),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Stack(
                    children: [
                      Container(height: 10, color: AppPalette.surfaceTop),
                      FractionallySizedBox(
                        widthFactor: pct * _controller.value,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppPalette.water, Color(0xFF63B3ED)],
                            ),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppPalette.water.withOpacity(0.3),
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick-add buttons
          Row(
            children: [
              _WaterBtn(
                  amount: WaterLogModel.smallGlass, 
                  label: '200ml',
                  icon: Icons.local_drink_rounded, 
                  onTap: () => _add(WaterLogModel.smallGlass, 'Glass')),
              const SizedBox(width: 10),
              _WaterBtn(
                  amount: WaterLogModel.mediumGlass, 
                  label: '250ml',
                  icon: Icons.local_drink_rounded, 
                  onTap: () => _add(WaterLogModel.mediumGlass, 'Large Glass')),
              const SizedBox(width: 10),
              _WaterBtn(
                  amount: WaterLogModel.bottle, 
                  label: '500ml',
                  icon: Icons.water_rounded, 
                  onTap: () => _add(WaterLogModel.bottle, 'Bottle')),
              const SizedBox(width: 10),
              _WaterBtn(
                  amount: 0, 
                  label: 'Custom',
                  icon: Icons.add_rounded, 
                  onTap: _showCustom),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _add(int ml, String note) async {
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();
    
    // Create timestamp for the selected date, but with current time if today
    final timestamp = DateUtils.isSameDay(selectedDate, now)
        ? now
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 12, 0);

    final log = WaterLogModel(
        timestamp: timestamp, milliliters: ml, note: note);
    await ref.read(storageServiceProvider).saveWaterLog(log);
    ref.invalidate(dailyWaterIntakeProvider);
    if (mounted) {
      _controller.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${log.getFormattedAmount()} water \uD83D\uDCA7'),
          backgroundColor: AppPalette.water,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _showCustom() async {
    final ctrl = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Amount', 
            style: AppText.h3.copyWith(color: AppPalette.text)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppPalette.text),
          decoration: InputDecoration(
            labelText: 'Milliliters',
            labelStyle: const TextStyle(color: AppPalette.textSec),
            hintText: 'e.g. 330',
            hintStyle: TextStyle(color: AppPalette.textTert.withOpacity(0.5)),
            suffixText: 'ml',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Cancel', style: TextStyle(color: AppPalette.textSec))),
          AppButton(
            text: 'Add Water',
            width: 120,
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
          ),
        ],
      ),
    );
    if (result != null && mounted) await _add(result, 'Custom');
  }
}

class _WaterBtn extends StatelessWidget {
  final int amount;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WaterBtn({
    required this.amount,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppPalette.surfaceTop,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppPalette.water),
              const SizedBox(height: 6),
              Text(label,
                  style: AppText.labelXs.copyWith(
                      color: AppPalette.textSec, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
