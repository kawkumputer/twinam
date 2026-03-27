import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/counter_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _welcomeChecked = false;

  String _getGreeting(AppLocalizations l10n, String userName) {
    final name = userName.isNotEmpty ? ', $userName' : '';
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '${l10n.translate('greetingMorning').replaceAll(' !', '').replaceAll('!', '')}$name!';
    if (hour >= 12 && hour < 18) return '${l10n.translate('greetingAfternoon').replaceAll(' !', '').replaceAll('!', '')}$name!';
    if (hour >= 18 && hour < 23) return '${l10n.translate('greetingEvening').replaceAll(' !', '').replaceAll('!', '')}$name!';
    return '${l10n.translate('greetingNight').replaceAll(' ?', '').replaceAll('?', '')}$name?';
  }

  String _getDailyMotivation(AppLocalizations l10n) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final index = (dayOfYear % 7) + 1;
    return l10n.translate('motivate$index');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final counterProvider = context.watch<CounterProvider>();
    final counters = counterProvider.counters;
    final achievementProvider = context.watch<AchievementProvider>();

    // Check for welcome dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_welcomeChecked) {
        _welcomeChecked = true;
        if (!settings.hasUserName && mounted) {
          _showWelcomeDialog(context, settings, l10n);
        }
      }
      if (achievementProvider.didLevelUp && mounted) {
        achievementProvider.clearLevelUp();
        _showLevelUpDialog(context, achievementProvider, l10n);
      }
      if (achievementProvider.milestone != null && mounted) {
        final m = achievementProvider.milestone!;
        achievementProvider.clearMilestone();
        _showMilestoneDialog(context, m, l10n);
      }
      final last = achievementProvider.lastUnlocked;
      if (last != null && mounted) {
        achievementProvider.clearLastUnlocked();
        _showAchievementUnlock(context, last, l10n);
      }
    });

    // Check counter-count and streak achievements
    achievementProvider.checkCounterCount(counters.length);
    achievementProvider.checkStreaks(counters);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(l10n, settings.userName),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${achievementProvider.levelEmoji} ${l10n.translate('level')} ${achievementProvider.level}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2196F3),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: achievementProvider.levelProgress,
                                    minHeight: 5,
                                    backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${achievementProvider.xp} XP',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/achievements');
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB74D).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text('🏆', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.settings_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Motivation banner
            if (counters.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getDailyMotivation(l10n),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (counters.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(context, l10n),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final counter = counters[index];
                      return CounterCard(
                        counter: counter,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/counter',
                            arguments: counter.id,
                          );
                        },
                        onQuickTap: () {
                          achievementProvider.recordTap();
                          if (achievementProvider.soundEnabled) {
                            SystemSound.play(SystemSoundType.click);
                          }
                          final wasGoalReached = counter.goalReached;
                          counterProvider.incrementCounter(counter.id);
                          achievementProvider.checkCounterMilestone(counter.value);
                          if (counter.goal != null && !wasGoalReached && counter.goalReached) {
                            achievementProvider.recordGoalCompleted();
                          }
                        },
                        onLongPress: () {
                          _showContextMenu(context, counter, counterProvider, l10n);
                        },
                      );
                    },
                    childCount: counters.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/create');
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.translate('newCounter')),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    dynamic counter,
    CounterProvider provider,
    AppLocalizations l10n,
  ) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '${counter.emoji} ${counter.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text(l10n.translate('editCounter')),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/edit', arguments: counter.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: Text(l10n.translate('stats')),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/stats', arguments: counter.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: Text(l10n.translate('reset')),
                onTap: () {
                  provider.resetCounter(counter.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red.shade400),
                title: Text(
                  l10n.translate('delete'),
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, counter, provider, l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    dynamic counter,
    CounterProvider provider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('deleteConfirm')),
        content: Text(l10n.translate('deleteConfirmMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              provider.deleteCounter(counter.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showWelcomeDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('👋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              l10n.translate('welcomeTitle'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('welcomeMessage'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: l10n.translate('welcomeHint'),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              onSubmitted: (_) {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  settings.setUserName(name);
                  Navigator.pop(ctx);
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    settings.setUserName(name);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(l10n.translate('welcomeButton')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelUpDialog(
    BuildContext context,
    AchievementProvider ap,
    AppLocalizations l10n,
  ) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(l10n.translate('levelUp'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3),
                  ),
            ),
            const SizedBox(height: 12),
            Text(ap.levelEmoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              '${l10n.translate('levelUpMessage')} ${ap.level}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              ap.levelTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('⚡'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMilestoneDialog(
    BuildContext context,
    int milestone,
    AppLocalizations l10n,
  ) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(l10n.translate('milestone'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFB74D),
                  ),
            ),
            const SizedBox(height: 12),
            const Text('🎊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              '${l10n.translate('milestoneMessage')} $milestone',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.translate('milestoneOnCounter'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '+${milestone ~/ 10} XP',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('🎉'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementUnlock(
    BuildContext context,
    dynamic achievement,
    AppLocalizations l10n,
  ) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.translate('newAchievement'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 16),
            Text(achievement.icon, style: const TextStyle(fontSize: 56)),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('🎉'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingIcon(color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              l10n.translate('noCounters'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.translate('noCountersMessage'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final Color color;
  const _PulsingIcon({required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _opacityAnimation.value),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_rounded,
              size: 56,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
