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
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp()
              .timeout(const Duration(seconds: 10));
        }
        FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
        debugPrint('[Firebase] Ready. Apps: ${Firebase.apps.length}');
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

      // Direct FCM token debug — runs regardless of SocialNotificationService
      _debugFCMToken();
    }
  } catch (e, s) {
    debugPrint('[Main] Init error: $e\n$s');
  } finally {
    FlutterNativeSplash.remove();
  }

  runApp(TwinAmApp(storageService: storageService));
}

/// Standalone debug function to verify FCM token generation.
/// Saves debug info to fcm_token field so we can see status from Supabase dashboard.
Future<void> _debugFCMToken() async {
  try {
    final firebaseApps = Firebase.apps.length;
    debugPrint('[FCM-DEBUG] Firebase apps: $firebaseApps');

    final messaging = FirebaseMessaging.instance;

    // Check notification settings
    final settings = await messaging.getNotificationSettings();
    final authStatus = settings.authorizationStatus.toString();
    debugPrint('[FCM-DEBUG] Auth status: $authStatus');

    // Try to get APNs token (iOS only)
    String? apns;
    for (int i = 0; i < 10; i++) {
      apns = await messaging.getAPNSToken();
      if (apns != null) break;
      debugPrint('[FCM-DEBUG] APNs attempt ${i + 1}/10 - null, waiting 2s...');
      await Future.delayed(const Duration(seconds: 2));
    }
    debugPrint('[FCM-DEBUG] APNs token: ${apns != null ? "OK" : "NULL after retries"}');

    // Get FCM token
    String? fcmToken;
    if (apns != null) {
      fcmToken = await messaging.getToken();
      debugPrint('[FCM-DEBUG] FCM token: ${fcmToken != null ? "OK" : "NULL"}');
    }

    // Save result (token or debug info) so we can see it in Supabase
    final user = SupabaseService.currentUser;
    if (user != null) {
      final valueToSave = fcmToken ?? 'DEBUG:firebase=$firebaseApps|auth=$authStatus|apns=${apns != null ? "ok" : "null"}';
      await SupabaseService.client
          .from('profiles')
          .update({'fcm_token': valueToSave})
          .eq('id', user.id);
      debugPrint('[FCM-DEBUG] Saved to DB: ${fcmToken != null ? "real token" : valueToSave}');
    } else {
      debugPrint('[FCM-DEBUG] No user logged in — waiting for auth...');
      // Listen for auth and retry once
      SupabaseService.authStateChanges.first.then((_) async {
        await Future.delayed(const Duration(seconds: 3));
        final u = SupabaseService.currentUser;
        if (u != null) {
          final token = await messaging.getToken();
          final val = token ?? 'DEBUG:delayed|apns=${apns != null ? "ok" : "null"}';
          await SupabaseService.client.from('profiles').update({'fcm_token': val}).eq('id', u.id);
          debugPrint('[FCM-DEBUG] Delayed save: $val');
        }
      });
    }
  } catch (e, s) {
    debugPrint('[FCM-DEBUG] ERROR: $e\n$s');
    // Try to save error to DB
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        await SupabaseService.client
            .from('profiles')
            .update({'fcm_token': 'ERROR:${e.toString().substring(0, 50)}'})
            .eq('id', user.id);
      }
    } catch (_) {}
  }
}
