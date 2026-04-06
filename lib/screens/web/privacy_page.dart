import 'package:flutter/material.dart';
import '../../l10n/web_translations.dart';
import '../../main_web.dart';

class PrivacyPage extends StatelessWidget {
  final WebL10n l;
  final String locale;
  const PrivacyPage({super.key, required this.l, required this.locale});

  @override
  Widget build(BuildContext context) {
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
            child: _buildLanguageSelector(context),
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
                l.t('privacyTitle'),
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.t('privacyDate'),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              _buildSection(l.t('privacyIntroTitle'), l.t('privacyIntroContent'), isMobile),
              _buildSection(l.t('privacyCollectTitle'), l.t('privacyCollectContent'), isMobile),
              _buildSection(l.t('privacyUseTitle'), l.t('privacyUseContent'), isMobile),
              _buildSection(l.t('privacyStorageTitle'), l.t('privacyStorageContent'), isMobile),
              _buildSection(l.t('privacyNotifTitle'), l.t('privacyNotifContent'), isMobile),
              _buildSection(l.t('privacyThirdTitle'), l.t('privacyThirdContent'), isMobile),
              _buildSection(l.t('privacyChildrenTitle'), l.t('privacyChildrenContent'), isMobile),
              _buildSection(l.t('privacyDeletionTitle'), l.t('privacyDeletionContent'), isMobile),
              _buildSection(l.t('privacyChangesTitle'), l.t('privacyChangesContent'), isMobile),
              _buildSection(l.t('privacyContactTitle'), l.t('privacyContactContent'), isMobile),
              
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
  }

  Widget _buildLanguageSelector(BuildContext context) {
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
          onTap: () => TwinAmWebApp.setLocale(context, lang['code']!),
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

  Widget _buildSection(String title, String content, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
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
