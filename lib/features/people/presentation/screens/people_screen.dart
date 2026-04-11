// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/loading_skeletons.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend_factory.dart';
import 'package:two_space_app/features/chat/presentation/screens/call_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/calls_screen.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/people_repository.dart';
import 'package:two_space_app/features/people/presentation/controllers/people_controller.dart';
import 'package:two_space_app/features/people/presentation/widgets/people_search_field.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_avatar.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_tile.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({
    super.key,
    this.autofocusSearch = false,
    this.simplified = false,
    this.titleOverride,
    this.searchHintOverride,
    this.subtitleOverride,
    this.showCallsShortcut = true,
    this.onRemotePersonTap,
  });
  final bool autofocusSearch;
  final bool simplified;
  final String? titleOverride;
  final String? searchHintOverride;
  final String? subtitleOverride;
  final bool showCallsShortcut;
  final Future<void> Function(PersonEntry person)? onRemotePersonTap;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late final PeopleController _controller;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  final ScrollController _bodyScrollController = ScrollController();
  final Map<String, GlobalKey> _phonebookSectionKeys = <String, GlobalKey>{};

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
    _bodyScrollController.dispose();
    super.dispose();
  }

  // ──────────────────────────── UI ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final title = widget.titleOverride ?? l10n.peopleTitle;
    final searchHint = widget.searchHintOverride ?? l10n.peopleSearchHint;
    final subtitle =
      widget.subtitleOverride ??
      (widget.autofocusSearch ? l10n.searchContactsHint : l10n.peopleSubtitle);
    final segmentOptions = <({PeopleSegment value, String label, IconData icon})>[
      (
        value: PeopleSegment.all,
        label: l10n.peopleSegmentAll,
        icon: Icons.grid_view_rounded,
      ),
      (
        value: PeopleSegment.twospace,
        label: l10n.peopleSegmentTwoSpace,
        icon: Icons.alternate_email_rounded,
      ),
      (
        value: PeopleSegment.phonebook,
        label: l10n.peopleSegmentPhonebook,
        icon: Icons.contact_phone_outlined,
      ),
      (
        value: PeopleSegment.recent,
        label: l10n.peopleSegmentRecent,
        icon: Icons.schedule_rounded,
      ),
    ];
    const pad = EdgeInsets.symmetric(horizontal: 16);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: UITokens.readableContentMaxWidth,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: pad.copyWith(top: 10, bottom: 8),
                      child: SectionCard(
                        radius: UITokens.cornerXL,
                        padding: const EdgeInsets.fromLTRB(
                          UITokens.spaceMdLg,
                          UITokens.spaceMdLg,
                          UITokens.spaceMdLg,
                          UITokens.spaceMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (canPop)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: UITokens.spaceSmMd,
                                    ),
                                    child: _HeaderIcon(
                                      icon: Icons.arrow_back_rounded,
                                      tooltip: l10n.back,
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: UITokens.spaceXSm),
                                      Text(
                                        subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AppColors.subtitleText(
                                                context,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.showCallsShortcut)
                                  _HeaderIcon(
                                    icon: Icons.history_rounded,
                                    tooltip: l10n.callsTitle,
                                    onTap: _openCallsHistory,
                                  ),
                              ],
                            ),
                            const SizedBox(height: UITokens.spaceMd),
                            PeopleSearchField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: widget.autofocusSearch,
                              hintText: searchHint,
                              embedded: true,
                              onChanged: _controller.updateQuery,
                              onClear: () {
                                _searchController.clear();
                                _controller.clearSearch();
                              },
                            ),
                            if (!widget.simplified) ...[
                              const SizedBox(height: UITokens.spaceMdSm),
                              Wrap(
                                spacing: UITokens.spaceSm,
                                runSpacing: UITokens.spaceSm,
                                children: segmentOptions.map((segment) {
                                  final selected =
                                      _controller.segment == segment.value;
                                  return ChoiceChip(
                                    selected: selected,
                                    showCheckmark: false,
                                    avatar: Icon(
                                      segment.icon,
                                      size: 18,
                                      color: selected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    label: Text(segment.label),
                                    selectedColor: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.96),
                                    side: BorderSide(
                                      color: selected
                                          ? theme.colorScheme.primary.withValues(alpha: 0.22)
                                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        UITokens.cornerXLg,
                                      ),
                                    ),
                                    onSelected: (_) =>
                                        _controller.setSegment(segment.value),
                                  );
                                }).toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceXS),
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

    final items = <Widget>[];

    // Permission card — compact, non-intrusive
    if (dashboard.permission != DeviceContactsPermission.granted) {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UITokens.spaceMd,
            0,
            UITokens.spaceMd,
            UITokens.spaceSm,
          ),
          child: _PermissionBanner(
            message:
                dashboard.permission ==
                    DeviceContactsPermission.permanentlyDenied
                ? l10n.peoplePermissionCardMessageSettings
                : l10n.peoplePermissionCardMessage,
            actionLabel:
                dashboard.permission ==
                    DeviceContactsPermission.permanentlyDenied
                ? l10n.openSettingsButton
                : l10n.requestPermissionButton,
            onAction: () async {
              if (dashboard.permission ==
                  DeviceContactsPermission.permanentlyDenied) {
                await openAppSettings();
              }
              await _controller.refresh();
            },
          ),
        ),
      );
    }

    if (_controller.isSearchingMode) {
      items.addAll(_searchContent(l10n));
    } else {
      items.addAll(_dashboardContent(dashboard, l10n));
    }

    if (items.isEmpty) {
      items.add(
        AppEmptyState(
          title: l10n.peopleNoPeopleTitle,
          message: l10n.peopleNoPeopleMessage,
          icon: Icons.people_outline_rounded,
        ),
      );
    }

    return ListView(
      controller: _bodyScrollController,
      cacheExtent: 800,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: UITokens.bottomSheetClearance),
      children: items,
    );
  }

  List<Widget> _dashboardContent(PeopleDashboardData d, AppLocalizations l10n) {
    final w = <Widget>[];
    final seen = <String>{};

    void section(
      String t,
      List<PersonEntry> p, {
      int? limit,
    }) {
      final filtered = _dedupePeople(_filter(p), seen);
      if (filtered.isEmpty) {
        return;
      }
      final visible = limit == null
          ? filtered
          : filtered.take(limit).toList(growable: false);
      w.add(_SectionLabel(title: t, count: filtered.length));
      w.addAll(visible.map((person) => _personTile(person, l10n)));
    }

    switch (_controller.segment) {
      case PeopleSegment.all:
        section(
          l10n.peopleFavoritesFrequentTitle,
          d.favoritesAndFrequent,
          limit: 4,
        );
        section(l10n.peopleRecentTitle, d.recentPeople, limit: 4);
        section(l10n.peopleTwoSpaceTitle, d.twoSpacePeople, limit: 6);
        section(l10n.peopleInviteTitle, d.invitePeople, limit: 4);
      case PeopleSegment.twospace:
        section(
          l10n.peopleTwoSpaceTitle,
          <PersonEntry>[
            ...d.favoritesAndFrequent,
            ...d.recentPeople,
            ...d.twoSpacePeople,
          ],
        );
      case PeopleSegment.phonebook:
        w.addAll(_phonebookContent(d, l10n));
      case PeopleSegment.recent:
        section(l10n.peopleRecentTitle, d.recentPeople);
    }
    return w;
  }

  List<Widget> _phonebookContent(
    PeopleDashboardData d,
    AppLocalizations l10n,
  ) {
    final people = _dedupePeople(
      _filter(<PersonEntry>[
        ...d.favoritesAndFrequent,
        ...d.recentPeople,
        ...d.twoSpacePeople,
        ...d.invitePeople,
      ]),
      <String>{},
    );
    if (people.isEmpty) {
      return const <Widget>[];
    }

    final grouped = <String, List<PersonEntry>>{};
    var twoSpaceCount = 0;
    var inviteCount = 0;
    for (final person in people) {
      if (person.isTwoSpaceUser) {
        twoSpaceCount++;
      }
      if (person.isInvitable) {
        inviteCount++;
      }
      grouped.putIfAbsent(_initialForPerson(person), () => <PersonEntry>[]).add(person);
    }

    final widgets = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(
          UITokens.spaceMd,
          UITokens.spaceSm,
          UITokens.spaceMd,
          UITokens.spaceSm,
        ),
        child: SectionCard(
          padding: const EdgeInsets.all(UITokens.spaceMdSm),
          child: Row(
            children: [
              Expanded(
                child: _PhonebookMetric(
                  label: l10n.peopleSegmentPhonebook,
                  value: '${people.length}',
                ),
              ),
              Expanded(
                child: _PhonebookMetric(
                  label: l10n.peopleTwoSpaceTitle,
                  value: '$twoSpaceCount',
                ),
              ),
              Expanded(
                child: _PhonebookMetric(
                  label: l10n.peopleInviteTitle,
                  value: '$inviteCount',
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    final sortedKeys = grouped.keys.toList()..sort();
    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(
          UITokens.spaceMd,
          0,
          UITokens.spaceMd,
          UITokens.spaceSm,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final key in sortedKeys)
                Padding(
                  padding: const EdgeInsets.only(right: UITokens.spaceXSm),
                  child: ActionChip(
                    label: Text(key),
                    onPressed: () => _jumpToPhonebookSection(key),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    for (final key in sortedKeys) {
      final entries = grouped[key]!..sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
      );
      widgets.add(
        KeyedSubtree(
          key: _phonebookSectionKeys.putIfAbsent(key, GlobalKey.new),
          child: _SectionLabel(title: key, count: entries.length),
        ),
      );
      widgets.addAll(entries.map((person) => _personTile(person, l10n)));
    }
    return widgets;
  }

  Future<void> _jumpToPhonebookSection(String key) async {
    final sectionKey = _phonebookSectionKeys[key];
    final sectionContext = sectionKey?.currentContext;
    if (sectionContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      sectionContext,
      duration: UITokens.durationMdLg,
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  List<Widget> _searchContent(AppLocalizations l10n) {
    final data = _controller.searchData;
    final w = <Widget>[];
    final seen = <String>{};
    if (_controller.searching) w.add(const PeopleInlineSkeleton());
    void section(String t, List<PersonEntry> p) {
      final f = _dedupePeople(_filter(p), seen);
      if (f.isEmpty) return;
      w.add(_SectionLabel(title: t, count: f.length));
      w.addAll(f.map((p) => _personTile(p, l10n)));
    }

    section(l10n.peopleSearchRemoteTitle, data.remoteResults);
    section(l10n.peopleSearchLocalTitle, data.localResults);
    section(l10n.peopleSearchInviteTitle, data.inviteResults);
    if (w.isEmpty) {
      w.add(
        AppEmptyState(
          title: l10n.peopleSearchEmptyTitle,
          message: l10n.peopleSearchEmptyMessage,
          icon: Icons.manage_search_rounded,
        ),
      );
    }
    return w;
  }

  Widget _personTile(PersonEntry person, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        0,
        UITokens.spaceMd,
        UITokens.spaceXSm,
      ),
      child: PersonTile(
        person: person,
        trailingLabel: person.isTwoSpaceUser
            ? l10n.peopleTwoSpaceBadge
            : person.isInvitable
            ? l10n.peopleInviteTitle
            : null,
        subtitle: _subtitle(person, l10n),
        onTap: person.remoteUserId != null
            ? () => _handleRemotePersonTap(person)
            : () => _showPersonSheet(person),
        onFavoriteTap: () => _controller.toggleFavorite(person),
        onMessageTap: person.remoteUserId != null
            ? () => _openChat(person)
            : null,
        onInviteTap: person.isInvitable ? () => _invitePerson(person) : null,
        onMoreTap: () => _showPersonSheet(person),
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

  List<PersonEntry> _dedupePeople(List<PersonEntry> people, Set<String> seen) {
    final unique = <PersonEntry>[];
    for (final person in people) {
      final key = _personDedupKey(person);
      if (seen.add(key)) {
        unique.add(person);
      }
    }
    return unique;
  }

  String _personDedupKey(PersonEntry person) {
    final remote = person.remoteUserId?.trim();
    if (remote != null && remote.isNotEmpty) {
      return 'remote:$remote';
    }
    if (person.phones.isNotEmpty) {
      return 'phone:${person.phones.first.trim()}';
    }
    return 'local:${person.id.trim()}';
  }

  String _initialForPerson(PersonEntry person) {
    final source = person.displayName.trim().isNotEmpty
        ? person.displayName.trim()
        : (person.phones.isNotEmpty ? person.phones.first.trim() : '#');
    final first = source.characters.first.toUpperCase();
    return RegExp('[A-ZА-Я0-9]').hasMatch(first) ? first : '#';
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
    if (person.username != null && person.username!.isNotEmpty)
      return '@${person.username!}';
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
    final remoteUserId = person.remoteUserId;
    if (remoteUserId == null) return;
    await _controller.rememberPerson(person);
    final backend = createChatBackend();
    final map = await backend.getOrCreateDirectChat(remoteUserId);
    if (!mounted) return;
    final chat = Chat.fromMap(map);
    await context.push(
      '${AppStrings.routeChat}/${Uri.encodeComponent(chat.id)}',
      extra: chat,
    );
  }

  Future<void> _handleRemotePersonTap(PersonEntry person) async {
    final customTap = widget.onRemotePersonTap;
    if (customTap != null) {
      await customTap(person);
      return;
    }
    await _openProfile(person);
  }

  Future<void> _openProfile(PersonEntry person) async {
    final remoteUserId = person.remoteUserId;
    if (remoteUserId == null) return;
    await _controller.rememberPerson(person);
    if (!mounted) return;
    await context.push(
      AppStrings.routeProfile,
      extra: <String, dynamic>{
        'userId': remoteUserId,
        'initialName': person.displayName,
        'initialAvatar': person.avatarUrl,
      },
    );
  }

  Future<void> _startCall(PersonEntry person, bool isVideo) async {
    await _controller.rememberPerson(person);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          room:
              'call_${person.stableRemoteId}_${DateTime.now().millisecondsSinceEpoch}',
          person: person,
          isVideo: isVideo,
          displayName: person.displayName,
          avatarUrl: person.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _openCallsHistory() async {
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CallsScreen()),
    );
  }

  Future<void> _invitePerson(PersonEntry person) async {
    final l10n = AppLocalizations.of(context)!;
    await _controller.rememberPerson(person);
    await Share.share(l10n.peopleInviteSpecificShareText(person.displayName));
  }

  Future<void> _showPersonSheet(PersonEntry person) async {
    final l10n = AppLocalizations.of(context)!;
    final badgeLabel = person.isTwoSpaceUser
        ? l10n.peopleTwoSpaceBadge
        : person.isInvitable
        ? l10n.peopleInviteTitle
        : null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UITokens.corner2Lg),
          ),
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
                const SizedBox(height: UITokens.spaceSm),
                Container(
                  width: UITokens.dragHandleWidth,
                  height: UITokens.dragHandleHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      ctx,
                    ).colorScheme.outline.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(UITokens.cornerPill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UITokens.spaceMd,
                    UITokens.spaceSmMd,
                    UITokens.spaceMd,
                    UITokens.spaceXSm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonAvatar(
                        name: person.displayName,
                        avatarUrl: person.avatarUrl,
                        photoBytes: person.photoBytes,
                        showOnline: person.isOnline,
                      ),
                      const SizedBox(width: UITokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: UITokens.space2XS),
                            Text(
                              _subtitle(person, l10n),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (badgeLabel != null) ...[
                              const SizedBox(height: UITokens.spaceSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: UITokens.spaceSmMd,
                                  vertical: UITokens.spaceXSm,
                                ),
                                decoration: BoxDecoration(
                                  color: person.isInvitable && !person.isTwoSpaceUser
                                      ? Theme.of(ctx)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.9)
                                      : Theme.of(ctx)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(
                                    UITokens.cornerPill,
                                  ),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                const Divider(height: UITokens.borderThin),
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
                          leading: const Icon(
                            Icons.chat_bubble_outline_rounded,
                          ),
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
                          color: person.isFavorite
                              ? AppColors.favoriteActive(ctx)
                              : null,
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
                      const SizedBox(height: UITokens.spaceSm),
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
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: UITokens.spaceXSm),
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
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceSm,
        UITokens.spaceMd,
        UITokens.spaceXS,
      ),
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

class _PhonebookMetric extends StatelessWidget {
  const _PhonebookMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: UITokens.space2XS),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.subtitleText(context),
          ),
        ),
      ],
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceMdSm,
        vertical: UITokens.space,
      ),
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
                const SizedBox(width: UITokens.space),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.subtitleText(context),
                    ),
                  ),
                ),
              ],
            ),
            if (isNarrow) const SizedBox(height: UITokens.spaceSmMd),
            Align(
              alignment: isNarrow ? Alignment.centerRight : Alignment.center,
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
              const SizedBox(width: UITokens.spaceSm),
              content.last,
            ],
          );
        },
      ),
    );
  }
}
