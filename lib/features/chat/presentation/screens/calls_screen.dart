import 'package:flutter/material.dart';
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
import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/presentation/controllers/calls_controller.dart';
import 'package:two_space_app/features/people/presentation/widgets/people_search_field.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_avatar.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  late final CallsController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = CallsController()..load();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────── UI ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const pad = EdgeInsets.symmetric(horizontal: 16);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sections = _controller.buildSections(
          todayLabel: l10n.callsTodaySection,
          yesterdayLabel: l10n.yesterdayLabel,
          thisWeekLabel: l10n.callsThisWeekSection,
          earlierLabel: l10n.callsEarlierSection,
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ScreenBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header row ──
                      Padding(
                        padding: pad.copyWith(top: 14, bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.callsTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _openStartCall,
                              icon: Icon(Icons.add_ic_call_outlined,
                                  color: theme.colorScheme.onSurface, size: 22),
                              tooltip: l10n.callsStartCallAction,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      // ── Search ──
                      Padding(
                        padding: pad.copyWith(top: 6, bottom: 6),
                        child: PeopleSearchField(
                          controller: _searchController,
                          hintText: l10n.callsSearchHint,
                          onChanged: _controller.updateQuery,
                          onClear: () {
                            _searchController.clear();
                            _controller.updateQuery('');
                          },
                        ),
                      ),
                      // ── Filter chips ──
                      SizedBox(
                        height: 40,
                        child: ListView(
                          padding: pad,
                          scrollDirection: Axis.horizontal,
                          children: [
                            _chip(CallsFilter.all, l10n.allFilter),
                            _chip(CallsFilter.missed, l10n.missedFilter),
                            _chip(CallsFilter.incoming, l10n.incomingFilter),
                            _chip(CallsFilter.outgoing, l10n.outgoingFilter),
                            _chip(CallsFilter.video, l10n.callsVideoFilter),
                          ],
                        ),
                      ),
                      // ── Top contacts strip ──
                      if (_controller.topContacts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: pad,
                                child: Text(
                                  l10n.callsTopContactsTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.subtitleText(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 88,
                                child: ListView.separated(
                                  padding: pad,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _controller.topContacts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (_, i) {
                                    final p = _controller.topContacts[i];
                                    return _TopContactChip(
                                      person: p,
                                      onTap: () => _startCall(p, false),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // ── History list ──
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _controller.load,
                          child: _buildBody(sections, l10n),
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

  Widget _chip(CallsFilter filter, String label) {
    final selected = _controller.filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _controller.setFilter(filter),
        backgroundColor: AppColors.chipBackground(context),
        selectedColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        checkmarkColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ──────────────────────── Body ──────────────────────────

  Widget _buildBody(List<CallsSection> sections, AppLocalizations l10n) {
    if (_controller.loading) return const CallsListSkeleton();

    if (sections.isEmpty) {
      return ListView(children: [
        AppEmptyState(
          title: l10n.callsEmptyTitle,
          message: _controller.query.trim().isNotEmpty
              ? l10n.callsEmptySearchMessage
              : l10n.callsEmptyMessage,
          icon: Icons.call_outlined,
          actionLabel: l10n.callsStartCallAction,
          onAction: _openStartCall,
        ),
      ]);
    }

    return ListView.builder(
      cacheExtent: 800,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.subtitleText(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                    ),
                  ),
                  Text(
                    '${section.items.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.hintText(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            ...section.items.map((thread) => _callTile(thread, l10n)),
          ],
        );
      },
    );
  }

  Widget _callTile(CallThreadSummary thread, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: ValueKey(thread.latest.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          await _controller.deleteEntry(thread.latest.id);
          return false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 22),
        ),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          onTap: () => _showThreadSheet(thread),
          child: ListTile(
            minVerticalPadding: 0,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: PersonAvatar(
              name: thread.person.displayName,
              avatarUrl: thread.person.avatarUrl,
              photoBytes: thread.person.photoBytes,
              radius: 22,
              showOnline: thread.person.isOnline,
            ),
            title: Text(
              thread.person.displayName,
              style: TextStyle(
                color: thread.missedCount > 0 ? AppColors.danger(context) : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _threadSubtitle(thread, l10n),
                style: TextStyle(
                    color: AppColors.subtitleText(context), fontSize: 13),
              ),
            ),
            trailing: SizedBox(
              width: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(thread.latest.startedAt, l10n),
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.hintText(context)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _startCall(thread.person, false),
                        child: Icon(Icons.call_outlined,
                            size: 18,
                    color: Colors.green.withValues(alpha: 0.92)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _startCall(thread.person, true),
                        child: Icon(Icons.videocam_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.92)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────── Helpers ──────────────────────────

  String _threadSubtitle(CallThreadSummary thread, AppLocalizations l10n) {
    final type =
        thread.latest.isVideo ? l10n.videoCallLabel : l10n.voiceCallLabel;
    final count = thread.totalCount > 1
        ? l10n.callsThreadCount(thread.totalCount)
        : _directionLabel(thread.latest.direction, l10n);
    final duration = thread.totalDuration > Duration.zero
        ? ' • ${_formatDuration(thread.totalDuration)}'
        : '';
    if (thread.missedCount > 0) {
      return '${l10n.callsMissedSummary(thread.missedCount)} • $type$duration';
    }
    return '$count • $type$duration';
  }

  String _directionLabel(CallHistoryDirection direction, AppLocalizations l10n) {
    return direction == CallHistoryDirection.incoming
        ? l10n.incomingCall
        : l10n.outgoingCall;
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${duration.inMinutes}:${s.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes.clamp(1, 59));
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterdayLabel;
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }

  // ──────────────────────── Actions ──────────────────────────

  Future<void> _openStartCall() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchContactsScreen()),
    );
    await _controller.load();
  }

  Future<void> _openChat(PersonEntry person) async {
    if (person.remoteUserId == null) return;
    final backend = createChatBackend();
    final map = await backend.getOrCreateDirectChat(person.remoteUserId!);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chat: Chat.fromMap(map))),
    );
  }

  Future<void> _startCall(PersonEntry person, bool isVideo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          room: 'call_${person.stableRemoteId}_${DateTime.now().millisecondsSinceEpoch}',
          person: person,
          displayName: person.displayName,
          avatarUrl: person.avatarUrl,
          isVideo: isVideo,
        ),
      ),
    );
    await _controller.load();
  }

  Future<void> _showThreadSheet(CallThreadSummary thread) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider(context), borderRadius: BorderRadius.circular(99)),
              ),
              ListTile(
                leading: PersonAvatar(
                  name: thread.person.displayName,
                  avatarUrl: thread.person.avatarUrl,
                  photoBytes: thread.person.photoBytes,
                ),
                title: Text(thread.person.displayName),
                subtitle: Text(_threadSubtitle(thread, l10n)),
              ),
              ListTile(
                leading: const Icon(Icons.call_outlined),
                title: Text(l10n.voiceCallLabel),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startCall(thread.person, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(l10n.videoCallLabel),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startCall(thread.person, true);
                },
              ),
              if (thread.person.remoteUserId != null)
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded),
                  title: Text(l10n.sendMessageCallAction),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openChat(thread.person);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(l10n.delete),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _controller.deleteEntry(thread.latest.id);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════ Private widgets ══════════════════════

class _TopContactChip extends StatelessWidget {
  const _TopContactChip({required this.person, required this.onTap});
  final PersonEntry person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            PersonAvatar(
              name: person.displayName,
              avatarUrl: person.avatarUrl,
              photoBytes: person.photoBytes,
              radius: 20,
              showOnline: person.isOnline,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                person.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
