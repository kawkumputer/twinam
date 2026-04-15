import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/achievement_provider.dart';
import '../widgets/twin_avatar_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0=welcome, 1=meet twin, 2=choose habit, 3=tap, 4=celebrate
  final _nameController = TextEditingController();
  String? _selectedHabitKey;
  String? _selectedEmoji;
  bool _tapped = false;
  late ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _presets = [
    {'key': 'onboardingHabitWater', 'emoji': '💧', 'goal': 8},
    {'key': 'onboardingHabitWalk', 'emoji': '🚶', 'goal': 1},
    {'key': 'onboardingHabitRead', 'emoji': '📖', 'goal': 1},
    {'key': 'onboardingHabitMeditate', 'emoji': '🧘', 'goal': 1},
    {'key': 'onboardingHabitSleep', 'emoji': '😴', 'goal': 1},
    {'key': 'onboardingHabitStretch', 'emoji': '🤸', 'goal': 1},
  ];

  final _languages = [
    {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
    {'code': 'es', 'label': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'label': 'Deutsch', 'flag': '🇩🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _fadeController.reset();
    setState(() => _step = step);
    _fadeController.forward();
  }

  void _onHabitSelected(String key, String emoji) {
    setState(() {
      _selectedHabitKey = key;
      _selectedEmoji = emoji;
    });
  }

  Future<void> _onTap() async {
    if (_tapped) return;
    setState(() => _tapped = true);
    HapticFeedback.heavyImpact();

    final settings = context.read<SettingsProvider>();
    final counterProvider = context.read<CounterProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    final l10n = AppLocalizations.of(settings.locale);

    // Create the counter
    final preset = _presets.firstWhere((p) => p['key'] == _selectedHabitKey);
    final counter = Counter(
      id: const Uuid().v4(),
      name: l10n.translate(_selectedHabitKey!),
      emoji: _selectedEmoji ?? '🔢',
      goal: preset['goal'] as int,
      resetFrequency: ResetFrequency.daily,
      step: 1,
    );
    await counterProvider.addCounter(counter);

    // Increment once
    await counterProvider.incrementCounter(counter.id);

    // Award XP via recordTap
    achievementProvider.recordTap();

    // Short delay then celebrate
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _goToStep(4);
      _confettiController.play();
    }
  }

  void _finish() {
    final settings = context.read<SettingsProvider>();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      settings.setUserName(name);
    }
    settings.completeOnboarding();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildStep(l10n, settings),
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.06,
              gravity: 0.2,
              colors: const [
                Color(0xFF2196F3),
                Color(0xFF4CAF50),
                Color(0xFFFF9800),
                Color(0xFFFF6D00),
                Color(0xFFE040FB),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n, SettingsProvider settings) {
    switch (_step) {
      case 0:
        return _buildWelcomeStep(l10n, settings);
      case 1:
        return _buildMeetTwinStep(l10n);
      case 2:
        return _buildChooseHabitStep(l10n);
      case 3:
        return _buildTapStep(l10n);
      case 4:
        return _buildCelebrateStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Welcome ───────────────────────────────────────────────────────

  Widget _buildWelcomeStep(AppLocalizations l10n, SettingsProvider settings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('welcomeTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('welcomeSubtitle'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2196F3),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Language selector
        Text(
          l10n.translate('chooseLanguage'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _languages.map((lang) {
            final isSelected = settings.locale == lang['code'];
            return GestureDetector(
              onTap: () => settings.setLocale(lang['code']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: const Color(0xFF2196F3), width: 2) : null,
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
        const SizedBox(height: 28),
        // Name input
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.translate('welcomeHint'),
            prefixIcon: const Icon(Icons.person_rounded),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _goToStep(1),
            child: Text(
              l10n.translate('onboardingNext'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Meet your Twin ────────────────────────────────────────────────

  Widget _buildMeetTwinStep(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('onboardingMeetTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        TwinAvatarWidget(
          state: TwinState.neutral,
          size: 150,
          message: '',
          enableMicroBehaviors: true,
        ),
        if (name.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2196F3),
                ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          l10n.translate('onboardingMeetDesc'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _goToStep(2),
            child: Text(
              l10n.translate('onboardingNext'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Choose Habit ──────────────────────────────────────────────────

  Widget _buildChooseHabitStep(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('onboardingHabitTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('onboardingHabitDesc'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _presets.map((preset) {
            final key = preset['key'] as String;
            final emoji = preset['emoji'] as String;
            final isSelected = _selectedHabitKey == key;
            return GestureDetector(
              onTap: () => _onHabitSelected(key, emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF2196F3), width: 2)
                      : Border.all(color: Colors.transparent),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate(key),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedHabitKey != null ? () => _goToStep(3) : null,
            child: Text(
              l10n.translate('onboardingNext'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Tap +1 ───────────────────────────────────────────────────────

  Widget _buildTapStep(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('onboardingTapTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.translate('onboardingTapDesc'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TwinAvatarWidget(
          state: TwinState.neutral,
          size: 120,
          message: '',
          enableMicroBehaviors: true,
        ),
        const SizedBox(height: 32),
        // Big +1 button
        GestureDetector(
          onTap: _tapped ? null : _onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _tapped
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF2196F3),
              boxShadow: [
                BoxShadow(
                  color: (_tapped ? const Color(0xFF4CAF50) : const Color(0xFF2196F3))
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _tapped ? '✓' : '+1',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (_tapped) ...[
          const SizedBox(height: 16),
          Text(
            '+10 XP 🎉',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF9800),
                ),
          ),
        ],
      ],
    );
  }

  // ─── Step 4: Celebrate ─────────────────────────────────────────────────────

  Widget _buildCelebrateStep(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('onboardingCelebrateTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4CAF50),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        TwinAvatarWidget(
          state: TwinState.excited,
          size: 160,
          message: '',
          enableMicroBehaviors: true,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.translate('onboardingCelebrateDesc'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _finish,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              l10n.translate('onboardingStart'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
