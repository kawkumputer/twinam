import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final ap = context.watch<AchievementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('myProgression')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LevelHeroCard(ap: ap, l10n: l10n),
            const SizedBox(height: 20),
            _XpStatsRow(ap: ap, l10n: l10n),
            const SizedBox(height: 28),
            _HowToEarnCard(l10n: l10n),
            const SizedBox(height: 28),
            Text(
              l10n.translate('levelRoadmap'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            _LevelRoadmap(ap: ap, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _LevelHeroCard extends StatelessWidget {
  final AchievementProvider ap;
  final AppLocalizations l10n;

  const _LevelHeroCard({required this.ap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final xpInLevel = ap.xp - ap.xpForCurrentLevel;
    final xpNeeded = ap.xpForNextLevel - ap.xpForCurrentLevel;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withValues(alpha: 0.15),
            const Color(0xFF9C27B0).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(ap.levelEmoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            '${l10n.translate('level')} ${ap.level}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2196F3),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            ap.levelTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ap.levelProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor:
                    const Color(0xFF2196F3).withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2196F3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xpInLevel / $xpNeeded XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${l10n.translate('nextLevel')}: ${_nextLevelTitle(ap)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nextLevelTitle(AchievementProvider ap) {
    final nextIdx = ap.level.clamp(0, AchievementProvider.levelTitles.length - 1);
    return AchievementProvider.levelTitles[nextIdx];
  }
}

class _XpStatsRow extends StatelessWidget {
  final AchievementProvider ap;
  final AppLocalizations l10n;

  const _XpStatsRow({required this.ap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '⚡',
            label: l10n.translate('totalXp'),
            value: '${ap.xp} XP',
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '🌅',
            label: l10n.translate('xpToday'),
            value: '+${ap.xpToday} XP',
            color: const Color(0xFFFFB74D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '🏁',
            label: l10n.translate('xpToNextLevel'),
            value: '${(ap.xpForNextLevel - ap.xp).clamp(0, 9999)} XP',
            color: const Color(0xFF66BB6A),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _HowToEarnCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _HowToEarnCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = [
      l10n.translate('xpGuideDaily'),
      l10n.translate('xpGuideTap'),
      l10n.translate('xpGuideGoal'),
      l10n.translate('xpGuideMilestone'),
      l10n.translate('xpGuideAchievement'),
      l10n.translate('xpGuideChallengeWon'),
      l10n.translate('xpGuideChallengeCompleted'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                l10n.translate('howToEarnXp'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRoadmap extends StatelessWidget {
  final AchievementProvider ap;
  final AppLocalizations l10n;

  const _LevelRoadmap({required this.ap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        AchievementProvider.levelTitles.length,
        (i) {
          final lvl = i + 1;
          final isUnlocked = ap.level > lvl;
          final isCurrent = ap.level == lvl;
          final xpRequired = AchievementProvider.xpForLevelPublic(lvl);
          final emoji = AchievementProvider.levelEmojis[i];
          final title = AchievementProvider.levelTitles[i];

          return _RoadmapItem(
            level: lvl,
            emoji: emoji,
            title: title,
            xpRequired: xpRequired,
            isUnlocked: isUnlocked,
            isCurrent: isCurrent,
            l10n: l10n,
          );
        },
      ),
    );
  }
}

class _RoadmapItem extends StatelessWidget {
  final int level;
  final String emoji;
  final String title;
  final int xpRequired;
  final bool isUnlocked;
  final bool isCurrent;
  final AppLocalizations l10n;

  const _RoadmapItem({
    required this.level,
    required this.emoji,
    required this.title,
    required this.xpRequired,
    required this.isUnlocked,
    required this.isCurrent,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isCurrent
        ? const Color(0xFF2196F3)
        : isUnlocked
            ? const Color(0xFF66BB6A)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFF2196F3).withValues(alpha: 0.1)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${l10n.translate('level')} $level',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$xpRequired XP ${l10n.translate('xpNeeded')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF66BB6A), size: 20)
          else if (isCurrent)
            const Icon(Icons.radio_button_checked_rounded,
                color: Color(0xFF2196F3), size: 20)
          else
            Icon(
              Icons.lock_rounded,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
        ],
      ),
    );
  }
}
