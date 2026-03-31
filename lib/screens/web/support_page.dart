import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.jpeg',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text("Twin'Am"),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2196F3),
        elevation: 1,
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
                'Support',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nous sommes là pour t\'aider',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              // Contact Section
              _buildContactSection(isMobile),
              
              const SizedBox(height: 60),
              
              // FAQ Section
              Text(
                'Questions Fréquentes',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildFAQItem(
                'Comment créer un nouveau compteur ?',
                'Appuie sur le bouton "+" en bas à droite du Dashboard, puis remplis les informations de ton compteur (nom, objectif, icône, etc.).',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment définir un objectif quotidien ?',
                'Lors de la création ou modification d\'un compteur, active l\'option "Objectif" et définis le nombre que tu souhaites atteindre chaque jour.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment ajouter une tâche ?',
                'Clique sur l\'icône de tâches dans le header du Dashboard, puis sur le bouton "+" pour créer une nouvelle tâche avec un titre, une description, une échéance et une priorité.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Mes données sont-elles synchronisées ?',
                'Actuellement, toutes tes données sont stockées localement sur ton appareil. Elles ne sont pas synchronisées dans le cloud, ce qui garantit ta vie privée.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment désactiver les notifications ?',
                'Va dans Paramètres > Notifications et désactive les notifications que tu ne souhaites pas recevoir. Tu peux aussi gérer les notifications dans les paramètres de ton appareil.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment changer la langue de l\'app ?',
                'Va dans Paramètres > Langue et sélectionne Français ou English selon ta préférence.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Que se passe-t-il si je désinstalle l\'app ?',
                'Toutes tes données locales seront supprimées. Assure-toi d\'exporter tes données si tu souhaites les conserver avant de désinstaller l\'app.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment fonctionne le système de Twin ?',
                'Ton Twin est un compagnon virtuel qui réagit à tes progrès. Il est heureux quand tu atteins tes objectifs, neutre quand tu fais des efforts, et triste quand tu as besoin de motivation. Il t\'envoie des messages personnalisés pour t\'encourager.',
                isMobile,
              ),
              
              _buildFAQItem(
                'Comment gagner de l\'XP et monter de niveau ?',
                'Tu gagnes de l\'XP en atteignant tes objectifs quotidiens, en complétant des tâches et en maintenant des séries (streaks). Plus tu es régulier, plus tu montes de niveaux rapidement !',
                isMobile,
              ),
              
              const SizedBox(height: 60),
              
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isMobile) {
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
          const Icon(
            Icons.email_outlined,
            size: 48,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          Text(
            'Contacte-nous',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Une question ? Un problème ? Une suggestion ?',
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
