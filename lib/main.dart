import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions, kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

import 'firebase_options.dart';
import 'app_routes.dart';
import 'screens/levels_tree_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/final_project_screen.dart';
import 'screens/avatar_selection_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/subscription_screen.dart';
import 'data/services/storage_service.dart';
import 'data/services/gamification_service.dart';
import 'data/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Для веб-версии пропускаем Firebase
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization skipped: $e');
    }
  }

  try {
    await StorageService.init();
    await GamificationService.init();
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
  
  runApp(const NeuroApp());
}

/// Корневое приложение: тема, локаль, именованные маршруты.
///
/// Для [TextField] и виджетов Material на веб нужны [localizationsDelegates]
/// (иначе — «No MaterialLocalizations found»).
class NeuroApp extends StatelessWidget {
  const NeuroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'НейроИсследователь',
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.welcome:
            return MaterialPageRoute<void>(
              builder: (_) => const WelcomeScreen(),
              settings: settings,
            );
          case AppRoutes.onboarding:
            final name = settings.arguments as String? ?? '';
            return MaterialPageRoute<void>(
              builder: (_) => OnboardingScreen(userName: name),
              settings: settings,
            );
          case AppRoutes.levels:
            final name = settings.arguments as String? ?? '';
            return MaterialPageRoute<void>(
              builder: (_) => LevelsTreeScreen(userName: name),
              settings: settings,
            );
          case AppRoutes.lesson:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute<void>(
              builder: (_) => LessonScreen(
                lessonId: args?['lessonId'] ?? 1,
                userName: args?['userName'] ?? '',
                onComplete: args?['onComplete'] as VoidCallback?,
              ),
              settings: settings,
            );
          case AppRoutes.avatar:
            return MaterialPageRoute<void>(
              builder: (_) => const AvatarSelectionScreen(),
              settings: settings,
            );
          case AppRoutes.parentDashboard:
            return MaterialPageRoute<void>(
              builder: (_) => const ParentDashboardScreen(),
              settings: settings,
            );
          case AppRoutes.auth:
            return MaterialPageRoute<void>(
              builder: (_) => const AuthScreen(),
              settings: settings,
            );
          case AppRoutes.subscription:
            return MaterialPageRoute<void>(
              builder: (_) => const SubscriptionScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const WelcomeScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
