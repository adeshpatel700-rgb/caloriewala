import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design/colors.dart';
import '../core/design/typography.dart';
import 'dashboard/presentation/dashboard_screen.dart';
import 'home/presentation/home_screen.dart';
import 'history/presentation/history_screen.dart';

/// State provider for bottom nav
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// App shell with premium custom bottom navigation bar
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const DashboardScreen(),
      HomeScreen(),
      const HistoryScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppPalette.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppPalette.bg,
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: currentIndex,
          onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        border: Border(
          top: BorderSide(color: AppPalette.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                activeIcon: Icons.grid_view_rounded,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _ScanNavItem(
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'History',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppPalette.accent : AppPalette.textTert,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppText.labelXs.copyWith(
                color: isActive ? AppPalette.accent : AppPalette.textTert,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ScanNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 38,
              decoration: BoxDecoration(
                color: isActive ? AppPalette.accent : AppPalette.accentMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppPalette.accent : AppPalette.border,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 20,
                color: isActive ? Colors.black : AppPalette.accent,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Scan',
              style: AppText.labelXs.copyWith(
                color: isActive ? AppPalette.accent : AppPalette.textTert,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
