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

  final storageService = StorageService();

  try {
    await dotenv.load(fileName: '.env');
    await SupabaseService.initialize();

    if (!kIsWeb) {
      try {
        await Firebase.initializeApp()
            .timeout(const Duration(seconds: 10));
        FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
      } catch (e) {
        debugPrint('[Firebase] Init failed: $e');
      }
    }

    await storageService.init();

    if (!kIsWeb) {
      try {
        await NotificationService()
            .init()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[NotificationService] Init failed: $e');
      }

      try {
        await WidgetService()
            .initialize()
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('[WidgetService] Init failed: $e');
      }

      try {
        await AdMobService()
            .initialize()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[AdMobService] Init failed: $e');
      }

      TwinNotificationService().init();
      SocialNotificationService().initIfLoggedIn();
    }
  } catch (e, s) {
    debugPrint('[Main] Init error: $e\n$s');
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(TwinAmApp(storageService: storageService));
}
