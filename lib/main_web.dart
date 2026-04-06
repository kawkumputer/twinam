import 'package:flutter/material.dart';
import 'l10n/web_translations.dart';
import 'screens/web/home_page.dart';
import 'screens/web/privacy_page.dart';
import 'screens/web/terms_page.dart';
import 'screens/web/support_page.dart';

void main() {
  runApp(const TwinAmWebApp());
}

class TwinAmWebApp extends StatefulWidget {
  const TwinAmWebApp({super.key});

  static void setLocale(BuildContext context, String locale) {
    context.findAncestorStateOfType<_TwinAmWebAppState>()?._setLocale(locale);
  }

  @override
  State<TwinAmWebApp> createState() => _TwinAmWebAppState();
}

class _TwinAmWebAppState extends State<TwinAmWebApp> {
  String _locale = 'fr';

  void _setLocale(String locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final l = WebL10n(_locale);
    return MaterialApp(
      title: "Twin'Am - Your Digital Companion",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/privacy':
            return MaterialPageRoute(builder: (_) => PrivacyPage(l: l, locale: _locale));
          case '/terms':
            return MaterialPageRoute(builder: (_) => TermsPage(l: l, locale: _locale));
          case '/support':
            return MaterialPageRoute(builder: (_) => SupportPage(l: l, locale: _locale));
          default:
            return MaterialPageRoute(builder: (_) => HomePage(l: l, locale: _locale));
        }
      },
    );
  }
}
