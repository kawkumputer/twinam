import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
                'Terms of Service',
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
                'Welcome to Twin\'Am. By downloading, installing, or using our mobile application, you agree to be bound by these Terms of Service. Please read them carefully.',
                isMobile,
              ),
              
              _buildSection(
                '1. Acceptance of Terms',
                'By accessing and using Twin\'Am, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms of Service, please do not use the app.',
                isMobile,
              ),
              
              _buildSection(
                '2. Description of Service',
                'Twin\'Am is a productivity and habit-tracking mobile application that provides:\n\n'
                '• Habit tracking with customizable counters\n'
                '• Task management with priorities and deadlines\n'
                '• Personal Twin companion for motivation\n'
                '• Statistics and progress visualization\n'
                '• Achievement system and gamification\n'
                '• Local notifications and reminders',
                isMobile,
              ),
              
              _buildSection(
                '3. User Responsibilities',
                'You agree to:\n\n'
                '• Use the app for lawful purposes only\n'
                '• Not attempt to reverse engineer or modify the app\n'
                '• Not use the app in any way that could damage or impair the service\n'
                '• Maintain the security of your device\n'
                '• Be responsible for all data entered into the app',
                isMobile,
              ),
              
              _buildSection(
                '4. Local Data Storage',
                'Twin\'Am stores all data locally on your device. You acknowledge that:\n\n'
                '• You are responsible for backing up your data\n'
                '• We are not responsible for data loss due to device issues\n'
                '• Uninstalling the app will delete all local data\n'
                '• Data is not synced across devices (unless cloud features are added)',
                isMobile,
              ),
              
              _buildSection(
                '5. Intellectual Property',
                'The Twin\'Am app, including its design, features, graphics, and content, is owned by us and protected by copyright and other intellectual property laws. You may not:\n\n'
                '• Copy, modify, or distribute the app\n'
                '• Use our trademarks without permission\n'
                '• Create derivative works based on the app',
                isMobile,
              ),
              
              _buildSection(
                '6. Disclaimer of Warranties',
                'Twin\'Am is provided "as is" without warranties of any kind. We do not guarantee that:\n\n'
                '• The app will be error-free or uninterrupted\n'
                '• Defects will be corrected\n'
                '• The app will meet your specific requirements\n\n'
                'You use the app at your own risk.',
                isMobile,
              ),
              
              _buildSection(
                '7. Limitation of Liability',
                'To the maximum extent permitted by law, we shall not be liable for any:\n\n'
                '• Indirect, incidental, or consequential damages\n'
                '• Loss of data or profits\n'
                '• Damages arising from your use of the app\n\n'
                'Our total liability shall not exceed the amount you paid for the app (if applicable).',
                isMobile,
              ),
              
              _buildSection(
                '8. Updates and Modifications',
                'We reserve the right to:\n\n'
                '• Modify or discontinue the app at any time\n'
                '• Update these Terms of Service\n'
                '• Add or remove features\n\n'
                'Continued use of the app after changes constitutes acceptance of the new terms.',
                isMobile,
              ),
              
              _buildSection(
                '9. Termination',
                'You may stop using the app at any time by uninstalling it from your device. We reserve the right to terminate or suspend access to the app for violations of these terms.',
                isMobile,
              ),
              
              _buildSection(
                '10. Governing Law',
                'These Terms of Service shall be governed by and construed in accordance with the laws of France, without regard to its conflict of law provisions.',
                isMobile,
              ),
              
              _buildSection(
                '11. Contact Information',
                'For questions about these Terms of Service, please contact us at:\n\n'
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
