import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../providers/settings_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final achievementProvider = context.watch<AchievementProvider>();
    final achievements = achievementProvider.achievements;
    final unlocked = achievementProvider.unlockedAchievements.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('achievements')),
      ),
      body: Column(
        children: [
          // Header stats
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3).withValues(alpha: 0.15),
                  const Color(0xFFFFB74D).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  '🏆',
                  '$unlocked/${achievements.length}',
                  l10n.translate('achievementsUnlocked'),
                ),
                _buildStatColumn(
                  context,
                  '👆',
                  '${achievementProvider.totalTaps}',
                  l10n.translate('totalTaps'),
                ),
                _buildStatColumn(
                  context,
                  '📅',
                  '${achievementProvider.daysActive}',
                  l10n.translate('daysActiveLabel'),
                ),
              ],
            ),
          ),

          // Achievement grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementCard(context, achievement, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
    AppLocalizations l10n,
  ) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetail(context, achievement, l10n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked
              ? Theme.of(context).cardTheme.color
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: isUnlocked
              ? Border.all(
                  color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? achievement.icon : '🔒',
              style: TextStyle(
                fontSize: isUnlocked ? 32 : 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate(achievement.titleKey),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? null
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    Achievement achievement,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                achievement.isUnlocked ? achievement.icon : '🔒',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate(achievement.titleKey),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate(achievement.descriptionKey),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
              if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  '✅ ${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
