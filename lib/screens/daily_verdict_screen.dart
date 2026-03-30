import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/achievement_provider.dart';
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

  String _getAdvice(List<Counter> counters, double score) {
    if (counters.isEmpty) return "Add your first habit and start your journey!";
    if (score >= 1.0) return "Perfect day! Every goal crushed. Keep this momentum tomorrow. 🚀";
    if (score >= 0.8) return "Almost perfect! One more push and you'll be unstoppable.";
    if (score >= 0.6) return "Good progress! Focus on your remaining habits this evening.";
    if (score >= 0.4) return "You're halfway there. Every action counts — start now!";
    if (score >= 0.2) return "Tough day? That's okay. One habit done is better than zero.";
    return "Your Twin needs you. Open the app and do just ONE habit right now.";
  }

  List<_HabitRow> _getHabitRows(List<Counter> counters) {
    return counters.map((c) {
      if (c.goal == null) {
        return _HabitRow(
          emoji: c.emoji,
          name: c.name,
          value: '${c.value} actions',
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
    final score = _computeScore(counters);
    final twinState = TwinAvatarWidget.fromScore(score);
    final twinColor = TwinAvatarWidget.colorForState(twinState);
    final twinMessage = TwinAvatarWidget.messageForState(twinState);
    final advice = _getAdvice(counters, score);
    final habitRows = _getHabitRows(counters);
    final scorePercent = (score * 100).round();
    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daily Verdict",
          style: TextStyle(fontWeight: FontWeight.w800),
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
                    label: 'Best streak',
                    value: '${_bestStreak(counters)} days',
                    color: const Color(0xFFFF7043),
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: '⚡',
                    label: 'XP today',
                    value: '+${achievementProvider.xp} XP',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: '✅',
                    label: 'Goals done',
                    value:
                        '${habitRows.where((h) => h.done).length}/${habitRows.length}',
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Habit breakdown
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Habit Breakdown',
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
                        ? "Keep the momentum!"
                        : "Go crush your habits!",
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

  String _weekday(int w) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(w - 1).clamp(0, 6)];
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
