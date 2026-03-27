import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/achievement_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../models/counter.dart';
import '../widgets/animated_counter.dart';
import 'package:share_plus/share_plus.dart';

class CounterScreen extends StatefulWidget {
  final String counterId;
  const CounterScreen({super.key, required this.counterId});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late Animation<double> _pulseAnimation;
  bool _showConfetti = false;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _showConfetti = false);
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onTap(CounterProvider provider, Counter counter) {
    HapticFeedback.mediumImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());

    // Track achievement + XP
    final achievementProvider = context.read<AchievementProvider>();
    achievementProvider.recordTap();

    // Play tap sound
    if (achievementProvider.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    final wasGoalReached = counter.goalReached;
    provider.incrementCounter(widget.counterId);

    // Check milestone (50, 100, 500, 1000, 5000, 10000)
    achievementProvider.checkCounterMilestone(counter.value);

    if (counter.goal != null &&
        counter.value >= counter.goal! &&
        !wasGoalReached &&
        counter.goalDirection == GoalDirection.reach) {
      _triggerConfetti();
      achievementProvider.recordGoalCompleted();
    }
  }

  void _triggerConfetti() {
    final random = Random();
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5,
        color: Color.fromARGB(
          255,
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        ),
        size: random.nextDouble() * 8 + 4,
        velocity: random.nextDouble() * 2 + 1,
        angle: random.nextDouble() * pi * 2,
      ));
    }
    setState(() => _showConfetti = true);
    _confettiController.reset();
    _confettiController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final provider = context.watch<CounterProvider>();
    final counter = provider.getCounter(widget.counterId);

    if (counter == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final counterColor = Color(counter.colorValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  counterColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/stats',
                                arguments: widget.counterId,
                              );
                            },
                            icon: const Icon(Icons.bar_chart_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/edit',
                                arguments: widget.counterId,
                              );
                            },
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'share') {
                                _shareCounter(counter, l10n);
                              } else if (value == 'reset') {
                                _showResetDialog(context, provider, l10n);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, provider, l10n);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    const Icon(Icons.share_rounded, size: 20),
                                    const SizedBox(width: 12),
                                    Text(l10n.translate('share')),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'reset',
                                child: Row(
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 20),
                                    const SizedBox(width: 12),
                                    Text(l10n.translate('reset')),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_rounded, size: 20, color: Colors.red.shade400),
                                    const SizedBox(width: 12),
                                    Text(l10n.translate('delete'), style: TextStyle(color: Colors.red.shade400)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Emoji & name
                Text(counter.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  counter.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),

                const SizedBox(height: 32),

                // Counter value (animated)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: AnimatedCounter(
                    value: counter.value,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 96,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: counterColor,
                        ),
                  ),
                ),

                // Goal progress
                if (counter.goal != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: counter.progress,
                            minHeight: 8,
                            backgroundColor: counterColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              counter.goalReached ? const Color(0xFF66BB6A) : counterColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          counter.goalReached
                              ? l10n.translate('goalReached')
                              : '${counter.value} / ${counter.goal}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: counter.goalReached
                                    ? const Color(0xFF66BB6A)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: counter.goalReached ? FontWeight.w700 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Streak display
                if (counter.goal != null && counter.currentStreak > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          '${counter.currentStreak} ${l10n.translate('days')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFB74D),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // Tap button
                GestureDetector(
                  onTap: () => _onTap(provider, counter),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            counterColor,
                            counterColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: counterColor.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 48),
                          Text(
                            '+${counter.step}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Minus button
                TextButton.icon(
                  onPressed: counter.value > 0
                      ? () {
                          HapticFeedback.lightImpact();
                          provider.decrementCounter(widget.counterId);
                        }
                      : null,
                  icon: const Icon(Icons.remove_rounded, size: 20),
                  label: Text('-${counter.step}'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),

          // Confetti overlay
          if (_showConfetti)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _shareCounter(Counter counter, AppLocalizations l10n) {
    final goalText = counter.goal != null
        ? '\n${l10n.translate('goal')}: ${counter.value}/${counter.goal}'
        : '';
    final streakText = counter.currentStreak > 0
        ? '\n🔥 ${l10n.translate('streak')}: ${counter.currentStreak} ${l10n.translate('days')}'
        : '';
    final text =
        '${counter.emoji} ${counter.name}\n'
        '${l10n.translate('today')}: ${counter.value}'
        '$goalText'
        '$streakText'
        "\n\n— Twin'Am";
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _showResetDialog(BuildContext context, CounterProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('resetConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetCounter(widget.counterId);
              Navigator.pop(ctx);
            },
            child: Text(l10n.translate('reset')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CounterProvider provider, AppLocalizations l10n) {
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
              provider.deleteCounter(widget.counterId);
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x, y, size, velocity, angle;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.angle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
      final dx = p.x * size.width + cos(p.angle) * p.velocity * progress * 200;
      final dy = p.y * size.height + progress * p.velocity * 400;
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
