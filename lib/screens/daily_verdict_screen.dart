import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/twin_avatar_widget.dart';

class DailyVerdictScreen extends StatefulWidget {
  const DailyVerdictScreen({super.key});

  @override
  State<DailyVerdictScreen> createState() => _DailyVerdictScreenState();
}

class _DailyVerdictScreenState extends State<DailyVerdictScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _scoreController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counters = context.read<CounterProvider>().counters;
      final score = _computeScore(counters);
      _scoreAnim = Tween<double>(begin: 0, end: score).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
      );
      _entryController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scoreController.forward();
        HapticFeedback.mediumImpact();
      });
    });

    _scoreAnim = Tween<double>(begin: 0, end: 0).animate(_scoreController);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  double _computeScore(List<Counter> counters) {
    if (counters.isEmpty) return 0;
    final withGoal = counters.where((c) => c.goal != null).toList();
    if (withGoal.isEmpty) {
      final total = counters.fold<int>(0, (sum, c) => sum + c.value);
      return total > 0 ? 1.0 : 0.0;
    }
    final reached = withGoal.where((c) => c.goalReached).length;
    return reached / withGoal.length;
  }

  String _getAdvice(List<Counter> counters, double score, AppLocalizations l10n) {
    if (counters.isEmpty) return "Add your first habit and start your journey!";
    if (score >= 1.0) return l10n.translate('perfectDay');
    if (score >= 0.8) return l10n.translate('almostPerfect');
    if (score >= 0.6) return l10n.translate('goodProgress');
    if (score >= 0.4) return l10n.translate('halfwayThere');
    if (score >= 0.2) return l10n.translate('toughDay');
    return l10n.translate('twinNeedsYou');
  }

  List<_HabitRow> _getHabitRows(List<Counter> counters, AppLocalizations l10n) {
    return counters.map((c) {
      if (c.goal == null) {
        return _HabitRow(
          emoji: c.emoji,
          name: c.name,
          value: '${c.value} ${l10n.translate('actions')}',
          done: c.value > 0,
          progress: c.value > 0 ? 1.0 : 0.0,
        );
      }
      return _HabitRow(
        emoji: c.emoji,
        name: c.name,
        value: '${c.value} / ${c.goal}',
        done: c.goalReached,
        progress: c.progress,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final counters = context.watch<CounterProvider>().counters;
    final achievementProvider = context.watch<AchievementProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final score = _computeScore(counters);
    final twinState = TwinAvatarWidget.fromScore(score);
    final twinColor = TwinAvatarWidget.colorForState(twinState);
    final twinMessage = TwinAvatarWidget.messageForState(twinState, settings.locale);
    final advice = _getAdvice(counters, score, l10n);
    final habitRows = _getHabitRows(counters, l10n);
    final scorePercent = (score * 100).round();
    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday, l10n)}, ${now.day} ${_month(now.month, l10n)} ${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('dailyVerdict'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeIn.value,
            child: Transform.translate(
              offset: Offset(0, _slideUp.value),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 24),

              // Twin avatar + score ring
              _ScoreRing(
                score: score,
                scoreAnim: _scoreAnim,
                color: twinColor,
                child: TwinAvatarWidget(
                  state: twinState,
                  size: 80,
                  message: '',
                ),
              ),

              const SizedBox(height: 20),

              // Score number
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (context, _) {
                  final pct = (_scoreAnim.value * 100).round();
                  return Text(
                    '$pct%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: twinColor,
                          letterSpacing: -2,
                        ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // Twin message
              Text(
                twinMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: twinColor,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Advice card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: twinColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: twinColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        advice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.75),
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: '🔥',
                    label: l10n.translate('bestStreak'),
                    value: '${_bestStreak(counters)} ${l10n.translate('daysLowercase')}',
                    color: const Color(0xFFFF7043),
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: '⚡',
                    label: l10n.translate('xpToday'),
                    value: '+${achievementProvider.xp} XP',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: '✅',
                    label: l10n.translate('goalsDone'),
                    value:
                        '${habitRows.where((h) => h.done).length}/${habitRows.length}',
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tasks completed today
              if (taskProvider.completedTodayCount > 0) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.translate('tasksCompletedTodayTitle'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.task_alt_rounded,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${taskProvider.completedTodayCount} ${taskProvider.completedTodayCount > 1 ? l10n.translate('tasksCompletedToday') : l10n.translate('taskCompletedToday')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Habit breakdown
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.translate('habitBreakdown'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              if (habitRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No habits yet. Add your first one!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                )
              else
                ...habitRows.map((row) => _HabitBreakdownRow(row: row)),

              const SizedBox(height: 32),

              // CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Text(
                    scorePercent >= 80 ? '🚀' : '💪',
                    style: const TextStyle(fontSize: 18),
                  ),
                  label: Text(
                    scorePercent >= 80
                        ? l10n.translate('keepTheMomentum')
                        : l10n.translate('crushYourHabits'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: twinColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  int _bestStreak(List<Counter> counters) {
    if (counters.isEmpty) return 0;
    return counters.map((c) => c.currentStreak).fold(0, (a, b) => a > b ? a : b);
  }

  String _weekday(int w, AppLocalizations l10n) {
    final days = [
      l10n.translate('monday'),
      l10n.translate('tuesday'),
      l10n.translate('wednesday'),
      l10n.translate('thursday'),
      l10n.translate('friday'),
      l10n.translate('saturday'),
      l10n.translate('sunday'),
    ];
    return days[(w - 1).clamp(0, 6)];
  }

  String _month(int m, AppLocalizations l10n) {
    final months = [
      l10n.translate('januaryMonth'),
      l10n.translate('februaryMonth'),
      l10n.translate('marchMonth'),
      l10n.translate('aprilMonth'),
      l10n.translate('mayMonth'),
      l10n.translate('juneMonth'),
      l10n.translate('julyMonth'),
      l10n.translate('augustMonth'),
      l10n.translate('septemberMonth'),
      l10n.translate('octoberMonth'),
      l10n.translate('novemberMonth'),
      l10n.translate('decemberMonth'),
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}

// ── Score ring widget ───────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final double score;
  final Animation<double> scoreAnim;
  final Color color;
  final Widget child;

  const _ScoreRing({
    required this.score,
    required this.scoreAnim,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scoreAnim,
      builder: (context, _) {
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: scoreAnim.value,
                  strokeWidth: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

// ── Stat chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
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
                        .withValues(alpha: 0.4),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Habit row data ───────────────────────────────────────────────────────────

class _HabitRow {
  final String emoji;
  final String name;
  final String value;
  final bool done;
  final double progress;

  _HabitRow({
    required this.emoji,
    required this.name,
    required this.value,
    required this.done,
    required this.progress,
  });
}

// ── Habit breakdown row widget ───────────────────────────────────────────────

class _HabitBreakdownRow extends StatelessWidget {
  final _HabitRow row;

  const _HabitBreakdownRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final color = row.done
        ? const Color(0xFF4CAF50)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(row.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  row.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                row.value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
              const SizedBox(width: 10),
              Icon(
                row.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: row.done
                    ? const Color(0xFF4CAF50)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.25),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: row.progress,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                row.done
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
