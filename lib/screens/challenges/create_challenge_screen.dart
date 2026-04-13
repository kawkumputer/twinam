import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/counter.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/counter_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class CreateChallengeScreen extends StatefulWidget {
  final String opponentId;
  final String opponentUsername;

  const CreateChallengeScreen({
    super.key,
    required this.opponentId,
    required this.opponentUsername,
  });

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _challengeType = 'streak';
  int _targetValue = 7;
  int _durationDays = 7;

  final _types = ['streak', 'goal_count', 'total_value'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cp = context.read<ChallengeProvider>();
    final success = await cp.createChallenge(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      challengeType: _challengeType,
      targetValue: _targetValue,
      durationDays: _durationDays,
      opponentId: widget.opponentId,
    );
    if (!mounted) return;
    if (success) {
      // Auto-create a linked counter for the challenge creator
      final challenge = cp.challenges
          .where((c) => c.title == _titleCtrl.text.trim() && c.isPending)
          .lastOrNull;
      if (challenge != null) {
        final counter = Counter(
          id: const Uuid().v4(),
          name: '⚡ ${challenge.title}',
          emoji: '⚡',
          goal: challenge.targetValue,
          challengeId: challenge.id,
          resetFrequency: challenge.challengeType == 'streak'
              ? ResetFrequency.daily
              : ResetFrequency.never,
        );
        if (mounted) context.read<CounterProvider>().addCounter(counter);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Défi envoyé ! 🔥'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else if (cp.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cp.error!),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
      cp.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final cp = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);

    final typeLabels = {
      'streak': l10n.translate('challengeTypeStreak'),
      'goal_count': l10n.translate('challengeTypeGoalCount'),
      'total_value': l10n.translate('challengeTypeTotalValue'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('newChallenge')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opponent banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        widget.opponentUsername[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.translate('challengeOpponent'),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey)),
                        Text('@${widget.opponentUsername}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.translate('challengeTitle'),
                  hintText: l10n.translate('challengeTitleHint'),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.translate('required') : null,
              ),
              const SizedBox(height: 16),

              // Description (optional)
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.translate('challengeDescriptionOpt'),
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Challenge type
              Text(l10n.translate('challengeType'),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types.map((t) => ChoiceChip(
                  label: Text(typeLabels[t] ?? t),
                  selected: _challengeType == t,
                  onSelected: (_) => setState(() => _challengeType = t),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Target value slider
              Text(
                '${l10n.translate('target')}: $_targetValue',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _targetValue.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$_targetValue',
                onChanged: (v) => setState(() => _targetValue = v.round()),
              ),
              const SizedBox(height: 8),

              // Duration slider
              Text(
                '${l10n.translate('duration')}: $_durationDays ${l10n.translate('days')}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: _durationDays.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '$_durationDays',
                onChanged: (v) => setState(() => _durationDays = v.round()),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: cp.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.bolt_rounded),
                  label: Text(l10n.translate('sendChallenge')),
                  onPressed: cp.loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
