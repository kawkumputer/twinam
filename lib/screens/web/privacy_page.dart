import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                'Privacy Policy',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Last updated: March 31, 2026',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              _buildSection(
                'Introduction',
                'Twin\'Am ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
                isMobile,
              ),
              
              _buildSection(
                '1. Information We Collect',
                'Twin\'Am is designed with privacy in mind. All your data is stored locally on your device using Hive database. We collect and store:\n\n'
                '• Counter data (names, values, goals, icons)\n'
                '• Task information (titles, descriptions, deadlines, priorities)\n'
                '• User preferences (name, language, theme settings)\n'
                '• Achievement and XP progress\n'
                '• Notification preferences\n\n'
                'This data is stored exclusively on your device and is not transmitted to our servers.',
                isMobile,
              ),
              
              _buildSection(
                '2. How We Use Your Information',
                'Your locally stored data is used to:\n\n'
                '• Provide core app functionality (counters, tasks, statistics)\n'
                '• Personalize your experience with your Twin companion\n'
                '• Send local notifications and reminders\n'
                '• Track your progress and achievements\n'
                '• Save your preferences and settings',
                isMobile,
              ),
              
              _buildSection(
                '3. Data Storage and Security',
                'All data is stored locally on your device using Hive, a secure local database. We do not:\n\n'
                '• Transmit your data to external servers\n'
                '• Share your data with third parties\n'
                '• Sell your personal information\n'
                '• Track your activity outside the app\n\n'
                'Your data remains on your device and is protected by your device\'s security measures.',
                isMobile,
              ),
              
              _buildSection(
                '4. Notifications',
                'Twin\'Am uses local notifications to:\n\n'
                '• Remind you about tasks and deadlines\n'
                '• Send motivational messages from your Twin\n'
                '• Notify you of achievements\n\n'
                'These notifications are generated locally on your device. You can disable notifications at any time in your device settings or within the app.',
                isMobile,
              ),
              
              _buildSection(
                '5. Third-Party Services',
                'Twin\'Am does not currently integrate with any third-party analytics or advertising services. The app functions entirely offline with local data storage.',
                isMobile,
              ),
              
              _buildSection(
                '6. Children\'s Privacy',
                'Twin\'Am does not knowingly collect information from children under 13. The app is designed for general audiences and does not require age verification.',
                isMobile,
              ),
              
              _buildSection(
                '7. Data Deletion',
                'You have complete control over your data:\n\n'
                '• Delete individual counters or tasks within the app\n'
                '• Clear all app data through your device settings\n'
                '• Uninstall the app to remove all local data\n\n'
                'Since all data is stored locally, deleting the app will permanently remove all your information.',
                isMobile,
              ),
              
              _buildSection(
                '8. Changes to This Privacy Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                isMobile,
              ),
              
              _buildSection(
                '9. Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                'Email: contact@twinam.app',
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
