import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/counter_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/counter_screen.dart';
import 'screens/create_counter_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/stats_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

class TwinAmApp extends StatelessWidget {
  final StorageService storageService;

  const TwinAmApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => CounterProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementProvider(storageService),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final isDark = settings.themeMode == ThemeMode.dark;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ));
          return MaterialApp(
            title: "Twin'Am",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settings.themeMode,
            home: const DashboardScreen(),
            onGenerateRoute: (routeSettings) {
              switch (routeSettings.name) {
                case '/counter':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(CounterScreen(counterId: counterId));
                case '/create':
                  return _buildRoute(const CreateCounterScreen());
                case '/edit':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(CreateCounterScreen(editCounterId: counterId));
                case '/stats':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(StatsScreen(counterId: counterId));
                case '/settings':
                  return _buildRoute(const SettingsScreen());
                case '/achievements':
                  return _buildRoute(const AchievementsScreen());
                default:
                  return _buildRoute(const DashboardScreen());
              }
            },
          );
        },
      ),
    );
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.03, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        final fadeTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
