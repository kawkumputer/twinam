import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'providers/achievement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/counter_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/counter_screen.dart';
import 'screens/create_counter_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/widget_settings_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/daily_verdict_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'screens/friends/friends_screen.dart';
import 'screens/level_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/upgrader_messages.dart';
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
        ChangeNotifierProvider(
          create: (_) => TaskProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChallengeProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final isDark = settings.themeMode == ThemeMode.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            child: MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            title: "Twin'Am",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settings.themeMode,
            // Add RTL support for Arabic
            locale: Locale(settings.locale),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
              Locale('es'),
              Locale('ar'),
              Locale('de'),
            ],
            home: UpgradeAlert(
              upgrader: Upgrader(
                durationUntilAlertAgain: const Duration(days: 1),
                messages: _getUpgraderMessages(settings.locale),
              ),
              child: Directionality(
                textDirection: settings.locale == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: Consumer<SettingsProvider>(
                  builder: (context, s, _) {
                    if (!s.onboardingCompleted) {
                      return const OnboardingScreen();
                    }
                    return const DashboardScreen();
                  },
                ),
              ),
            ),
            onGenerateRoute: (routeSettings) {
              final locale = settings.locale;
              switch (routeSettings.name) {
                case '/counter':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(CounterScreen(counterId: counterId), locale: locale);
                case '/create':
                  return _buildRoute(const CreateCounterScreen(), locale: locale);
                case '/edit':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(CreateCounterScreen(editCounterId: counterId), locale: locale);
                case '/stats':
                  final counterId = routeSettings.arguments as String;
                  return _buildRoute(StatsScreen(counterId: counterId), locale: locale);
                case '/settings':
                  return _buildRoute(const SettingsScreen(), locale: locale);
                case '/widget-settings':
                  if (defaultTargetPlatform == TargetPlatform.android) {
                    return _buildRoute(const WidgetSettingsScreen(), locale: locale);
                  }
                  return _buildRoute(const Scaffold(body: Center(child: Text('Feature not available on iOS'))), locale: locale);
                case '/achievements':
                  return _buildRoute(const AchievementsScreen(), locale: locale);
                case '/verdict':
                  return _buildRoute(const DailyVerdictScreen(), locale: locale);
                case '/tasks':
                  return _buildRoute(const TasksScreen(), locale: locale);
                case '/friends':
                  return _buildRoute(const FriendsScreen(), locale: locale);
                case '/challenges':
                  return _buildRoute(const ChallengesScreen(), locale: locale);
                case '/level':
                  return _buildRoute(const LevelScreen(), locale: locale);
                case '/create-task':
                  return _buildRoute(const CreateTaskScreen(), locale: locale);
                case '/edit-task':
                  final taskId = routeSettings.arguments as String;
                  return _buildRoute(CreateTaskScreen(editTaskId: taskId), locale: locale);
                default:
                  return _buildRoute(const DashboardScreen(), locale: locale);
              }
            },
          ),
          );
        },
      ),
    );
  }

  static UpgraderMessages _getUpgraderMessages(String locale) {
    switch (locale) {
      case 'fr':
        return UpgraderMessagesFr();
      case 'ar':
        return UpgraderMessagesAr();
      case 'es':
        return UpgraderMessagesEs();
      case 'de':
        return UpgraderMessagesDe();
      default:
        return UpgraderMessages(code: 'en');
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, {String? locale}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Directionality(
        textDirection: locale == 'ar' 
            ? TextDirection.rtl 
            : TextDirection.ltr,
        child: page,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: locale == 'ar' 
                ? const Offset(-1.0, 0.0)  // Slide from right for RTL
                : const Offset(1.0, 0.0),  // Slide from left for LTR
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}
