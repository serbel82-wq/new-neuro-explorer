import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed (expected in web without config): $e');
  }
  
  await GamificationService.init();
  
  runApp(const NeuroApp());
}

class NeuroApp extends StatefulWidget {
  const NeuroApp({super.key});

  @override
  State<NeuroApp> createState() => _NeuroAppState();

  static Future<void> toggleTheme(BuildContext context) async {
    final state = context.findAncestorStateOfType<_NeuroAppState>();
    await state?._toggleTheme();
  }
}

class _NeuroAppState extends State<NeuroApp> {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final isDark = _themeMode == ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

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
      themeMode: _themeMode,
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
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
              builder: (_) => FutureBuilder(
                future: ParentDashboardScreen.init(),
                builder: (context, snapshot) => const ParentDashboardScreen(),
              ),
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
      builder: (context, child) {
        // Добавляем кнопку переключения темы для отладки/тестирования
        return ThemeToggleWidget(
          themeMode: _themeMode,
          onToggle: _toggleTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class ThemeToggleWidget extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggle;
  final Widget child;

  const ThemeToggleWidget({
    super.key,
    required this.themeMode,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
