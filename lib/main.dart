import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/counter_screen.dart';
import '../screens/onboarding_screen.dart';
import '../services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();

  // Lock orientation to portrait for stable counting UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(JaapaApp(storage: storage));
}

class JaapaApp extends StatelessWidget {
  final StorageService storage;

  const JaapaApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    const primarySaffron = Color(0xFFD96B00);
    final darkBackground = Color(storage.backgroundColorValue);
    const surfaceDark = Color(0xFF1C1A17);

    return MaterialApp(
      title: 'Jaapa',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySaffron,
          brightness: Brightness.light,
          primary: primarySaffron,
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySaffron,
          brightness: Brightness.dark,
          primary: primarySaffron,
          surface: surfaceDark,
          onSurface: const Color(0xFFEDE8E1),
        ),
      ),
      home: storage.onboarded
          ? CounterScreen(storage: storage)
          : OnboardingScreen(storage: storage),
    );
  }
}