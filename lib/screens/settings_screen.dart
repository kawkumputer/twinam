import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User profile stats
          _buildProfileCard(context, l10n),
          const SizedBox(height: 20),

          // Name
          _buildSettingsTile(
            context,
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF66BB6A),
            title: l10n.translate('yourName'),
            subtitle: settings.userName.isNotEmpty ? settings.userName : null,
            trailing: IconButton(
              icon: Icon(
                Icons.edit_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              onPressed: () => _showEditNameDialog(context, settings, l10n),
            ),
          ),

          const SizedBox(height: 12),

          // Dark mode
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF2196F3),
            title: l10n.translate('darkMode'),
            trailing: Switch.adaptive(
              value: settings.isDarkMode,
              onChanged: (_) => settings.toggleDarkMode(),
              activeTrackColor: const Color(0xFF2196F3),
            ),
          ),

          const SizedBox(height: 12),

          // Language
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: l10n.translate('language'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: settings.locale,
                underline: const SizedBox(),
                isDense: true,
                borderRadius: BorderRadius.circular(14),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(l10n.translate('english')),
                  ),
                  DropdownMenuItem(
                    value: 'fr',
                    child: Text(l10n.translate('french')),
                  ),
                  DropdownMenuItem(
                    value: 'es',
                    child: Text(l10n.translate('spanish')),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: Text(l10n.translate('arabic')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) settings.setLocale(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sound effects
          _buildSettingsTile(
            context,
            icon: Icons.volume_up_rounded,
            iconColor: const Color(0xFFFF8A65),
            title: l10n.translate('soundEffects'),
            trailing: Switch.adaptive(
              value: context.watch<AchievementProvider>().soundEnabled,
              onChanged: (_) => context.read<AchievementProvider>().toggleSound(),
              activeTrackColor: const Color(0xFFFF8A65),
            ),
          ),

          const SizedBox(height: 12),

          // Widget Settings
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/widget-settings'),
            child: _buildSettingsTile(
              context,
              icon: Icons.widgets_rounded,
              iconColor: const Color(0xFF9C27B0),
              title: l10n.translate('widgetSettings'),
              subtitle: l10n.translate('widgetSettingsDesc'),
              trailing: const Icon(Icons.chevron_right_rounded, size: 24),
            ),
          ),

          const SizedBox(height: 32),

          // Support Us section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              l10n.translate('supportTwinAm'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Buy Me a Coffee
          GestureDetector(
            onTap: () => _launchUrl('https://buymeacoffee.com/hamathkane'),
            child: _buildSettingsTile(
              context,
              icon: Icons.coffee_rounded,
              iconColor: const Color(0xFFFFDD57),
              title: 'Buy Me a Coffee',
              subtitle: 'Support development ☕',
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            ),
          ),

          const SizedBox(height: 12),

          // PayPal
          GestureDetector(
            onTap: () => _launchUrl('https://paypal.me/HamathKane'),
            child: _buildSettingsTile(
              context,
              icon: Icons.payment_rounded,
              iconColor: const Color(0xFF0070BA),
              title: 'PayPal',
              subtitle: 'One-time donation 💙',
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
            ),
          ),

          const SizedBox(height: 32),

          // About
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: l10n.translate('about'),
            subtitle: '${l10n.translate('version')} 1.0.0',
          ),
          
          // Add bottom padding to ensure About button is fully visible
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.translate('yourName')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.translate('nameHint'),
            prefixIcon: const Icon(Icons.person_rounded),
          ),
          onSubmitted: (_) {
            settings.setUserName(controller.text);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.pop(ctx);
            },
            child: Text(l10n.translate('save')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppLocalizations l10n) {
    final ap = context.watch<AchievementProvider>();
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/achievements'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2196F3).withValues(alpha: 0.12),
              const Color(0xFFFFB74D).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            // Level badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ap.levelEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.translate('level')} ${ap.level} — ${ap.levelTitle}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ap.levelProgress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  '${ap.xp} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildProfileStat(context, '👆', '${ap.totalTaps}', l10n.translate('totalTaps'))),
                Expanded(child: _buildProfileStat(context, '📅', '${ap.daysActive}', l10n.translate('daysActiveLabel'))),
                Expanded(child: _buildProfileStat(context, '🎯', '${ap.goalsCompleted}', l10n.translate('goalsCompletedLabel'))),
                Expanded(child: _buildProfileStat(
                  context,
                  '🏆',
                  '${ap.unlockedAchievements.length}',
                  l10n.translate('achievements'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(BuildContext context, String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
