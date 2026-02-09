import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

/// Animated theme toggle button with smooth transitions
class AnimatedThemeToggle extends ConsumerStatefulWidget {
  const AnimatedThemeToggle({super.key});

  @override
  ConsumerState<AnimatedThemeToggle> createState() =>
      _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends ConsumerState<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Set initial state based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
      if (isDark) {
        _controller.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 * 2,
            child: IconButton(
              icon: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDark ? Colors.amber : AppColors.primary,
              ),
              onPressed: _toggleTheme,
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              splashRadius: 24,
            ),
          ),
        );
      },
    );
  }
}
