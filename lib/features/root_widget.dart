import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/simple_splash_screen.dart';
import '../features/app_shell.dart';

/// Provider to track splash screen completion
final splashCompletedProvider = StateProvider<bool>((ref) => false);

/// Root widget that shows splash then navigates to app
class AppRootWidget extends ConsumerWidget {
  const AppRootWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashCompleted = ref.watch(splashCompletedProvider);

    if (!splashCompleted) {
      return SimpleSplashScreen(
        onComplete: () {
          ref.read(splashCompletedProvider.notifier).state = true;
        },
      );
    }

    return const AppShell();
  }
}
