import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/challenge_model.dart';
import '../../models/counter.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/counter_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/twin_avatar_widget.dart';
import 'create_challenge_screen.dart';

class ChallengeTabBody extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final VoidCallback? onRefresh;

  const ChallengeTabBody({
    super.key,
    required this.friends,
    this.onRefresh,
  });

  @override
  State<ChallengeTabBody> createState() => _ChallengeTabBodyState();
}

class _ChallengeTabBodyState extends State<ChallengeTabBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndCleanup());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAndCleanup() async {
    if (!mounted) return;
    await context.read<ChallengeProvider>().load();
    if (!mounted) return;
    final ids = context.read<ChallengeProvider>().challengeIds;
    await context.read<CounterProvider>().cleanupOrphanedChallengeCounters(ids);
  }

  Future<void> _refresh() => _loadAndCleanup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final challenges = context.watch<ChallengeProvider>();
    final theme = Theme.of(context);
    final uid = SupabaseService.currentUser?.id;

    if (challenges.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final invitations = challenges.pending
        .where((c) =>
            c.participants.any((p) => p.userId == uid && p.status == 'invited'))
        .toList();
    final outgoing =
        challenges.pending.where((c) => c.creatorId == uid).toList();

    return Column(
      children: [
        Material(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.translate('invitations')),
              Tab(text: l10n.translate('active')),
              Tab(text: l10n.translate('finished')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInvitationsTab(
                  invitations, outgoing, l10n, theme, challenges),
              _buildActiveTab(challenges.active, l10n, theme),
              _buildFinishedTab(challenges.completed, l10n, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationsTab(
    List<Challenge> invitations,
    List<Challenge> outgoing,
    AppLocalizations l10n,
    ThemeData theme,
    ChallengeProvider challenges,
  ) {
    if (invitations.isEmpty && outgoing.isEmpty && widget.friends.isEmpty) {
      return _emptyScrollable(Icons.inbox_outlined, l10n.translate('noInvitations'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
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
        if (outgoing.isNotEmpty) ...[
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
        if (widget.friends.isNotEmpty) ...[
          if (invitations.isNotEmpty || outgoing.isNotEmpty)
            const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    size: 15, color: AppTheme.warningColor),
                const SizedBox(width: 6),
                Text(
                  l10n.translate('friends'),
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          ...widget.friends.map((f) {
            final uname = f['username'] as String? ?? '?';
            final dname = f['display_name'] as String?;
            final ci = uname.codeUnitAt(0) % AppTheme.counterColors.length;
            final col = AppTheme.counterColors[ci];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: col.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                      color: col.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [col, col.withValues(alpha: 0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(uname[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('@$uname',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        if (dname != null && dname.isNotEmpty)
                          Text(dname,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) => CreateChallengeScreen(
                            opponentId: f['id'] as String,
                            opponentUsername: uname,
                          ),
                        ))
                        .then((_) => challenges.load()),
                    icon: const Icon(Icons.bolt_rounded, size: 14),
                    label: Text(l10n.translate('launchChallenge'),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    ),
    );
  }

  Widget _buildActiveTab(
    List<Challenge> active,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (active.isEmpty) {
      return _emptyScrollable(
          Icons.emoji_events_outlined, l10n.translate('noActiveChallenges'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: active.length,
        itemBuilder: (_, i) => _ChallengeCard(challenge: active[i], l10n: l10n),
      ),
    );
  }

  Widget _buildFinishedTab(
    List<Challenge> finished,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (finished.isEmpty) {
      return _emptyScrollable(
          Icons.history_rounded, l10n.translate('noFinishedChallenges'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: finished.length,
        itemBuilder: (_, i) => _ChallengeCard(challenge: finished[i], l10n: l10n),
      ),
    );
  }

  Widget _emptyScrollable(IconData icon, String text) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
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
}

// ─── Invitation Card ─────────────────────────────────────────────────────────

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
    final challenger = challenge.participants.firstWhere(
        (p) => p.userId == challenge.creatorId,
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
                      style: const TextStyle(color: AppTheme.dangerColor)),
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

// ─── Outgoing Pending Challenge Card ─────────────────────────────────────────

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
    final opponent = challenge.participants.firstWhere(
        (p) => p.userId != challenge.creatorId,
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

// ─── Active / Finished Challenge Card ────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final AppLocalizations l10n;

  const _ChallengeCard({required this.challenge, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final uid = SupabaseService.currentUser?.id;
    final me = challenge.participants.firstWhere((p) => p.userId == uid,
        orElse: () => challenge.participants.first);
    final opponentList =
        challenge.participants.where((p) => p.userId != uid).toList();
    final opponentLeft = opponentList.isEmpty;
    final opponent = opponentLeft ? null : opponentList.first;

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
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
                const SizedBox(height: 6),
                _ChipRow(challenge: challenge, l10n: l10n),
                const SizedBox(height: 12),
                _ProgressRow(
                  label: l10n.translate('you'),
                  value: me.currentValue,
                  target: challenge.targetValue,
                  twinState: TwinAvatarWidget.fromScore(
                      challenge.targetValue > 0
                          ? (me.currentValue / challenge.targetValue)
                              .clamp(0.0, 1.0)
                          : 0.0),
                ),
                const SizedBox(height: 8),
                if (opponentLeft)
                  _OpponentLeftRow(l10n: l10n)
                else
                  _ProgressRow(
                    label: '@${opponent!.username ?? '?'}',
                    value: opponent.currentValue,
                    target: challenge.targetValue,
                    twinState: TwinAvatarWidget.fromScore(
                        challenge.targetValue > 0
                            ? (opponent.currentValue / challenge.targetValue)
                                .clamp(0.0, 1.0)
                            : 0.0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Row ─────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final TwinState twinState;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.target,
    required this.twinState,
  });

  static String _emojiForState(TwinState s) {
    switch (s) {
      case TwinState.excited: return '🔥';
      case TwinState.happy:   return '😊';
      case TwinState.neutral: return '😐';
      case TwinState.sad:     return '😢';
      case TwinState.cry:     return '😭';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final stateColor = TwinAvatarWidget.colorForState(twinState);
    final emoji = _emojiForState(twinState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                TwinAvatarWidget.assetForState(twinState),
                width: 30, height: 30, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: stateColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text('$value / $target',
                          style: TextStyle(
                              color: stateColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: stateColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(stateColor),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Opponent Left Row ────────────────────────────────────────────────────────

class _OpponentLeftRow extends StatelessWidget {
  final AppLocalizations l10n;
  const _OpponentLeftRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            l10n.translate('opponentLeft'),
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip Row ─────────────────────────────────────────────────────────────────

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
    }[challenge.challengeType] ??
        challenge.challengeType;

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
