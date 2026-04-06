import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/web_translations.dart';
import '../../main_web.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: webLocale,
      builder: (context, locale, _) {
        final l = WebL10n(locale);
        final isMobile = MediaQuery.of(context).size.width < 768;
        return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.jpeg', height: 32, width: 32, fit: BoxFit.contain),
            const SizedBox(width: 12),
            const Text("Twin'Am"),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2196F3),
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildLanguageSelector(context, locale),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100,
            vertical: isMobile ? 40 : 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.t('supportTitle'),
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.t('supportSub'),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              _buildContactSection(isMobile, l),
              
              const SizedBox(height: 60),
              
              Text(
                l.t('faqTitle'),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 32),
              
              for (int i = 1; i <= 9; i++)
                _buildFAQItem(l.t('faq${i}Q'), l.t('faq${i}A'), isMobile),
              
              const SizedBox(height: 60),
              
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l.t('backHome'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, String locale) {
    final languages = [
      {'code': 'en', 'flag': '🇬🇧'},
      {'code': 'fr', 'flag': '🇫🇷'},
      {'code': 'ar', 'flag': '🇸🇦'},
      {'code': 'es', 'flag': '🇪🇸'},
      {'code': 'de', 'flag': '🇩🇪'},
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: languages.map((lang) {
        final isSelected = locale == lang['code'];
        return InkWell(
          onTap: () => webLocale.value = lang['code']!,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isSelected ? Border.all(color: const Color(0xFF2196F3), width: 1.5) : null,
            ),
            child: Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection(bool isMobile, WebL10n l) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.email_outlined, size: 48, color: Color(0xFF2196F3)),
          const SizedBox(height: 16),
          Text(
            l.t('contactTitle'),
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.t('contactSub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => launchUrl(Uri.parse('mailto:contact@twinam.app')),
            icon: const Icon(Icons.send),
            label: const Text('contact@twinam.app'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 16 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
