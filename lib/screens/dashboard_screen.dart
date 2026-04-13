import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/counter_card.dart';
import '../widgets/twin_avatar_widget.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/notification_service.dart';
import '../services/twin_notification_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _welcomeChecked = false;
  bool _notificationPermissionChecked = false;
  bool _postFrameScheduled = false;

  double _getDailyScore(List counters) {
    if (counters.isEmpty) return 0;
    final withGoal = counters.where((c) => c.goal != null).toList();
    if (withGoal.isEmpty) {
      final total = counters.fold<int>(0, (sum, c) => sum + (c.value as int));
      return total > 0 ? 1.0 : 0.0;
    }
    final reached = withGoal.where((c) => c.goalReached).length;
    return reached / withGoal.length;
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

    // Register at most one post-frame callback per frame to prevent accumulation
    if (!_postFrameScheduled) {
      _postFrameScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _postFrameScheduled = false;
      if (!_welcomeChecked) {
        _welcomeChecked = true;
        if (!settings.hasUserName && mounted) {
          _showWelcomeDialog(context, settings, l10n);
        }
        // Request notification permission after welcome
        if (!_notificationPermissionChecked && mounted) {
          _notificationPermissionChecked = true;
          _requestNotificationPermission();
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
      // Check achievements
      if (mounted) {
        achievementProvider.checkCounterCount(counters.length);
        achievementProvider.checkStreaks(counters);
      }
      // Schedule Twin notifications (guarded internally by date)
      if (mounted) {
        final bestStreak = counters.map((c) => c.currentStreak).fold(0, (a, b) => a > b ? a : b);
        TwinNotificationService().scheduleNotificationsIfNeeded(
          counters: counters,
          bestStreak: bestStreak,
          translate: l10n.translate,
        );
      }
      // Handle deep-link from cold-start notification tap
      NotificationService().handlePendingPayload();
    });
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name with Twin reference
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                              children: [
                                if (settings.userName.isNotEmpty) ...[
                                  TextSpan(
                                    text: l10n.translate('myTwin'),
                                    style: const TextStyle(
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${settings.userName}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 🤝',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ] else ...[
                                  TextSpan(
                                    text: l10n.translate('twinAndYou'),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 🤝',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Level and XP bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
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
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/tasks');
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.task_alt_rounded,
                                  color: Color(0xFFFF9800),
                                  size: 20,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/friends');
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.people_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/challenges');
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: AppTheme.warningColor,
                                  size: 20,
                                ),
                              ),
                            ),
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
                  ],
                ),
              ),
            ),
            // Twin Avatar card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _TwinCard(
                  score: _getDailyScore(counters),
                  counters: counters,
                  locale: settings.locale,
                  onTap: () => Navigator.of(context).pushNamed('/verdict'),
                ),
              ),
            ),

            // Tasks section - always visible
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  return SliverToBoxAdapter(
                    child: _TasksSummaryCard(taskProvider: taskProvider),
                  );
                },
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
      bottomNavigationBar: const BannerAdWidget(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab_task',
            onPressed: () => Navigator.of(context).pushNamed('/create-task'),
            backgroundColor: const Color(0xFFFF9800),
            mini: true,
            tooltip: l10n.translate('newTask'),
            child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_counter',
            onPressed: () => Navigator.of(context).pushNamed('/create'),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.translate('newCounter')),
          ),
        ],
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
    final languages = [
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
      {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
      {'code': 'de', 'label': 'Deutsch', 'flag': '🇩🇪'},
    ];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final currentL10n = AppLocalizations.of(settings.locale);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  ClipOval(
                    child: Image.asset(
                      'assets/happy-avatar.jpeg',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentL10n.translate('welcomeTitle'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentL10n.translate('welcomeSubtitle'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2196F3),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Language selector
                  Text(
                    currentL10n.translate('chooseLanguage'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: languages.map((lang) {
                      final isSelected = settings.locale == lang['code'];
                      return GestureDetector(
                        onTap: () {
                          settings.setLocale(lang['code']!);
                          setDialogState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2196F3).withValues(alpha: 0.15)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: const Color(0xFF2196F3), width: 2)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                lang['label']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF2196F3)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: currentL10n.translate('welcomeHint'),
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
                      child: Text(currentL10n.translate('welcomeButton')),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Future<void> _requestNotificationPermission() async {
    try {
      final granted = await NotificationService().requestPermission();
      if (!granted) {
        // Could show a dialog explaining why notifications are useful
        debugPrint('[Twin] Notification permission denied');
      } else {
        debugPrint('[Twin] Notification permission granted');
      }
    } catch (e) {
      debugPrint('[Twin] Error requesting notification permission: $e');
    }
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
      child: SingleChildScrollView(
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
      ),
    );
  }
}

class _TwinCard extends StatelessWidget {
  final double score;
  final List counters;
  final String locale;
  final VoidCallback? onTap;

  const _TwinCard({required this.score, required this.counters, required this.locale, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(locale);
    final state = TwinAvatarWidget.fromScore(score);
    final color = TwinAvatarWidget.colorForState(state);
    final message = TwinAvatarWidget.messageForState(state, locale);
    final total = counters.length;
    final withGoal = counters.where((c) => c.goal != null).toList();
    final reached = withGoal.where((c) => c.goalReached).length;
    final scorePercent = (score * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              TwinAvatarWidget(
                state: state,
                size: 72,
                message: '',
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 6),
                    if (withGoal.isNotEmpty) ...[
                      Text(
                        '$reached / ${withGoal.length} ${l10n.translate('goalsReachedPlural')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: score,
                          minHeight: 7,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$scorePercent% ${l10n.translate('today')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                      ),
                    ] else ...[
                      Text(
                        total > 0 ? l10n.translate('keepTrackingHabits') : l10n.translate('addFirstHabit'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TasksSummaryCard extends StatelessWidget {
  final TaskProvider taskProvider;

  const _TasksSummaryCard({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(settings.locale);

    final todoCount = taskProvider.todoTasks.length;
    final todayCount = taskProvider.todayTasks.length;
    final overdueCount = taskProvider.overdueCount;
    final inProgressCount = taskProvider.inProgressTasks.length;

    final allUrgent = <dynamic>{
      ...taskProvider.overdueTasks,
      ...taskProvider.todayTasks,
    }.take(2).toList();

    final hasUrgent = allUrgent.isNotEmpty;
    final allClear = todoCount == 0 && inProgressCount == 0 && overdueCount == 0;

    final borderColor = overdueCount > 0
        ? const Color(0xFFFF7043).withValues(alpha: 0.35)
        : const Color(0xFFFF9800).withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.translate('tasks'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF9800),
                      ),
                ),
              ),
              // Quick add task button
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/create-task'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: Color(0xFFFF9800)),
                      const SizedBox(width: 4),
                      Text(
                        l10n.translate('newTask'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/tasks'),
                child: Text(
                  l10n.translate('viewAll'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats chips row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (overdueCount > 0)
                _StatChip(
                  count: overdueCount,
                  label: l10n.translate('overdue'),
                  color: const Color(0xFFFF7043),
                  icon: Icons.warning_rounded,
                ),
              if (todayCount > 0)
                _StatChip(
                  count: todayCount,
                  label: l10n.translate('today'),
                  color: const Color(0xFF2196F3),
                  icon: Icons.today_rounded,
                ),
              if (inProgressCount > 0)
                _StatChip(
                  count: inProgressCount,
                  label: l10n.translate('inProgress'),
                  color: const Color(0xFF9C27B0),
                  icon: Icons.timelapse_rounded,
                ),
              _StatChip(
                count: todoCount,
                label: l10n.translate('todo'),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                icon: Icons.radio_button_unchecked_rounded,
              ),
            ],
          ),

          // Urgent tasks list or empty message
          if (hasUrgent) ...[
            const SizedBox(height: 12),
            ...allUrgent.map((task) => _TaskQuickItem(task: task, taskProvider: taskProvider)),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              allClear
                  ? l10n.translate('noUrgentTasks')
                  : l10n.translate('noUrgentTasks'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskQuickItem extends StatefulWidget {
  final dynamic task;
  final TaskProvider taskProvider;

  const _TaskQuickItem({required this.task, required this.taskProvider});

  @override
  State<_TaskQuickItem> createState() => _TaskQuickItemState();
}

class _TaskQuickItemState extends State<_TaskQuickItem> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Start shake animation if task is overdue
    if (widget.task.isOverdue) {
      _shakeController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(settings.locale);
    final isOverdue = widget.task.isOverdue;
    
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: isOverdue 
            ? Offset(_shakeAnimation.value * (widget.task.hashCode % 2 == 0 ? 1 : -1), 0) 
            : Offset.zero,
          child: child,
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFFF7043).withValues(alpha: 0.08)
            : const Color(0xFF2196F3).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
            size: 16,
            color: isOverdue ? const Color(0xFFFF7043) : const Color(0xFF2196F3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.task.description.isNotEmpty)
                  Text(
                    widget.task.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            color: const Color(0xFF4CAF50),
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.taskProvider.markTaskAsDone(widget.task.id);
            },
            tooltip: l10n.translate('markAsDone'),
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
