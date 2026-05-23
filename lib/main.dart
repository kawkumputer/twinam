import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'services/widget_service.dart';
import 'services/admob_service.dart';
import 'services/twin_notification_service.dart';
import 'services/social_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize();

  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  }

  final storageService = StorageService();
  await storageService.init();

  // Initialize services with platform checks
  if (!kIsWeb) {
    // Mobile-only services
    final notificationService = NotificationService();
    await notificationService.init();

    final widgetService = WidgetService();
    await widgetService.initialize();

    final adMobService = AdMobService();
    await adMobService.initialize();

    TwinNotificationService().init();
    SocialNotificationService().initIfLoggedIn();
  }

  FlutterNativeSplash.remove();
  runApp(TwinAmApp(storageService: storageService));
}
