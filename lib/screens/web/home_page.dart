import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/web_translations.dart';
import '../../main_web.dart';

class HomePage extends StatelessWidget {
  final WebL10n l;
  final String locale;
  const HomePage({super.key, required this.l, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            children: [
            _buildHeader(context, isMobile),
            _buildHeroSection(context, isMobile),
            _buildTwinAvatarsSection(context, isMobile),
            _buildFeaturesSection(context, isMobile),
            _buildCTASection(context, isMobile),
            _buildDonateSection(context, isMobile),
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/logo.jpeg',
                height: isMobile ? 32 : 40,
                width: isMobile ? 32 : 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Text(
                "Twin'Am",
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          
          // Navigation + Language selector
          Row(
            children: [
              if (!isMobile) ...[
                _buildNavLink(context, l.t('navPrivacy'), '/privacy'),
                const SizedBox(width: 24),
                _buildNavLink(context, l.t('navTerms'), '/terms'),
                const SizedBox(width: 24),
                _buildNavLink(context, l.t('navSupport'), '/support'),
                const SizedBox(width: 24),
              ],
              _buildLanguageSelector(context),
            ],
          ),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isSelected ? Border.all(color: const Color(0xFF2196F3), width: 1.5) : null,
            ),
            child: Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavLink(BuildContext context, String text, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        children: [
          Text(
            l.t('heroTitle1'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 48,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.t('heroTitle2'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 48,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2196F3),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.t('heroSub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String text, IconData icon, String url, bool isMobile) {
    return ElevatedButton.icon(
      onPressed: () => launchUrl(Uri.parse(url)),
      icon: Icon(icon, size: isMobile ? 20 : 24),
      label: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 32,
          vertical: isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTwinAvatarsSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        children: [
          Text(
            l.t('meetTwin'),
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.t('meetTwinSub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildTwinAvatarCard(
                'assets/happy-avatar.jpeg',
                l.t('twinHappy'),
                l.t('twinHappyDesc'),
                const Color(0xFF4CAF50),
                isMobile,
              ),
              _buildTwinAvatarCard(
                'assets/neutral-avatar.jpeg',
                l.t('twinNeutral'),
                l.t('twinNeutralDesc'),
                const Color(0xFF2196F3),
                isMobile,
              ),
              _buildTwinAvatarCard(
                'assets/sad-avatar.jpeg',
                l.t('twinSad'),
                l.t('twinSadDesc'),
                const Color(0xFFFF7043),
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTwinAvatarCard(String imagePath, String message, String description, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            l.t('features'),
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 32),
          
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                '\ud83e\udd1d',
                l.t('feat1Title'),
                l.t('feat1Desc'),
                isMobile,
              ),
              _buildFeatureCard(
                '\ud83d\udcca',
                l.t('feat2Title'),
                l.t('feat2Desc'),
                isMobile,
              ),
              _buildFeatureCard(
                '\u2705',
                l.t('feat3Title'),
                l.t('feat3Desc'),
                isMobile,
              ),
              _buildFeatureCard(
                '\ud83d\udcc8',
                l.t('feat4Title'),
                l.t('feat4Desc'),
                isMobile,
              ),
              _buildFeatureCard(
                '\ud83c\udfae',
                l.t('feat5Title'),
                l.t('feat5Desc'),
                isMobile,
              ),
              _buildFeatureCard(
                '\ud83d\udd14',
                l.t('feat6Title'),
                l.t('feat6Desc'),
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            l.t('ctaTitle'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('ctaSub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildDownloadButton(
                'App Store',
                Icons.apple,
                'https://apps.apple.com/us/app/twinam/id6761271353',
                isMobile,
              ),
              _buildDownloadButton(
                'Google Play',
                Icons.android,
                'https://play.google.com',
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonateSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFDD57).withValues(alpha: 0.1),
            const Color(0xFF0070BA).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            l.t('donateTitle'),
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l.t('donateSub'),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildDonateButton(
                context,
                'Buy Me a Coffee',
                '\u2615',
                const Color(0xFFFFDD57),
                'https://buymeacoffee.com/hamathkane',
                isMobile,
              ),
              _buildDonateButton(
                context,
                'PayPal',
                '\u2764',
                const Color(0xFF0070BA),
                'https://paypal.me/HamathKane',
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonateButton(
    BuildContext context,
    String title,
    String emoji,
    Color color,
    String url,
    bool isMobile,
  ) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 32,
          vertical: isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 40,
      ),
      color: Colors.grey[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.jpeg',
                height: isMobile ? 28 : 32,
                width: isMobile ? 28 : 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                "Twin'Am",
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink(context, l.t('privacyPolicy'), '/privacy'),
              _buildFooterLink(context, l.t('termsOfService'), '/terms'),
              _buildFooterLink(context, l.t('navSupport'), '/support'),
            ],
          ),
          
          const SizedBox(height: 24),
          Text(
            'contact@twinam.app',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.t('copyright'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ); 
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
