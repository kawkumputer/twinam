import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/challenge_model.dart';
import '../../models/counter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/counter_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/twin_avatar_widget.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final auth = context.watch<AuthProvider>();
    final challenges = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translate('challenges'))),
        body: const Center(child: Text('Connecte-toi pour voir tes défis.')),
      );
    }

    final uid = SupabaseService.currentUser?.id;

    final invitations = challenges.pending
        .where((c) => c.participants.any(
            (p) => p.userId == uid && p.status == 'invited'))
        .toList();

    final outgoing = challenges.pending
        .where((c) => c.creatorId == uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('challenges')),
        actions: [
          if (invitations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Badge(
                label: Text('${invitations.length}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => challenges.load(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('invitations')),
            Tab(text: l10n.translate('active')),
            Tab(text: l10n.translate('finished')),
          ],
        ),
      ),
      body: challenges.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInvitationsTab(
                    invitations, outgoing, l10n, theme, challenges),
                _buildActiveTab(challenges.active, l10n, theme, challenges),
                _buildFinishedTab(challenges.completed, l10n, theme),
              ],
            ),
    );
  }

  Widget _buildInvitationsTab(
    List<Challenge> invitations,
    List<Challenge> outgoing,
    AppLocalizations l10n,
    ThemeData theme,
    ChallengeProvider challenges,
  ) {
    if (invitations.isEmpty && outgoing.isEmpty) {
      return _emptyState(Icons.inbox_outlined, l10n.translate('noInvitations'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Incoming invitations
        ...invitations.map((c) => _InvitationCard(
          challenge: c,
          onAccept: () async {
            await challenges.respond(c.id, true);
            if (!mounted) return;
            final counter = Counter(
              id: const Uuid().v4(),
              name: '⚡ ${c.title}',
              emoji: '⚡',
              goal: c.targetValue,
              challengeId: c.id,
              resetFrequency: c.challengeType == 'streak'
                  ? ResetFrequency.daily
                  : ResetFrequency.never,
            );
            context.read<CounterProvider>().addCounter(counter);
          },
          onReject: () => challenges.respond(c.id, false),
          l10n: l10n,
        )),
        // Outgoing (sent) pending challenges
        if (outgoing.isNotEmpty) ...
          [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.translate('sentRequests'),
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ...outgoing.map((c) => _OutgoingChallengeCard(
              challenge: c,
              onDelete: () => _confirmDelete(c, challenges, l10n),
              onEdit: () => _showEditDialog(c, challenges, l10n),
              l10n: l10n,
            )),
          ],
      ],
    );
  }

  void _confirmDelete(
      Challenge c, ChallengeProvider cp, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.translate('deleteChallenge')),
        content: Text(l10n.translate('deleteChallengeConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor),
            onPressed: () {
              Navigator.pop(context);
              cp.delete(c.id);
            },
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      Challenge c, ChallengeProvider cp, AppLocalizations l10n) {
    final titleCtrl = TextEditingController(text: c.title);
    final descCtrl = TextEditingController(text: c.description ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.translate('editChallenge')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration:
                  InputDecoration(labelText: l10n.translate('challengeTitle')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                  labelText: l10n.translate('challengeDescriptionOpt')),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cp.updateInfo(c.id, titleCtrl.text.trim(),
                  descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
            },
            child: Text(l10n.translate('save')),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(
    List<Challenge> active,
    AppLocalizations l10n,
    ThemeData theme,
    ChallengeProvider challenges,
  ) {
    if (active.isEmpty) {
      return _emptyState(
          Icons.emoji_events_outlined, l10n.translate('noActiveChallenges'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: active.length,
      itemBuilder: (_, i) => _ChallengeCard(
        challenge: active[i],
        l10n: l10n,
      ),
    );
  }

  Widget _buildFinishedTab(
    List<Challenge> finished,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (finished.isEmpty) {
      return _emptyState(
          Icons.history_rounded, l10n.translate('noFinishedChallenges'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: finished.length,
      itemBuilder: (_, i) => _ChallengeCard(
        challenge: finished[i],
        l10n: l10n,
      ),
    );
  }

  Widget _emptyState(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Invitation Card ────────────────────────────────────────────────────────

class _InvitationCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final AppLocalizations l10n;

  const _InvitationCard({
    required this.challenge,
    required this.onAccept,
    required this.onReject,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final challenger = challenge.participants
        .firstWhere((p) => p.userId == challenge.creatorId,
            orElse: () => challenge.participants.first);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  '@${challenger.username ?? '?'} ${l10n.translate('challengesYou')}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(challenge.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            if (challenge.description != null) ...[
              const SizedBox(height: 4),
              Text(challenge.description!,
                  style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 8),
            _ChipRow(challenge: challenge, l10n: l10n),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.close,
                      size: 16, color: AppTheme.dangerColor),
                  label: Text(l10n.translate('reject'),
                      style:
                          const TextStyle(color: AppTheme.dangerColor)),
                  onPressed: onReject,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l10n.translate('accept')),
                  onPressed: onAccept,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Outgoing Pending Challenge Card ────────────────────────────────────────

class _OutgoingChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final AppLocalizations l10n;

  const _OutgoingChallengeCard({
    required this.challenge,
    required this.onDelete,
    required this.onEdit,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final opponent = challenge.participants
        .firstWhere((p) => p.userId != challenge.creatorId,
            orElse: () => challenge.participants.first);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${l10n.translate('waitingFor')} @${opponent.username ?? '?'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      size: 18, color: AppTheme.primaryColor),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_rounded,
                      size: 18, color: AppTheme.dangerColor),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(challenge.title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            if (challenge.description != null) ...[
              const SizedBox(height: 3),
              Text(challenge.description!,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
            const SizedBox(height: 6),
            _ChipRow(challenge: challenge, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

// ─── Active / Finished Challenge Card ───────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final AppLocalizations l10n;

  const _ChallengeCard({
    required this.challenge,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final uid = SupabaseService.currentUser?.id;
    final me = challenge.participants
        .firstWhere((p) => p.userId == uid,
            orElse: () => challenge.participants.first);
    final opponent = challenge.participants
        .firstWhere((p) => p.userId != uid,
            orElse: () => challenge.participants.first);

    final duoVideo = challenge.isCompleted
        ? (me.currentValue >= challenge.targetValue
            ? TwinDuoWidget.videoCompleted
            : TwinDuoWidget.videoNeutral)
        : TwinDuoWidget.videoActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TwinDuoWidget(videoAsset: duoVideo, height: 120),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(challenge.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            if (challenge.description != null) ...[      
              const SizedBox(height: 4),
              Text(challenge.description!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 6),
            _ChipRow(challenge: challenge, l10n: l10n),
            const SizedBox(height: 12),
            // Progress comparison
            _ProgressRow(
              label: l10n.translate('you'),
              value: me.currentValue,
              target: challenge.targetValue,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 6),
            _ProgressRow(
              label: '@${opponent.username ?? '?'}',
              value: opponent.currentValue,
              target: challenge.targetValue,
              color: AppTheme.accentColor,
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            Text('$value / $target',
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  final Challenge challenge;
  final AppLocalizations l10n;

  const _ChipRow({required this.challenge, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final typeLabel = {
      'streak': l10n.translate('challengeTypeStreak'),
      'goal_count': l10n.translate('challengeTypeGoalCount'),
      'total_value': l10n.translate('challengeTypeTotalValue'),
    }[challenge.challengeType] ?? challenge.challengeType;

    return Wrap(
      spacing: 6,
      children: [
        Chip(
          label: Text(typeLabel),
          visualDensity: VisualDensity.compact,
          labelStyle: const TextStyle(fontSize: 11),
        ),
        Chip(
          label: Text('${challenge.targetValue} ${l10n.translate('target')}'),
          visualDensity: VisualDensity.compact,
          labelStyle: const TextStyle(fontSize: 11),
        ),
        Chip(
          label: Text('${challenge.durationDays}j'),
          visualDensity: VisualDensity.compact,
          labelStyle: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
