// Outil de contrôle visuel (non exécuté par `flutter test` : le nom ne finit pas par _test).
// Usage : flutter test test/tools/capture.dart --dart-define=OUT=<dossier> --dart-define=FONTS=<dossier des .ttf>
// FONTS doit contenir Poppins-{Regular,Medium,SemiBold,Bold,ExtraBold,Black}.ttf (google/fonts, licence OFL).
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twinam/models/counter.dart';
import 'package:twinam/providers/achievement_provider.dart';
import 'package:twinam/providers/auth_provider.dart';
import 'package:twinam/providers/challenge_provider.dart';
import 'package:twinam/providers/counter_provider.dart';
import 'package:twinam/providers/settings_provider.dart';
import 'package:twinam/providers/task_provider.dart';
import 'package:twinam/screens/counter_screen.dart';
import 'package:twinam/screens/dashboard_screen.dart';
import 'package:twinam/screens/settings_screen.dart';
import 'package:twinam/screens/stats_screen.dart';
import 'package:twinam/services/auth_service.dart';
import 'package:twinam/services/purchase_service.dart';
import 'package:twinam/services/storage_service.dart';
import 'package:twinam/theme/app_theme.dart';
import 'package:twinam/widgets/pro_sheet.dart';

const out = String.fromEnvironment('OUT', defaultValue: 'build/shots');
const fonts = String.fromEnvironment('FONTS');

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Directory(out).createSync(recursive: true);
  final key = GlobalKey();
  final tmp = Directory.systemTemp.createTempSync('twinam_shots');

  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, (_) async => tmp.path);

  late StorageService storage;
  late PurchaseService purchases;
  late SettingsProvider settings;
  late CounterProvider counters;
  late AchievementProvider achievements;
  late TaskProvider tasks;

  Widget wrap(Widget home, String name) => RepaintBoundary(
        key: key,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: purchases),
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: counters),
            ChangeNotifierProvider.value(value: achievements),
            ChangeNotifierProvider.value(value: tasks),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ChallengeProvider()),
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, s, _) => MaterialApp(
              key: ValueKey(name), // navigateur neuf à chaque écran
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: s.themeMode,
              locale: Locale(s.locale),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('fr')],
              home: home,
            ),
          ),
        ),
      );

  Future<void> shot(WidgetTester t, String name) async {
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await t.pump(const Duration(milliseconds: 1200));
    await t.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  Future<void> show(WidgetTester t, String name, Widget w) async {
    t.view.physicalSize = const Size(393 * 3, 852 * 3); // iPhone 15/16
    t.view.devicePixelRatio = 3;
    t.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    await t.pumpWidget(wrap(w, name));
    await shot(t, name);
    final ex = t.takeException();
    if (ex != null) {
      // ignore: avoid_print
      print('EXC in $name: ${ex.toString().split('\n').first}');
    }
  }

  Future<void> loadFont(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }

  setUpAll(() async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    final mat = '$flutterRoot/bin/cache/artifacts/material_fonts';
    await loadFont('MaterialIcons', ['$mat/materialicons-regular.otf']);
    await loadFont('Roboto', ['$mat/roboto-regular.ttf', '$mat/roboto-bold.ttf']);
    const weights = {
      'regular': 'Regular', '400': 'Regular', '500': 'Medium', '600': 'SemiBold',
      '700': 'Bold', '800': 'ExtraBold', '900': 'Black',
    };
    for (final e in weights.entries) {
      await loadFont('Poppins_${e.key}', ['$fonts/Poppins-${e.value}.ttf']);
    }

    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://example.supabase.co', anonKey: 'test');
    storage = StorageService();
    await storage.init();
    purchases = PurchaseService(storage);
    settings = SettingsProvider(storage)
      ..setLocale('fr')
      ..setUserName('Hamath')
      ..completeOnboarding();
    counters = CounterProvider(storage);
    achievements = AchievementProvider(storage, AuthService());
    tasks = TaskProvider(storage);

    final rnd = Random(4);
    final now = DateTime.now();
    List<CounterEntry> hist(int goal) => [
          for (var d = 35; d >= 1; d--)
            CounterEntry(
              date: DateTime(now.year, now.month, now.day - d, 20),
              value: (goal * (0.4 + rnd.nextDouble() * 0.9)).round(),
            ),
        ];
    final demo = [
      ('water', 'Verres d\'eau', '💧', 5, 8, 0xFF2196F3),
      ('pushups', 'Pompes', '💪', 30, 50, 0xFF7CB342),
      ('read', 'Pages lues', '📖', 12, 20, 0xFFFFB74D),
    ];
    for (final (id, name, emoji, value, goal, color) in demo) {
      await counters.addCounter(Counter(
        id: id, name: name, emoji: emoji, value: value, goal: goal,
        colorValue: color, history: hist(goal),
        createdAt: now.subtract(const Duration(days: 35)),
      ));
    }
  });

  Future<void> run(WidgetTester t, String suffix) async {
    purchases.debugSet(purchased: false);
    await show(t, '01_home_$suffix', const DashboardScreen());
    await show(t, '02_counter_$suffix', const CounterScreen(counterId: 'water'));
    await show(t, '03_stats_free_$suffix', const StatsScreen(counterId: 'water'));
    await show(t, '04_settings_$suffix', const SettingsScreen());
    showProSheet(t.element(find.byType(Scaffold).first), reason: ProReason.counters);
    await t.pump();
    await shot(t, '05_pro_sheet_$suffix');
    purchases.debugSet(purchased: true);
    await show(t, '06_stats_pro_$suffix', const StatsScreen(counterId: 'water'));
  }

  testWidgets('captures', (t) async {
    addTearDown(t.view.reset);
    settings.setThemeMode(ThemeMode.light);
    await run(t, 'light');
    settings.setThemeMode(ThemeMode.dark);
    await run(t, 'dark');
  });
}
