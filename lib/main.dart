import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/design/theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/dashboard/data/services/storage_service.dart';
import 'features/root_widget.dart';

void main() async {
  // Wrap everything in error handling
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlays
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Load environment variables (optional - won't crash if file is missing)
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ Environment loaded successfully');
    } catch (e) {
      debugPrint(
          '⚠️ Warning: .env file not found. Using default configuration.');
    }

    // Initialize Hive for local storage with error handling
    try {
      await Hive.initFlutter();
      // Initialize storage service (opens boxes)
      await StorageService.init();
      debugPrint('✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Hive initialization failed: $e');
    }

    runApp(
      const ProviderScope(
        child: CalorieWalaApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('❌ Fatal error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class CalorieWalaApp extends ConsumerWidget {
  const CalorieWalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'CalorieWala',
      debugShowCheckedModeBanner: false,
      theme: ModernTheme.light(),
      darkTheme: ModernTheme.dark(),
      themeMode: themeMode,
      home: const AppRootWidget(),
      // Error handling for widget build errors
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorDetails.exception.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return widget!;
      },
    );
  }
}
