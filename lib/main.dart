import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/widget_service.dart';
import 'services/admob_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final storageService = StorageService();
  await storageService.init();
  
  // Force dark mode by default for all users
  storageService.ensureDarkMode();

  // Initialize services with platform checks
  if (!kIsWeb) {
    // Mobile-only services
    final notificationService = NotificationService();
    await notificationService.init();

    final widgetService = WidgetService();
    await widgetService.initialize();

    final adMobService = AdMobService();
    await adMobService.initialize();
  }

  FlutterNativeSplash.remove();
  runApp(TwinAmApp(storageService: storageService));
}
