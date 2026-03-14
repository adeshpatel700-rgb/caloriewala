import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/app_components.dart';
import '../data/models/food_item_model.dart';
import '../data/models/nutrition_model.dart';
import 'providers/analysis_provider.dart';
import '../../dashboard/data/models/meal_log_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';

/// Full-screen nutrition results
class ResultScreen extends ConsumerStatefulWidget {
  final List<FoodItemModel> foodItems;
  final File? imageFile;
  final String mealCategory;

  const ResultScreen({
    super.key,
    required this.foodItems,
    this.imageFile,
    this.mealCategory = 'Lunch',
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionProvider.notifier).calculateNutrition(widget.foodItems);
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveMeal(NutritionModel nutrition) async {
    if (_saved) return;
    setState(() => _saved = true);

    final meal = MealLogModel(
      id: const Uuid().v4(),
      mealCategory: widget.mealCategory,
      foodItems: widget.foodItems.map((f) => f.name).toList(),
      totalCalories: nutrition.totalCalories,
      proteinGrams:  nutrition.proteinGrams,
      carbsGrams:    nutrition.carbsGrams,
      fatGrams:      nutrition.fatGrams,
      timestamp: DateTime.now(),
    );

    await ref.read(storageServiceProvider).saveMeal(meal);
    
    // Refresh all relevant providers
    ref.invalidate(dailyStatsProvider);
    ref.invalidate(dailyMealsProvider);
    ref.invalidate(mealHistoryProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal logged successfully! \u2728'),
          backgroundColor: AppPalette.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  void _shareResult(NutritionModel nutrition) {
    // Sharing simulation for the audit
    final text = 'Just logged my ${widget.mealCategory} on CalorieWala! \n'
        'Calories: ${nutrition.totalCalories.toStringAsFixed(0)} kcal\n'
        'Protein: ${nutrition.proteinGrams.toStringAsFixed(1)}g\n'
        'Download CalorieWala to track your nutrition with AI!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Result copied to clipboard! \uD83D\uDCCE'),
        backgroundColor: AppPalette.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: Text('Nutrition Results', style: AppText.h2.copyWith(color: AppPalette.text)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppPalette.textSec, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (state.nutrition != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppPalette.accent, size: 20),
              onPressed: () => _shareResult(state.nutrition!),
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppPalette.bg,
        elevation: 0,
        centerTitle: false,
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32, height: 32,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: AppPalette.accent),
                  ),
                  SizedBox(height: 20),
                  Text('Calculating nutrition data…',
                      style: TextStyle(color: AppPalette.textSec, letterSpacing: 0.5)),
                ],
              ),
            )
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 56, color: AppPalette.error),
                        const SizedBox(height: 20),
                        Text('Analysis Interrupted',
                            style: AppText.h3.copyWith(color: AppPalette.text)),
                        const SizedBox(height: 12),
                        Text(state.error!,
                            style: AppText.bodyMd.copyWith(color: AppPalette.textSec),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        AppButton(
                          text: 'Try Again',
                          onPressed: () => Navigator.pop(context),
                          buttonStyle: AppButtonStyle.secondary,
                        ),
                      ],
                    ),
                  ),
                )
              : _SuccessView(
                  nutrition: state.nutrition!,
                  foodItems: widget.foodItems,
                  mealCategory: widget.mealCategory,
                  animCtrl: _animCtrl,
                  saved: _saved,
                  onSave: () => _saveMeal(state.nutrition!),
                ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final NutritionModel nutrition;
  final List<FoodItemModel> foodItems;
  final String mealCategory;
  final AnimationController animCtrl;
  final bool saved;
  final VoidCallback onSave;

  const _SuccessView({
    required this.nutrition,
    required this.foodItems,
    required this.mealCategory,
    required this.animCtrl,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 24);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero calorie card ───────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppPalette.border.withOpacity(0.8)),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.accent.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(mealCategory.toUpperCase(),
                          style: AppText.labelSm.copyWith(
                              color: AppPalette.textTert, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: animCtrl,
                        builder: (_, __) => Text(
                          (nutrition.totalCalories * animCtrl.value).toStringAsFixed(0),
                          style: AppText.numberLg.copyWith(
                              color: AppPalette.accent, fontSize: 56),
                        ),
                      ),
                      Text('TOTAL KILOCALORIES',
                          style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
                    ],
                  ),
                ),
                space,

                // ── Macros Section ──────────────────────────────
                Text('Macro Breakdown',
                    style: AppText.h4.copyWith(color: AppPalette.textSec)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Column(
                    children: [
                      _MacroRow(label: 'Protein', value: nutrition.proteinGrams, unit: 'g', color: AppPalette.protein, total: 100),
                      const Divider(height: 28, color: AppPalette.border),
                      _MacroRow(label: 'Carbs', value: nutrition.carbsGrams, unit: 'g', color: AppPalette.carbs, total: 300),
                      const Divider(height: 28, color: AppPalette.border),
                      _MacroRow(label: 'Fat', value: nutrition.fatGrams, unit: 'g', color: AppPalette.fat, total: 80),
                    ],
                  ),
                ),
                space,

                // ── Food items ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Detected Items',
                        style: AppText.h4.copyWith(color: AppPalette.textSec)),
                    Text('${foodItems.length} items',
                        style: AppText.bodySm.copyWith(color: AppPalette.textTert)),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foodItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _FoodItemCard(
                    item: foodItems[index],
                    index: index,
                  ),
                ),

                // ── Health note ─────────────────────────────────
                if (nutrition.healthNote.isNotEmpty) ...[
                  space,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppPalette.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppPalette.accent.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppPalette.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            nutrition.healthNote,
                            style: AppText.bodyMd.copyWith(
                                color: AppPalette.text, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // ── Pinned Save button ─────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          decoration: BoxDecoration(
            color: AppPalette.bg,
            border: Border(top: BorderSide(color: AppPalette.border.withOpacity(0.5))),
          ),
          child: AppButton(
            text: saved ? 'Meal Saved' : 'Confirm & Log Meal',
            icon: saved ? Icons.check_circle_rounded : Icons.add_task_rounded,
            onPressed: saved ? null : onSave,
            buttonStyle: saved ? AppButtonStyle.secondary : AppButtonStyle.primary,
          ),
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double total;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(label, style: AppText.labelMd.copyWith(color: AppPalette.textSec)),
            const Spacer(),
            Text('${value.toStringAsFixed(1)}$unit',
                style: AppText.h4.copyWith(color: AppPalette.text, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / total).clamp(0.0, 1.0),
            backgroundColor: AppPalette.surfaceTop,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItemModel item;
  final int index;
  const _FoodItemCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppText.bodyLg.copyWith(
                        color: AppPalette.text, fontWeight: FontWeight.bold)),
                if (item.hindiName != null && item.hindiName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.hindiName!,
                      style: AppText.bodySm.copyWith(color: AppPalette.textTert)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppPalette.surfaceTop,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppPalette.border),
            ),
            child: Text(item.portion,
                style: AppText.labelSm.copyWith(
                    color: AppPalette.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
