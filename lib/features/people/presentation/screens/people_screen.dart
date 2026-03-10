import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/responsive.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/loading_skeletons.dart';
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
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final maxContentWidth = MediaQuery.sizeOf(context).width >= 900 ? 860.0 : double.infinity;
    final horizontalPadding = 16.s(context);
    final headerTopPadding = 16.s(context);
    final headerGap = 8.s(context);
    final sectionGap = 12.s(context);
    final chipHeight = 40.s(context).clamp(36.0, 48.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ScreenBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          headerTopPadding,
                          horizontalPadding,
                          headerGap,
                        ),
                        child: Row(
                          children: [
                            const AppLogo(large: false),
                            SizedBox(width: 8.s(context)),
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
                                  SizedBox(height: 2.s(context)),
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
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _QuickActionsCard(
                          compact: isCompact,
                          newChatLabel: l10n.peopleQuickNewChat,
                          inviteLabel: l10n.peopleQuickInvite,
                          syncLabel: l10n.peopleQuickSync,
                          onNewChat: _focusSearch,
                          onInvite: _shareInviteText,
                          onSync: _controller.refresh,
                        ),
                      ),
                      if (_controller.dashboard != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            sectionGap,
                            horizontalPadding,
                            0,
                          ),
                          child: _PeopleHighlights(
                            compact: isCompact,
                            items: [
                              _OverviewItem(
                                label: l10n.peopleSegmentTwoSpace,
                                count: _controller.dashboard!.twoSpacePeople.length,
                                icon: Icons.verified_user_outlined,
                              ),
                              _OverviewItem(
                                label: l10n.peopleSegmentPhonebook,
                                count: _controller.dashboard!.twoSpacePeople
                                        .where((person) => person.isDeviceContact)
                                        .length +
                                    _controller.dashboard!.invitePeople.length,
                                icon: Icons.contact_page_outlined,
                              ),
                              _OverviewItem(
                                label: l10n.peopleInviteTitle,
                                count: _controller.dashboard!.invitePeople.length,
                                icon: Icons.share_outlined,
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          sectionGap,
                          horizontalPadding,
                          0,
                        ),
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
                      SizedBox(height: sectionGap),
                      SizedBox(
                        height: chipHeight,
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      SizedBox(height: sectionGap),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentChip(PeopleSegment segment, String label) {
    final selected = _controller.segment == segment;
    return Padding(
      padding: EdgeInsets.only(right: 8.s(context)),
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
      return const PeopleListSkeleton();
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
          padding: EdgeInsets.fromLTRB(
            16.s(context),
            0,
            16.s(context),
            12.s(context),
          ),
          child: _PermissionCard(
            compact: MediaQuery.sizeOf(context).width < 390,
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
              }
              await _controller.refresh();
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
      padding: EdgeInsets.only(bottom: 110.s(context)),
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
            padding: EdgeInsets.fromLTRB(
              16.s(context),
              0,
              16.s(context),
              8.s(context),
            ),
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
            padding: EdgeInsets.fromLTRB(
              16.s(context),
              0,
              16.s(context),
              8.s(context),
            ),
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
      widgets.add(const PeopleInlineSkeleton());
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.s(sheetContext))),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8.s(sheetContext)),
                Container(
                  width: 42.s(sheetContext),
                  height: 4.s(sheetContext),
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
                SizedBox(height: 12.s(sheetContext)),
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
      padding: EdgeInsets.fromLTRB(
        16.s(context),
        8.s(context),
        16.s(context),
        8.s(context),
      ),
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
              padding: EdgeInsets.symmetric(
                horizontal: 8.s(context),
                vertical: 4.s(context),
              ),
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
    required this.compact,
    required this.newChatLabel,
    required this.inviteLabel,
    required this.syncLabel,
    required this.onNewChat,
    required this.onInvite,
    required this.onSync,
  });

  final bool compact;
  final String newChatLabel;
  final String inviteLabel;
  final String syncLabel;
  final VoidCallback onNewChat;
  final VoidCallback onInvite;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _QuickActionButton(
        icon: Icons.edit_square,
        label: newChatLabel,
        onTap: onNewChat,
      ),
      _QuickActionButton(
        icon: Icons.share_outlined,
        label: inviteLabel,
        onTap: onInvite,
      ),
      _QuickActionButton(
        icon: Icons.sync_rounded,
        label: syncLabel,
        onTap: onSync,
      ),
    ];

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 8.s(context),
        vertical: 8.s(context),
      ),
      child: compact
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(child: actions[0]),
                    Expanded(child: actions[1]),
                  ],
                ),
                SizedBox(height: 6.s(context)),
                Row(
                  children: [
                    Expanded(child: actions[2]),
                    const Spacer(),
                  ],
                ),
              ],
            )
          : Row(
              children: actions
                  .map((action) => Expanded(child: action))
                  .toList(growable: false),
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
      borderRadius: BorderRadius.circular(16.s(context)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.s(context),
          vertical: 6.s(context),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20.s(context)),
            SizedBox(height: 6.s(context)),
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

class _OverviewItem {
  const _OverviewItem({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;
}

class _PeopleHighlights extends StatelessWidget {
  const _PeopleHighlights({
    required this.compact,
    required this.items,
  });

  final bool compact;
  final List<_OverviewItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.s(context),
      runSpacing: 8.s(context),
      children: items
          .map(
            (item) => SizedBox(
              width: compact ? double.infinity : 220.s(context),
              child: GlassCard(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.s(context),
                  vertical: 12.s(context),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.s(context),
                      height: 38.s(context),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.s(context)),
                      ),
                      child: Icon(item.icon, color: Colors.white),
                    ),
                    SizedBox(width: 12.s(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.count}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            item.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.compact,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final bool compact;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final details = Expanded(
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
          SizedBox(height: 4.s(context)),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
          ),
        ],
      ),
    );

    return GlassCard(
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      color: Colors.white,
                      size: 22.s(context),
                    ),
                    SizedBox(width: 12.s(context)),
                    details,
                  ],
                ),
                SizedBox(height: 12.s(context)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  Icons.contact_phone_outlined,
                  color: Colors.white,
                  size: 22.s(context),
                ),
                SizedBox(width: 12.s(context)),
                details,
                SizedBox(width: 12.s(context)),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ],
            ),
    );
  }
}
