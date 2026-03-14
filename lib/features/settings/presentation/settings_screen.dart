import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';
import '../../../../core/widgets/app_components.dart';
import '../../dashboard/data/models/calorie_goal_model.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../root_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loading = true;

  String _userName    = '';
  int _calorieGoal = 2000;
  int _proteinGoal = 150;
  int _carbsGoal   = 250;
  int _fatGoal     = 65;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    final name = ref.read(userNameProvider);
    final goal = ref.read(currentGoalProvider);
    if (goal != null) {
      _userName    = name;
      _calorieGoal = goal.dailyCalorieGoal.toInt();
      _proteinGoal = goal.proteinGoal.toInt();
      _carbsGoal   = goal.carbsGoal.toInt();
      _fatGoal     = goal.fatGoal.toInt();
    } else {
      _userName = name;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveGoals() async {
    setState(() => _loading = true);
    
    // Save Name
    await ref.read(storageServiceProvider).saveUserName(_userName);
    ref.read(userNameProvider.notifier).state = _userName;

    // Save Goals
    final goal = CalorieGoalModel(
      dailyCalorieGoal:  _calorieGoal.toDouble(),
      proteinGoal:       _proteinGoal.toDouble(),
      carbsGoal:         _carbsGoal.toDouble(),
      fatGoal:           _fatGoal.toDouble(),
      goalType:          'maintain',
      createdAt:         DateTime.now(),
    );
    
    await ref.read(storageServiceProvider).saveGoal(goal);
    ref.invalidate(currentGoalProvider);
    
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Goals updated successfully \u2705'),
          backgroundColor: AppPalette.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.border),
      ),
      child: TextField(
        onChanged: (v) => _userName = v,
        controller: TextEditingController(text: _userName)..selection = TextSelection.fromPosition(TextPosition(offset: _userName.length)),
        style: AppText.bodyLg.copyWith(color: AppPalette.text, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'Your Name',
          labelStyle: AppText.labelMd.copyWith(color: AppPalette.textSec),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Enter your name...',
          hintStyle: AppText.bodyMd.copyWith(color: AppPalette.textTert),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.bg,
        elevation: 0,
        title: Text('Settings', style: AppText.h2.copyWith(color: AppPalette.text)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppPalette.textSec),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _loading ? null : _saveGoals,
              child: Text(_loading ? '...' : 'Save',
                  style: AppText.labelLg.copyWith(
                      color: AppPalette.accent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppPalette.accent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'PROFILE', icon: Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _buildNameInput(),
                  const SizedBox(height: 32),

                  _SectionHeader(title: 'DAILY GOALS', icon: Icons.track_changes_rounded),
                  const SizedBox(height: 16),
                  _GoalAdjustmentTile(
                    label: 'Calories', value: _calorieGoal, unit: 'kcal',
                    min: 1000, max: 5000, step: 50, color: AppPalette.accent,
                    onChanged: (v) => setState(() => _calorieGoal = v),
                  ),
                  _GoalAdjustmentTile(
                    label: 'Protein', value: _proteinGoal, unit: 'g',
                    min: 30, max: 400, step: 5, color: AppPalette.protein,
                    onChanged: (v) => setState(() => _proteinGoal = v),
                  ),
                  _GoalAdjustmentTile(
                    label: 'Carbohydrates', value: _carbsGoal, unit: 'g',
                    min: 50, max: 500, step: 5, color: AppPalette.carbs,
                    onChanged: (v) => setState(() => _carbsGoal = v),
                  ),
                  _GoalAdjustmentTile(
                    label: 'Fat', value: _fatGoal, unit: 'g',
                    min: 10, max: 200, step: 2, color: AppPalette.fat,
                    onChanged: (v) => setState(() => _fatGoal = v),
                  ),
                  
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'ABOUT APP', icon: Icons.info_outline_rounded),
                  const SizedBox(height: 16),
                  const _InfoTile(label: 'Version', value: '1.2.0 (Stable)'),
                  const _InfoTile(label: 'AI Core', value: 'Llama 3.3 (Vision)'),
                  const _InfoTile(label: 'API Provider', value: 'Groq Cloud'),
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppPalette.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppPalette.accent.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 18, color: AppPalette.accent),
                            const SizedBox(width: 10),
                            Text('AI Disclaimer', 
                                style: AppText.labelSm.copyWith(
                                    color: AppPalette.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nutrition estimates are generated by high-performance AI models based on visual data. While generally accurate, they should be used as references. For medical needs, consult a professional.',
                          style: AppText.bodySm.copyWith(color: AppPalette.textSec, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppPalette.textTert),
        const SizedBox(width: 8),
        Text(title,
            style: AppText.labelXs.copyWith(
              color: AppPalette.textTert, 
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}

class _GoalAdjustmentTile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final Color color;
  final ValueChanged<int> onChanged;

  const _GoalAdjustmentTile({
    required this.label, required this.value, required this.unit,
    required this.min, required this.max, required this.step,
    required this.color, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(label[0], 
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.bodySm.copyWith(color: AppPalette.textSec)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$value', style: AppText.h3.copyWith(color: AppPalette.text)),
                    const SizedBox(width: 4),
                    Text(unit, style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ControlButton(
                  icon: Icons.remove_rounded, 
                  onTap: value > min ? () => onChanged(value - step) : null),
              const SizedBox(width: 8),
              _ControlButton(
                  icon: Icons.add_rounded, 
                  onTap: value < max ? () => onChanged(value + step) : null),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ControlButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: disabled ? AppPalette.surfaceTop : AppPalette.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disabled ? AppPalette.border : AppPalette.accent.withOpacity(0.2),
          ),
        ),
        child: Icon(icon, size: 20,
            color: disabled ? AppPalette.textTert : AppPalette.accent),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodyMd.copyWith(color: AppPalette.textSec)),
          Text(value, style: AppText.labelMd.copyWith(
              color: AppPalette.text, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
