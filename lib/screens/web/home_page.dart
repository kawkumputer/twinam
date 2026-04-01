import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header/Navigation
            _buildHeader(context, isMobile),
            
            // Hero Section
            _buildHeroSection(context, isMobile),
            
            // Twin Avatars Section
            _buildTwinAvatarsSection(context, isMobile),
            
            // Features Section
            _buildFeaturesSection(context, isMobile),
            
            // CTA Section
            _buildCTASection(context, isMobile),
            
            // Footer
            _buildFooter(context, isMobile),
          ],
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
          
          // Navigation
          if (!isMobile)
            Row(
              children: [
                _buildNavLink(context, 'Privacy', '/privacy'),
                const SizedBox(width: 24),
                _buildNavLink(context, 'Terms', '/terms'),
                const SizedBox(width: 24),
                _buildNavLink(context, 'Support', '/support'),
              ],
            ),
        ],
      ),
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
            'Ton compagnon digital pour',
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
            'construire de meilleures habitudes',
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
            'Avec Twin\'Am, ton Twin personnel t\'accompagne chaque jour pour atteindre tes objectifs et booster ta productivité.',
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
            'Rencontre ton Twin',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ton compagnon qui évolue avec toi',
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
                'Fier de toi ! 🌟',
                'Quand tu atteins tes objectifs',
                const Color(0xFF4CAF50),
                isMobile,
              ),
              _buildTwinAvatarCard(
                'assets/neutral-avatar.jpeg',
                'Continue ! 💪',
                'Quand tu fais des progrès',
                const Color(0xFF2196F3),
                isMobile,
              ),
              _buildTwinAvatarCard(
                'assets/sad-avatar.jpeg',
                'Tu peux mieux faire ! 🔥',
                'Quand tu as besoin de motivation',
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
            'Fonctionnalités',
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
                '🤝',
                'Ton Twin Personnel',
                'Un compagnon digital qui t\'encourage et te motive chaque jour',
                isMobile,
              ),
              _buildFeatureCard(
                '📊',
                'Suivi d\'Habitudes',
                'Crée des compteurs personnalisés pour suivre tes habitudes quotidiennes',
                isMobile,
              ),
              _buildFeatureCard(
                '✅',
                'Gestion de Tâches',
                'Organise tes tâches avec des priorités et des échéances',
                isMobile,
              ),
              _buildFeatureCard(
                '📈',
                'Statistiques',
                'Visualise tes progrès avec des graphiques et des stats détaillées',
                isMobile,
              ),
              _buildFeatureCard(
                '🎮',
                'Gamification',
                'Gagne de l\'XP, monte de niveau et débloque des achievements',
                isMobile,
              ),
              _buildFeatureCard(
                '🔔',
                'Rappels Intelligents',
                'Reçois des notifications personnalisées pour rester sur la bonne voie',
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
            'Prêt à transformer tes habitudes ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Télécharge Twin\'Am gratuitement et commence ton voyage vers une meilleure version de toi-même.',
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
                'https://apps.apple.com',
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
              _buildFooterLink(context, 'Privacy Policy', '/privacy'),
              _buildFooterLink(context, 'Terms of Service', '/terms'),
              _buildFooterLink(context, 'Support', '/support'),
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
            '© 2026 Twin\'Am. All rights reserved.',
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
