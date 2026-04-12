import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFriends();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
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

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(results as List);
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
          tabs: [
            Tab(text: l10n.translate('friends')),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.translate('addFriend')),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsTab(l10n, theme),
          _buildSearchTab(l10n, theme),
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
        padding: const EdgeInsets.all(16),
        children: [
          // Received pending requests
          if (_pendingReceived.isNotEmpty) ...[
            Text(
              l10n.translate('pendingRequests'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingReceived.map((req) => _PendingCard(
                  profile: req,
                  onAccept: () => _respondToRequest(req['friendship_id'], true),
                  onReject: () => _respondToRequest(req['friendship_id'], false),
                  l10n: l10n,
                )),
            const Divider(height: 28),
          ],
          // Sent pending requests
          if (_pendingSent.isNotEmpty) ...[
            Text(
              l10n.translate('sentRequests'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingSent.map((req) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        (req['username'] as String? ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text('@${req['username'] ?? ''}'),
                    trailing: const Chip(
                      label: Text('En attente'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                )),
            const Divider(height: 28),
          ],
          // Friends list
          if (_friends.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const Icon(Icons.people_outline, size: 56,
                        color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(l10n.translate('noFriends'),
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(l10n.translate('noFriendsMessage'),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            )
          else
            ..._friends.map((f) => _FriendCard(profile: f)),
        ],
      ),
    );
  }

  Widget _buildSearchTab(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                        width: 18,
                        height: 18,
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        (user['username'] as String)[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text('@${user['username']}'),
                    subtitle: user['display_name'] != null
                        ? Text(user['display_name'] as String)
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add_rounded,
                          color: AppTheme.primaryColor),
                      onPressed: () => _sendRequest(user['id'] as String),
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
}

class _FriendCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _FriendCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            (profile['username'] as String)[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text('@${profile['username']}'),
        subtitle: profile['display_name'] != null
            ? Text(profile['display_name'] as String,
                style: theme.textTheme.bodySmall)
            : null,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.warningColor.withValues(alpha: 0.15),
          child: Text(
            (profile['username'] as String)[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.warningColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text('@${profile['username']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: AppTheme.successColor),
              onPressed: onAccept,
              tooltip: l10n.translate('accept'),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined,
                  color: AppTheme.dangerColor),
              onPressed: onReject,
              tooltip: l10n.translate('reject'),
            ),
          ],
        ),
      ),
    );
  }
}
