import 'package:flutter/material.dart';
import 'screens/web/home_page.dart';
import 'screens/web/privacy_page.dart';
import 'screens/web/terms_page.dart';
import 'screens/web/support_page.dart';

void main() {
  runApp(const TwinAmWebApp());
}

class TwinAmWebApp extends StatelessWidget {
  const TwinAmWebApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      routes: {
        '/': (context) => const HomePage(),
        '/privacy': (context) => const PrivacyPage(),
        '/terms': (context) => const TermsPage(),
        '/support': (context) => const SupportPage(),
      },
    );
  }
}
