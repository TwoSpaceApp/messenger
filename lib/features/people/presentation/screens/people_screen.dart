import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
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
    this.simplified = false,
  });
  final bool autofocusSearch;
  final bool simplified;

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

  // ──────────────────────────── UI ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    const pad = EdgeInsets.symmetric(horizontal: 16);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  children: [
                    // ── Header row ──
                    Padding(
                      padding: pad.copyWith(top: 10, bottom: 2),
                      child: Row(
                        children: [
                          if (canPop)
                            _HeaderIcon(
                              icon: Icons.arrow_back_rounded,
                              tooltip: l10n.back,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                          if (canPop) const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.peopleTitle,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!widget.simplified) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.peopleSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.subtitleText(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!widget.simplified) ...[
                            _HeaderIcon(
                              icon: Icons.sync_rounded,
                              tooltip: l10n.peopleQuickSync,
                              onTap: _controller.loading
                                  ? null
                                  : _controller.refresh,
                            ),
                            _HeaderIcon(
                              icon: Icons.share_outlined,
                              tooltip: l10n.peopleQuickInvite,
                              onTap: _shareInviteText,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ── Search ──
                    Padding(
                      padding: pad.copyWith(top: 4, bottom: 4),
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
                    // ── Filter chips ──
                    if (!widget.simplified) ...[
                      SizedBox(
                        height: 36,
                        child: ListView(
                          padding: pad,
                          scrollDirection: Axis.horizontal,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: [
                            _chip(PeopleSegment.all, l10n.peopleSegmentAll),
                            _chip(PeopleSegment.twospace, l10n.peopleSegmentTwoSpace),
                            _chip(PeopleSegment.phonebook, l10n.peopleSegmentPhonebook),
                            _chip(PeopleSegment.recent, l10n.peopleSegmentRecent),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // ── Body ──
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _controller.refresh,
                        child: _buildBody(l10n),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(PeopleSegment segment, String label) {
    final selected = _controller.segment == segment;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => _controller.setSegment(segment),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.56),
        selectedColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.55)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ──────────────────────── Body builders ──────────────────────

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
      return ListView(children: [
        AppEmptyState(
          title: l10n.peopleNoPeopleTitle,
          message: l10n.peopleNoPeopleMessage,
          icon: Icons.people_outline_rounded,
        ),
      ]);
    }

    final items = <Widget>[];

    // Permission card — compact, non-intrusive
    if (dashboard.permission != DeviceContactsPermission.granted) {
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _PermissionBanner(
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
      ));
    }

    if (_controller.isSearchingMode) {
      items.addAll(_searchContent(l10n));
    } else {
      items.addAll(_dashboardContent(dashboard, l10n));
    }

    if (items.isEmpty) {
      items.add(AppEmptyState(
        title: l10n.peopleNoPeopleTitle,
        message: l10n.peopleNoPeopleMessage,
        icon: Icons.people_outline_rounded,
      ));
    }

    return ListView(
      cacheExtent: 800,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 100),
      children: items,
    );
  }

  List<Widget> _dashboardContent(PeopleDashboardData d, AppLocalizations l10n) {
    final w = <Widget>[];
    void section(String t, List<PersonEntry> p) {
      final f = _filter(p);
      if (f.isEmpty) return;
      w.add(_SectionLabel(title: t, count: f.length));
      w.addAll(f.map((p) => _personTile(p, l10n)));
    }
    section(l10n.peopleFavoritesFrequentTitle, d.favoritesAndFrequent);
    section(l10n.peopleRecentTitle, d.recentPeople);
    section(l10n.peopleTwoSpaceTitle, d.twoSpacePeople);
    section(l10n.peopleInviteTitle, d.invitePeople);
    return w;
  }

  List<Widget> _searchContent(AppLocalizations l10n) {
    final data = _controller.searchData;
    final w = <Widget>[];
    if (_controller.searching) w.add(const PeopleInlineSkeleton());
    void section(String t, List<PersonEntry> p) {
      final f = _filter(p);
      if (f.isEmpty) return;
      w.add(_SectionLabel(title: t, count: f.length));
      w.addAll(f.map((p) => _personTile(p, l10n)));
    }
    section(l10n.peopleSearchRemoteTitle, data.remoteResults);
    section(l10n.peopleSearchLocalTitle, data.localResults);
    section(l10n.peopleSearchInviteTitle, data.inviteResults);
    if (w.isEmpty) {
      w.add(AppEmptyState(
        title: l10n.peopleSearchEmptyTitle,
        message: l10n.peopleSearchEmptyMessage,
        icon: Icons.manage_search_rounded,
      ));
    }
    return w;
  }

  Widget _personTile(PersonEntry person, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: PersonTile(
        person: person,
        trailingLabel: l10n.peopleTwoSpaceBadge,
        subtitle: _subtitle(person, l10n),
        onTap: person.remoteUserId != null
            ? () => _openProfile(person)
            : () => _showPersonSheet(person),
        onFavoriteTap: () => _controller.toggleFavorite(person),
        onMessageTap: person.remoteUserId != null ? () => _openChat(person) : null,
        onVoiceCallTap: person.remoteUserId != null ? () => _startCall(person, false) : null,
        onVideoCallTap: person.remoteUserId != null ? () => _startCall(person, true) : null,
        onInviteTap: person.isInvitable ? () => _invitePerson(person) : null,
      ),
    );
  }

  // ──────────────────────── Helpers ──────────────────────────

  List<PersonEntry> _filter(List<PersonEntry> people) {
    switch (_controller.segment) {
      case PeopleSegment.all:
        return people;
      case PeopleSegment.twospace:
        return people.where((p) => p.isTwoSpaceUser).toList();
      case PeopleSegment.phonebook:
        return people.where((p) => p.isDeviceContact).toList();
      case PeopleSegment.recent:
        return people.where((p) => p.lastInteractionAt != null).toList();
    }
  }

  String _subtitle(PersonEntry person, AppLocalizations l10n) {
    if (person.isInvitable) {
      return person.phones.isNotEmpty
          ? '${person.phones.first} • ${l10n.peopleInviteSubtitle}'
          : l10n.peopleInviteSubtitle;
    }
    final presenceLabel = _presenceLabel(person, l10n);
    if (presenceLabel != null) {
      return person.username != null
          ? '@${person.username!} • $presenceLabel'
          : presenceLabel;
    }
    if (person.lastInteractionAt != null) {
      return person.username != null
          ? '@${person.username!} • ${_rel(person.lastInteractionAt!, l10n)}'
          : _rel(person.lastInteractionAt!, l10n);
    }
    if (person.lastSeenAt != null) {
      return person.username != null
          ? '@${person.username!} • ${_rel(person.lastSeenAt!, l10n)}'
          : _rel(person.lastSeenAt!, l10n);
    }
    if (person.username != null && person.username!.isNotEmpty) return '@${person.username!}';
    if (person.phones.isNotEmpty) return person.phones.first;
    return l10n.peopleNoDetails;
  }

  String? _presenceLabel(PersonEntry person, AppLocalizations l10n) {
    final status = person.presenceStatus?.toLowerCase();
    if (person.isOnline || status == 'online') {
      return l10n.onlineLabel;
    }
    if (status == 'recently') {
      return l10n.statusLastSeenRecently;
    }
    if ((status == 'was_online' || status == 'offline') &&
        person.lastSeenAt != null) {
      return _rel(person.lastSeenAt!, l10n);
    }
    if (status == 'long_ago') {
      return l10n.offlineLabel;
    }
    return null;
  }

  String _rel(DateTime t, AppLocalizations l10n) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return l10n.lessThanMinuteAgo;
    if (d.inMinutes < 60) return l10n.minutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.hoursAgo(d.inHours);
    if (d.inDays < 7) return l10n.daysAgo(d.inDays);
    return '${t.day}.${t.month.toString().padLeft(2, '0')}';
  }

  // ──────────────────────── Actions ──────────────────────────

  Future<void> _openChat(PersonEntry person) async {
    if (person.remoteUserId == null) return;
    await _controller.rememberPerson(person);
    final backend = createChatBackend();
    final map = await backend.getOrCreateDirectChat(person.remoteUserId!);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chat: Chat.fromMap(map))),
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
    await Share.share(l10n.peopleInviteSpecificShareText(person.displayName));
  }

  Future<void> _showPersonSheet(PersonEntry person) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.78,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          person.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.closeButton,
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _subtitle(person, l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (person.remoteUserId != null) ...[
                        ListTile(
                          leading: const Icon(Icons.person_outline_rounded),
                          title: Text(l10n.peopleViewProfileAction),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openProfile(person);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline_rounded),
                          title: Text(l10n.writeMessageAction),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openChat(person);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.call_outlined),
                          title: Text(l10n.voiceCallLabel),
                          onTap: () {
                            Navigator.pop(ctx);
                            _startCall(person, false);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.videocam_outlined),
                          title: Text(l10n.videoCallLabel),
                          onTap: () {
                            Navigator.pop(ctx);
                            _startCall(person, true);
                          },
                        ),
                      ],
                      if (person.isInvitable)
                        ListTile(
                          leading: const Icon(Icons.share_outlined),
                          title: Text(l10n.inviteAction),
                          onTap: () {
                            Navigator.pop(ctx);
                            _invitePerson(person);
                          },
                        ),
                      ListTile(
                        leading: Icon(
                          person.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: person.isFavorite ? AppColors.favoriteActive(ctx) : null,
                        ),
                        title: Text(
                          person.isFavorite
                              ? l10n.peopleRemoveFavoriteAction
                              : l10n.peopleAddFavoriteAction,
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _controller.toggleFavorite(person);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════ Private widgets ══════════════════════

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.26),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onTap == null
              ? colorScheme.onSurface.withValues(alpha: 0.45)
              : colorScheme.onSurface,
          size: 20,
        ),
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.count});
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.subtitleText(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
          if (count != null)
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.hintText(context),
                    fontWeight: FontWeight.w700,
                  ),
            ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.message, required this.actionLabel, required this.onAction});
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;
          final content = <Widget>[
            Row(
              children: [
                Icon(
                  Icons.contact_phone_outlined,
                  color: AppColors.subtitleText(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.subtitleText(context)),
                  ),
                ),
              ],
            ),
            if (isNarrow) const SizedBox(height: 10),
            Align(
              alignment:
                  isNarrow ? Alignment.centerRight : Alignment.center,
              child: TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ];

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content,
            );
          }

          return Row(
            children: [
              Expanded(child: content.first),
              const SizedBox(width: 8),
              content.last,
            ],
          );
        },
      ),
    );
  }
}
