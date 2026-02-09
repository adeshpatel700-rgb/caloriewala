import 'package:flutter/material.dart';
import '../../../../core/design/spacing.dart';

class MealCategorySelector extends StatelessWidget {
  const MealCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Meal Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _CategoryOption(
            icon: Icons.free_breakfast,
            label: 'Breakfast',
            color: const Color(0xFFFFB74D),
            onTap: () => Navigator.pop(context, 'Breakfast'),
          ),
          const SizedBox(height: 12),
          _CategoryOption(
            icon: Icons.lunch_dining,
            label: 'Lunch',
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.pop(context, 'Lunch'),
          ),
          const SizedBox(height: 12),
          _CategoryOption(
            icon: Icons.dinner_dining,
            label: 'Dinner',
            color: const Color(0xFF42A5F5),
            onTap: () => Navigator.pop(context, 'Dinner'),
          ),
          const SizedBox(height: 12),
          _CategoryOption(
            icon: Icons.cookie,
            label: 'Snack',
            color: const Color(0xFFAB47BC),
            onTap: () => Navigator.pop(context, 'Snack'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MealCategorySelector(),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
