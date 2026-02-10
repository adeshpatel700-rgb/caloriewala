import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/animations/staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_components.dart';
import '../../data/models/water_log_model.dart';
import '../providers/dashboard_provider.dart';

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
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
    final waterIntakeAsync = ref.watch(dailyWaterIntakeProvider);

    return waterIntakeAsync.when(
      data: (waterIntake) {
        final goal = WaterLogModel.dailyGoalMl;
        final percentage = (waterIntake / goal).clamp(0.0, 1.0);

        return _buildCard(context, waterIntake, goal, percentage);
      },
      loading: () => AppCard(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Loading water intake...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      error: (err, stack) => AppCard(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    int waterIntake,
    int goal,
    double percentage,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop,
                color: AppColors.info,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Water Intake',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '$waterIntake ml',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Progress bar
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: LinearProgressIndicator(
                      value: percentage * _controller.value,
                      minHeight: 12,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 1.0 ? AppColors.success : AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(percentage * 100).toInt()}% of daily goal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        'Goal: ${goal}ml',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppDimensions.md),

          // Quick add buttons
          Row(
            children: [
              Expanded(
                child: _WaterPresetButton(
                  amount: WaterLogModel.smallGlass,
                  label: 'Glass\n200ml',
                  icon: Icons.local_drink,
                  onTap: () =>
                      _addWater(WaterLogModel.smallGlass, 'Small Glass'),
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: _WaterPresetButton(
                  amount: WaterLogModel.mediumGlass,
                  label: 'Glass\n250ml',
                  icon: Icons.local_drink,
                  onTap: () => _addWater(WaterLogModel.mediumGlass, 'Glass'),
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: _WaterPresetButton(
                  amount: WaterLogModel.bottle,
                  label: 'Bottle\n500ml',
                  icon: Icons.water_drop_outlined,
                  onTap: () => _addWater(WaterLogModel.bottle, 'Bottle'),
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: _WaterPresetButton(
                  amount: 0,
                  label: 'Custom',
                  icon: Icons.add,
                  onTap: _showCustomAmountDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addWater(int milliliters, String note) async {
    final waterLog = WaterLogModel(
      timestamp: DateTime.now(),
      milliliters: milliliters,
      note: note,
    );

    await ref.read(storageServiceProvider).saveWaterLog(waterLog);
    ref.invalidate(dailyWaterIntakeProvider);

    if (mounted) {
      // Animate the progress bar
      _controller.forward(from: 0.0);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${waterLog.getFormattedAmount()} water'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showCustomAmountDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (ml)',
                hintText: '250',
                suffixText: 'ml',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      await _addWater(result, 'Custom');
    }
  }
}

class _WaterPresetButton extends StatelessWidget {
  final int amount;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WaterPresetButton({
    required this.amount,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.info,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.info,
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
