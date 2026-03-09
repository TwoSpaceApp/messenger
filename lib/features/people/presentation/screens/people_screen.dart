import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend_factory.dart';
import 'package:two_space_app/features/chat/presentation/screens/call_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/people_repository.dart';
import 'package:two_space_app/features/people/presentation/controllers/people_controller.dart';
import 'package:two_space_app/features/people/presentation/widgets/people_search_field.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_tile.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({
    super.key,
    this.autofocusSearch = false,
  });

  final bool autofocusSearch;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late final PeopleController _controller;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = PeopleController()..load();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ScreenBackground(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const AppLogo(large: false),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.peopleTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.peopleSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _QuickActionsCard(
                      newChatLabel: l10n.peopleQuickNewChat,
                      inviteLabel: l10n.peopleQuickInvite,
                      syncLabel: l10n.peopleQuickSync,
                      onNewChat: _focusSearch,
                      onInvite: _shareInviteText,
                      onSync: _controller.refresh,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: PeopleSearchField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: widget.autofocusSearch,
                      hintText: l10n.peopleSearchHint,
                      onChanged: _controller.updateQuery,
                      onClear: () {
                        _searchController.clear();
                        _controller.clearSearch();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSegmentChip(PeopleSegment.all, l10n.peopleSegmentAll),
                        _buildSegmentChip(
                          PeopleSegment.twospace,
                          l10n.peopleSegmentTwoSpace,
                        ),
                        _buildSegmentChip(
                          PeopleSegment.phonebook,
                          l10n.peopleSegmentPhonebook,
                        ),
                        _buildSegmentChip(
                          PeopleSegment.recent,
                          l10n.peopleSegmentRecent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: RefreshIndicator(
                        key: ValueKey<bool>(_controller.isSearchingMode),
                        onRefresh: _controller.refresh,
                        child: _buildBody(l10n),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentChip(PeopleSegment segment, String label) {
    final selected = _controller.segment == segment;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _controller.setSegment(segment),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        labelStyle: const TextStyle(color: Colors.white),
        checkmarkColor: Colors.white,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_controller.loading && _controller.dashboard == null) {
      return AppLoadingState(label: l10n.peopleLoading);
    }

    if (_controller.error != null && _controller.dashboard == null) {
      return AppErrorState(
        title: l10n.errorGeneric,
        message: _controller.error!,
        actionLabel: l10n.retry,
        onAction: _controller.refresh,
      );
    }

    final dashboard = _controller.dashboard;
    if (dashboard == null) {
      return ListView(
        children: [
          AppEmptyState(
            title: l10n.peopleNoPeopleTitle,
            message: l10n.peopleNoPeopleMessage,
            icon: Icons.people_outline_rounded,
          ),
        ],
      );
    }

    final children = <Widget>[
      if (dashboard.permission != DeviceContactsPermission.granted)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _PermissionCard(
            title: l10n.peoplePermissionCardTitle,
            message: dashboard.permission == DeviceContactsPermission.permanentlyDenied
                ? l10n.peoplePermissionCardMessageSettings
                : l10n.peoplePermissionCardMessage,
            actionLabel: dashboard.permission == DeviceContactsPermission.permanentlyDenied
                ? l10n.openSettingsButton
                : l10n.requestPermissionButton,
            onAction: () async {
              if (dashboard.permission == DeviceContactsPermission.permanentlyDenied) {
                await openAppSettings();
                await _controller.refresh();
              } else {
                await _controller.load();
              }
            },
          ),
        ),
    ];

    if (_controller.isSearchingMode) {
      children.addAll(_buildSearchContent(dashboard, l10n));
    } else {
      children.addAll(_buildDashboardContent(dashboard, l10n));
    }

    if (children.length == 1) {
      children.add(
        AppEmptyState(
          title: l10n.peopleNoPeopleTitle,
          message: l10n.peopleNoPeopleMessage,
          icon: Icons.people_outline_rounded,
        ),
      );
    }

    return ListView(
      cacheExtent: 1200,
      padding: const EdgeInsets.only(bottom: 110),
      children: children,
    );
  }

  List<Widget> _buildDashboardContent(
    PeopleDashboardData dashboard,
    AppLocalizations l10n,
  ) {
    final widgets = <Widget>[];

    void addSection(String title, List<PersonEntry> people) {
      final filtered = _applySegmentFilter(people);
      if (filtered.isEmpty) return;
      widgets.add(_SectionHeader(title: title, count: filtered.length));
      widgets.addAll(
        filtered.map(
          (person) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: PersonTile(
              person: person,
              trailingLabel: l10n.peopleTwoSpaceBadge,
              subtitle: _subtitleForPerson(person, l10n),
              onTap: () => _showPersonSheet(person),
              onFavoriteTap: () => _controller.toggleFavorite(person),
              onMessageTap: person.remoteUserId != null ? () => _openChat(person) : null,
              onVoiceCallTap: person.remoteUserId != null ? () => _startCall(person, false) : null,
              onVideoCallTap: person.remoteUserId != null ? () => _startCall(person, true) : null,
              onInviteTap: person.isInvitable ? () => _invitePerson(person) : null,
            ),
          ),
        ),
      );
    }

    addSection(l10n.peopleFavoritesFrequentTitle, dashboard.favoritesAndFrequent);
    addSection(l10n.peopleRecentTitle, dashboard.recentPeople);
    addSection(l10n.peopleTwoSpaceTitle, dashboard.twoSpacePeople);
    addSection(l10n.peopleInviteTitle, dashboard.invitePeople);
    return widgets;
  }

  List<Widget> _buildSearchContent(
    PeopleDashboardData dashboard,
    AppLocalizations l10n,
  ) {
    final data = _controller.searchData;
    final widgets = <Widget>[];

    void addSection(String title, List<PersonEntry> people) {
      final filtered = _applySegmentFilter(people);
      if (filtered.isEmpty) return;
      widgets.add(_SectionHeader(title: title, count: filtered.length));
      widgets.addAll(
        filtered.map(
          (person) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: PersonTile(
              person: person,
              trailingLabel: l10n.peopleTwoSpaceBadge,
              subtitle: _subtitleForPerson(person, l10n),
              onTap: () => _showPersonSheet(person),
              onFavoriteTap: () => _controller.toggleFavorite(person),
              onMessageTap: person.remoteUserId != null ? () => _openChat(person) : null,
              onVoiceCallTap: person.remoteUserId != null ? () => _startCall(person, false) : null,
              onVideoCallTap: person.remoteUserId != null ? () => _startCall(person, true) : null,
              onInviteTap: person.isInvitable ? () => _invitePerson(person) : null,
            ),
          ),
        ),
      );
    }

    if (_controller.searching) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppLoadingState(label: l10n.peopleSearching, compact: true),
      ));
    }

    addSection(l10n.peopleSearchRemoteTitle, data.remoteResults);
    addSection(l10n.peopleSearchLocalTitle, data.localResults);
    addSection(l10n.peopleSearchInviteTitle, data.inviteResults);

    if (widgets.isEmpty) {
      widgets.add(
        AppEmptyState(
          title: l10n.peopleSearchEmptyTitle,
          message: l10n.peopleSearchEmptyMessage,
          icon: Icons.manage_search_rounded,
        ),
      );
    }

    return widgets;
  }

  List<PersonEntry> _applySegmentFilter(List<PersonEntry> people) {
    switch (_controller.segment) {
      case PeopleSegment.all:
        return people;
      case PeopleSegment.twospace:
        return people.where((person) => person.isTwoSpaceUser).toList();
      case PeopleSegment.phonebook:
        return people.where((person) => person.isDeviceContact).toList();
      case PeopleSegment.recent:
        return people.where((person) => person.lastInteractionAt != null).toList();
    }
  }

  String _subtitleForPerson(PersonEntry person, AppLocalizations l10n) {
    if (person.isInvitable) {
      return person.phones.isNotEmpty
          ? '${person.phones.first} • ${l10n.peopleInviteSubtitle}'
          : l10n.peopleInviteSubtitle;
    }
    if (person.isOnline) {
      return person.username != null
          ? '@${person.username!} • ${l10n.onlineLabel}'
          : l10n.onlineLabel;
    }
    if (person.lastInteractionAt != null) {
      return person.username != null
          ? '@${person.username!} • ${_formatRelative(person.lastInteractionAt!, l10n)}'
          : _formatRelative(person.lastInteractionAt!, l10n);
    }
    if (person.lastSeenAt != null) {
      return person.username != null
          ? '@${person.username!} • ${_formatRelative(person.lastSeenAt!, l10n)}'
          : _formatRelative(person.lastSeenAt!, l10n);
    }
    if (person.username != null && person.username!.isNotEmpty) {
      return '@${person.username!}';
    }
    if (person.phones.isNotEmpty) {
      return person.phones.first;
    }
    return l10n.peopleNoDetails;
  }

  String _formatRelative(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return l10n.lessThanMinuteAgo;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${time.day}.${time.month.toString().padLeft(2, '0')}';
  }

  Future<void> _openChat(PersonEntry person) async {
    if (person.remoteUserId == null) return;
    await _controller.rememberPerson(person);
    final backend = createChatBackend();
    final map = await backend.getOrCreateDirectChat(person.remoteUserId!);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(chat: Chat.fromMap(map)),
      ),
    );
  }

  Future<void> _openProfile(PersonEntry person) async {
    if (person.remoteUserId == null) return;
    await _controller.rememberPerson(person);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userId: person.remoteUserId!,
          initialName: person.displayName,
          initialAvatar: person.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _startCall(PersonEntry person, bool isVideo) async {
    await _controller.rememberPerson(person);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          room: 'call_${person.stableRemoteId}_${DateTime.now().millisecondsSinceEpoch}',
          person: person,
          isVideo: isVideo,
          displayName: person.displayName,
          avatarUrl: person.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _shareInviteText() async {
    final l10n = AppLocalizations.of(context)!;
    await Share.share(l10n.peopleInviteShareText);
  }

  Future<void> _invitePerson(PersonEntry person) async {
    final l10n = AppLocalizations.of(context)!;
    await _controller.rememberPerson(person);
    await Share.share(
      l10n.peopleInviteSpecificShareText(person.displayName),
    );
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  Future<void> _showPersonSheet(PersonEntry person) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                ListTile(
                  title: Text(person.displayName),
                  subtitle: Text(_subtitleForPerson(person, l10n)),
                ),
                if (person.remoteUserId != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(l10n.peopleViewProfileAction),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openProfile(person);
                    },
                  ),
                if (person.remoteUserId != null)
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline_rounded),
                    title: Text(l10n.writeMessageAction),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openChat(person);
                    },
                  ),
                if (person.remoteUserId != null)
                  ListTile(
                    leading: const Icon(Icons.call_outlined),
                    title: Text(l10n.voiceCallLabel),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _startCall(person, false);
                    },
                  ),
                if (person.remoteUserId != null)
                  ListTile(
                    leading: const Icon(Icons.videocam_outlined),
                    title: Text(l10n.videoCallLabel),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _startCall(person, true);
                    },
                  ),
                if (person.isInvitable)
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: Text(l10n.inviteAction),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _invitePerson(person);
                    },
                  ),
                ListTile(
                  leading: Icon(
                    person.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  ),
                  title: Text(
                    person.isFavorite
                        ? l10n.peopleRemoveFavoriteAction
                        : l10n.peopleAddFavoriteAction,
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _controller.toggleFavorite(person);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.newChatLabel,
    required this.inviteLabel,
    required this.syncLabel,
    required this.onNewChat,
    required this.onInvite,
    required this.onSync,
  });

  final String newChatLabel;
  final String inviteLabel;
  final String syncLabel;
  final VoidCallback onNewChat;
  final VoidCallback onInvite;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.edit_square,
              label: newChatLabel,
              onTap: onNewChat,
            ),
          ),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.share_outlined,
              label: inviteLabel,
              onTap: onInvite,
            ),
          ),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.sync_rounded,
              label: syncLabel,
              onTap: onSync,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.contact_phone_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
