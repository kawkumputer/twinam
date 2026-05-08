import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../challenges/challenge_tab_body.dart';
import '../challenges/create_challenge_screen.dart';

class FriendsScreen extends StatefulWidget {
  final int initialTab;
  const FriendsScreen({super.key, this.initialTab = 0});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingReceived = [];
  List<Map<String, dynamic>> _pendingSent = [];
  bool _loadingFriends = true;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingLeaderboard = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadFriends();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    if (SupabaseService.currentUser == null) return;
    setState(() => _loadingLeaderboard = true);
    try {
      final data = await _authService.fetchLeaderboard();
      setState(() {
        _leaderboard = data;
        _loadingLeaderboard = false;
      });
    } catch (_) {
      setState(() => _loadingLeaderboard = false);
    }
  }

  Future<void> _loadFriends() async {
    setState(() => _loadingFriends = true);
    final uid = SupabaseService.currentUser?.id;
    if (uid == null) {
      setState(() => _loadingFriends = false);
      return;
    }

    try {
      final client = SupabaseService.client;

      // Step 1: Accepted friendships
      final acceptedRows = List<Map<String, dynamic>>.from(
        await client
            .from('friendships')
            .select('id, requester_id, addressee_id')
            .or('requester_id.eq.$uid,addressee_id.eq.$uid')
            .eq('status', 'accepted') as List,
      );
      final friendIds = acceptedRows.map((f) =>
          f['requester_id'] == uid ? f['addressee_id'] as String : f['requester_id'] as String).toList();
      List<Map<String, dynamic>> friendProfiles = [];
      if (friendIds.isNotEmpty) {
        friendProfiles = List<Map<String, dynamic>>.from(
          await client.from('profiles').select().inFilter('id', friendIds) as List,
        );
      }

      // Step 2: Pending received
      final receivedRows = List<Map<String, dynamic>>.from(
        await client
            .from('friendships')
            .select('id, requester_id')
            .eq('addressee_id', uid)
            .eq('status', 'pending') as List,
      );
      final requesterIds = receivedRows.map((f) => f['requester_id'] as String).toList();
      List<Map<String, dynamic>> receivedProfiles = [];
      if (requesterIds.isNotEmpty) {
        final rProfiles = List<Map<String, dynamic>>.from(
          await client.from('profiles').select().inFilter('id', requesterIds) as List,
        );
        receivedProfiles = receivedRows.map((f) {
          final p = rProfiles.firstWhere((p) => p['id'] == f['requester_id'],
              orElse: () => <String, dynamic>{});
          return {'friendship_id': f['id'], ...p};
        }).toList();
      }

      // Step 3: Pending sent
      final sentRows = List<Map<String, dynamic>>.from(
        await client
            .from('friendships')
            .select('id, addressee_id')
            .eq('requester_id', uid)
            .eq('status', 'pending') as List,
      );
      final addresseeIds = sentRows.map((f) => f['addressee_id'] as String).toList();
      List<Map<String, dynamic>> sentProfiles = [];
      if (addresseeIds.isNotEmpty) {
        final aProfiles = List<Map<String, dynamic>>.from(
          await client.from('profiles').select().inFilter('id', addresseeIds) as List,
        );
        sentProfiles = sentRows.map((f) {
          final p = aProfiles.firstWhere((p) => p['id'] == f['addressee_id'],
              orElse: () => <String, dynamic>{});
          return {'friendship_id': f['id'], ...p};
        }).toList();
      }

      setState(() {
        _friends = friendProfiles;
        _pendingReceived = receivedProfiles;
        _pendingSent = sentProfiles;
        _loadingFriends = false;
      });
    } catch (e) {
      debugPrint('_loadFriends error: $e');
      setState(() => _loadingFriends = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final uid = SupabaseService.currentUser?.id;
      final results = await SupabaseService.client
          .from('profiles')
          .select()
          .ilike('username', '%${query.trim()}%')
          .neq('id', uid ?? '')
          .limit(10);

      final excludeIds = {
        uid ?? '',
        ..._friends.map((f) => f['id'] as String? ?? ''),
        ..._pendingSent.map((f) => f['id'] as String? ?? ''),
        ..._pendingReceived.map((f) => f['id'] as String? ?? ''),
      };
      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(results as List)
            .where((p) => !excludeIds.contains(p['id'] as String?))
            .toList();
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(String addresseeId) async {
    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return;
    try {
      await SupabaseService.client.from('friendships').insert({
        'requester_id': uid,
        'addressee_id': addresseeId,
        'status': 'pending',
      });
      if (mounted) {
        final l10n = AppLocalizations.of(
            context.read<SettingsProvider>().locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('friendRequestSent')),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _searchCtrl.clear();
        setState(() => _searchResults = []);
      }
    } catch (_) {}
  }

  Future<void> _respondToRequest(String friendshipId, bool accept) async {
    await SupabaseService.client
        .from('friendships')
        .update({'status': accept ? 'accepted' : 'rejected'}).eq('id', friendshipId);
    await _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translate('twinFriends'))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_rounded, size: 64, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                l10n.translate('twinFriends'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('tfLoginSubtitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: Text(l10n.translate('signIn')),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('twinFriends')),
        actions: [
          if (_pendingReceived.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Badge(
                label: Text('${_pendingReceived.length}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          PopupMenuButton(
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.translate('signOut')),
                  ],
                ),
              ),
            ],
            onSelected: (v) async {
              if (v == 'signout') await auth.signOut();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.translate('friends')),
            Tab(
              child: Consumer<ChallengeProvider>(
                builder: (context, cp, child) {
                  final uid = SupabaseService.currentUser?.id;
                  final badge = cp.pending
                      .where((c) => c.participants.any(
                          (p) => p.userId == uid && p.status == 'invited'))
                      .length;
                  if (badge == 0) {
                    return Text('⚡ ${l10n.translate('challenges')}');
                  }
                  return Badge(
                    label: Text('$badge'),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('⚡ ${l10n.translate('challenges')}'),
                    ),
                  );
                },
              ),
            ),
            Tab(text: l10n.translate('addFriend')),
            Tab(text: '🏆 ${l10n.translate('leaderboard')}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(l10n, theme),
          ChallengeTabBody(friends: _friends),
          _buildSearchTab(l10n, theme),
          _buildLeaderboardTab(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(AppLocalizations l10n, ThemeData theme) {
    if (_loadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ── Header stats ──────────────────────────────────
          if (_friends.isNotEmpty) _FriendsHeader(count: _friends.length, l10n: l10n),

          // ── Pending received ──────────────────────────────
          if (_pendingReceived.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(
              icon: Icons.notification_important_rounded,
              label: l10n.translate('pendingRequests'),
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 10),
            ..._pendingReceived.map((req) => _PendingCard(
                  profile: req,
                  onAccept: () => _respondToRequest(req['friendship_id'], true),
                  onReject: () => _respondToRequest(req['friendship_id'], false),
                  l10n: l10n,
                )),
          ],

          // ── Sent pending ──────────────────────────────────
          if (_pendingSent.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(
              icon: Icons.schedule_send_rounded,
              label: l10n.translate('sentRequests'),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            ..._pendingSent.map((req) {
              final uname = req['username'] as String? ?? '?';
              final ci = uname.codeUnitAt(0) % AppTheme.counterColors.length;
              final col = AppTheme.counterColors[ci];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: col.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(uname[0].toUpperCase(),
                            style: TextStyle(color: col, fontWeight: FontWeight.w800, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('@$uname', style: const TextStyle(fontWeight: FontWeight.w600))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l10n.translate('pending'),
                          style: const TextStyle(color: AppTheme.warningColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Friends list ──────────────────────────────────
          if (_friends.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(
              icon: Icons.people_rounded,
              label: l10n.translate('friends'),
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 10),
            ..._friends.map((f) => _FriendCard(profile: f, l10n: l10n)),
          ] else if (_pendingReceived.isEmpty && _pendingSent.isEmpty)
            _EmptyFriends(l10n: l10n, theme: theme),
        ],
      ),
    );
  }

  Widget _buildSearchTab(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              labelText: l10n.translate('searchUsername'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: (v) => _searchUsers(v),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (_, i) {
                final user = _searchResults[i];
                final uname = user['username'] as String? ?? '?';
                final dname = user['display_name'] as String?;
                final ci = uname.codeUnitAt(0) % AppTheme.counterColors.length;
                final col = AppTheme.counterColors[ci];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: col.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(color: col.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [col, col.withValues(alpha: 0.65)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(uname[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('@$uname', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              if (dname != null && dname.isNotEmpty)
                                Text(dname, style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _sendRequest(user['id'] as String),
                          icon: const Icon(Icons.person_add_rounded, size: 15),
                          label: Text(l10n.translate('addFriend'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(AppLocalizations l10n, ThemeData theme) {
    if (_loadingLeaderboard) {
      return const Center(child: CircularProgressIndicator());
    }

    final uid = SupabaseService.currentUser?.id;
    final ap = context.read<AchievementProvider>();

    if (_leaderboard.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('leaderboardEmpty'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        itemCount: _leaderboard.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _LeaderboardHeader(l10n: l10n);
          }
          final rank = index;
          final entry = _leaderboard[index - 1];
          final isMe = entry['id'] == uid;
          final entryXp = isMe ? ap.xp : (entry['xp'] as int? ?? 0);
          final entryLevel = isMe ? ap.level : (entry['level'] as int? ?? 1);
          return _LeaderboardRow(
            rank: rank,
            profile: entry,
            xp: entryXp,
            level: entryLevel,
            isMe: isMe,
            l10n: l10n,
          );
        },
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _LeaderboardHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        l10n.translate('leaderboardTitle'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> profile;
  final int xp;
  final int level;
  final bool isMe;
  final AppLocalizations l10n;

  const _LeaderboardRow({
    required this.rank,
    required this.profile,
    required this.xp,
    required this.level,
    required this.isMe,
    required this.l10n,
  });

  String get _rankEmoji {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
  }

  String get _levelEmoji {
    final idx = (level - 1).clamp(0, AchievementProvider.levelEmojis.length - 1);
    return AchievementProvider.levelEmojis[idx];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = profile['username'] as String? ?? '?';
    final colorIndex = username.codeUnitAt(0) % AppTheme.counterColors.length;
    final avatarColor = isMe
        ? const Color(0xFF2196F3)
        : AppTheme.counterColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF2196F3).withValues(alpha: 0.1)
            : theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMe
              ? const Color(0xFF2196F3).withValues(alpha: 0.35)
              : avatarColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(_rankEmoji, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center)
                : Text(
                    _rankEmoji,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      isMe ? l10n.translate('leaderboardYou') : '@$username',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isMe ? const Color(0xFF2196F3) : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_levelEmoji ${l10n.translate('level')} $level',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$xp XP',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isMe
                      ? const Color(0xFF2196F3)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AppLocalizations l10n;

  const _FriendCard({required this.profile, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = profile['username'] as String? ?? '?';
    final displayName = profile['display_name'] as String?;
    final initial = username[0].toUpperCase();
    final colorIndex = username.codeUnitAt(0) % AppTheme.counterColors.length;
    final avatarColor = AppTheme.counterColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: avatarColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [avatarColor, avatarColor.withValues(alpha: 0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@$username',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  if (displayName != null && displayName.isNotEmpty)
                    Text(
                      displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateChallengeScreen(
                  opponentId: profile['id'] as String,
                  opponentUsername: username,
                ),
              )),
              icon: const Icon(Icons.bolt_rounded, size: 15),
              label: Text(
                l10n.translate('launchChallenge'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final AppLocalizations l10n;

  const _PendingCard({
    required this.profile,
    required this.onAccept,
    required this.onReject,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = profile['username'] as String? ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.warningColor, Color(0xFFFFA726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '@$username',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerColor,
                    side: const BorderSide(color: AppTheme.dangerColor),
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.close_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.check_rounded, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

class _FriendsHeader extends StatelessWidget {
  final int count;
  final AppLocalizations l10n;

  const _FriendsHeader({required this.count, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.18),
            AppTheme.primaryColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤝', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                  height: 1.1,
                ),
              ),
              Text(
                count == 1 ? l10n.translate('friends') : l10n.translate('friends'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.people_rounded, size: 40, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _EmptyFriends({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👥', style: TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('noFriends'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.translate('noFriendsMessage'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
