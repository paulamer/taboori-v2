import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/datasources/local_datasource.dart';
import 'presentation/shared/providers.dart';
import 'features/settings/presentation/simple_mode.dart';
import 'core/services/smart_notification_service.dart';

void main() async {
  // Step 1: Ensure Flutter engine and native binary channels are ready
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize Hive fast disk storage for offline caching & sessions
  await LocalDataSource.init();

  // Step 3: Initialize local Android notification channels (sound + vibration)
  await SmartNotificationService.initialize();

  // Step 4: Safely connect to Firebase with 10s timeout; fallback to Mock mode if offline
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10)); // 10s connection timeout
    debugPrint('🚀 Firebase initialized successfully!'); // Online Cloud Firestore mode
  } catch (e) {
    debugPrint('⚠️ Firebase failed to initialize: $e'); // Log network/auth failure
    debugPrint('💡 Fallback: Taboori is running in Mock Repository Mode for testing.'); // Safe fallback
  }

  // Step 5: Start app wrapped in ProviderScope for Riverpod reactive state
  runApp(
    const ProviderScope(
      child: MyApp(), // Root widget
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);       // Listen to GoRouter navigation state
    final locale = ref.watch(localeProvider);       // Listen to language: 'ar' or 'en'
    final themeMode = ref.watch(themeProvider);     // Listen to theme: Light or Dark mode
    final isSimple = ref.watch(simpleModeProvider); // Listen to Senior Accessibility mode

    return MaterialApp.router(
      title: 'طابوري - Taboori', // App title in Android task switcher
      debugShowCheckedModeBanner: false, // Hide debug banner for clean presentation
      theme: SimpleModeTheme.apply(AppTheme.lightTheme, isSimple),   // Apply Light Theme (+ Senior mode scaling)
      darkTheme: SimpleModeTheme.apply(AppTheme.darkTheme, isSimple), // Apply Dark Theme (+ Senior mode scaling)
      themeMode: themeMode,        // Dynamic light/dark theme switcher
      routerConfig: router,        // GoRouter declarative route table
      locale: Locale(locale),      // Active language locale (Arabic or English)
      supportedLocales: const [Locale('ar'), Locale('en')], // Supported language list
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Material widgets RTL/LTR
        GlobalWidgetsLocalizations.delegate,  // Generic widget layout directions
        GlobalCupertinoLocalizations.delegate,// iOS style dialogs localization
      ],
    );
  }
}
