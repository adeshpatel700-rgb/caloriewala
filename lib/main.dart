import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/design/theme.dart';
import 'features/dashboard/data/services/storage_service.dart';
import 'features/root_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141414),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Load .env (ignore if missing)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Init Hive (ignore if fails)
  try {
    await Hive.initFlutter();
    await StorageService.init();
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: CalorieWalaApp(),
    ),
  );
}

class CalorieWalaApp extends StatelessWidget {
  const CalorieWalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieWala',
      debugShowCheckedModeBanner: false,
      theme: ModernTheme.dark(),
      darkTheme: ModernTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const AppRootWidget(),
    );
  }
}
