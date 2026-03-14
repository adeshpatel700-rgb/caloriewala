import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_shell.dart';

/// User's name — seeded synchronously in main()
final userNameProvider = StateProvider<String>((ref) => '');

/// Root widget — goes straight to AppShell, no splash or onboarding
class AppRootWidget extends ConsumerWidget {
  const AppRootWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AppShell();
  }
}
