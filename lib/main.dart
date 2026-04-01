import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final widgetService = WidgetService();
  await widgetService.initialize();

  FlutterNativeSplash.remove();
  runApp(TwinAmApp(storageService: storageService));
}
