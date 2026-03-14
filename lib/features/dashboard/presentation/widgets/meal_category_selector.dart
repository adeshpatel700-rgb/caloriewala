import 'package:flutter/material.dart';
import '../../../../core/design/colors.dart';
import '../../../../core/design/typography.dart';

class MealCategorySelector extends StatelessWidget {
  const MealCategorySelector({super.key});

  static final _categories = [
    {'label': 'Breakfast', 'icon': Icons.free_breakfast_outlined, 'color': AppPalette.breakfast},
    {'label': 'Lunch',     'icon': Icons.lunch_dining_outlined,   'color': AppPalette.lunch},
    {'label': 'Dinner',    'icon': Icons.dinner_dining_outlined,  'color': AppPalette.dinner},
    {'label': 'Snack',     'icon': Icons.cookie_outlined,         'color': AppPalette.snack},
  ];

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MealCategorySelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppPalette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppPalette.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Select Meal Category',
              style: AppText.h3.copyWith(color: AppPalette.text)),
          const SizedBox(height: 20),
          ..._categories.map((cat) => _CategoryRow(
            icon: cat['icon'] as IconData,
            label: cat['label'] as String,
            color: cat['color'] as Color,
            onTap: () => Navigator.pop(context, cat['label']),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text('Cancel',
                  style: AppText.bodyMd.copyWith(color: AppPalette.textSec),
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? AppPalette.surfaceTop : AppPalette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.fromBorderSide(BorderSide(
            color: _pressed ? widget.color.withAlpha(120) : AppPalette.border,
          )),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: widget.color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 18, color: widget.color),
            ),
            const SizedBox(width: 14),
            Text(widget.label,
                style: AppText.bodyLg.copyWith(
                    color: AppPalette.text, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: AppPalette.textTert),
          ],
        ),
      ),
    );
  }
}
