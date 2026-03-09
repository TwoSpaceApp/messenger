import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                                l10n.callsTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.callsSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _openStartCall,
                          icon: const Icon(Icons.add_ic_call_outlined,
                              color: Colors.white),
                          tooltip: l10n.callsStartCallAction,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CallsSummaryCard(
                      title: l10n.callsQuickStartTitle,
                      subtitle: l10n.callsQuickStartSubtitle,
                      onTap: _openStartCall,
                      actionLabel: l10n.callsStartCallAction,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(CallsFilter.all, l10n.allFilter),
                        _buildFilterChip(CallsFilter.missed, l10n.missedFilter),
                        _buildFilterChip(CallsFilter.incoming, l10n.incomingFilter),
                        _buildFilterChip(CallsFilter.outgoing, l10n.outgoingFilter),
                        _buildFilterChip(CallsFilter.video, l10n.callsVideoFilter),
                      ],
                    ),
                  ),
                  if (_controller.topContacts.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.callsTopContactsTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _controller.topContacts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final person = _controller.topContacts[index];
                          return _TopContactChip(
                            person: person,
                            onTap: () => _startCall(person, false),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: RefreshIndicator(
                        key: ValueKey<int>(
                          sections.length + _controller.topContacts.length,
                        ),
                        onRefresh: _controller.load,
                        child: _buildBody(sections, l10n),
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

  Widget _buildFilterChip(CallsFilter filter, String label) {
    final selected = _controller.filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _controller.setFilter(filter),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        labelStyle: const TextStyle(color: Colors.white),
        checkmarkColor: Colors.white,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildBody(List<CallsSection> sections, AppLocalizations l10n) {
    if (_controller.loading) {
      return AppLoadingState(label: l10n.callsLoadingLabel);
    }

    if (sections.isEmpty) {
      return ListView(
        children: [
          AppEmptyState(
            title: l10n.callsEmptyTitle,
            message: _controller.query.trim().isNotEmpty
                ? l10n.callsEmptySearchMessage
                : l10n.callsEmptyMessage,
            icon: Icons.call_outlined,
            actionLabel: l10n.callsStartCallAction,
            onAction: _openStartCall,
          ),
        ],
      );
    }

    return ListView.builder(
      cacheExtent: 1200,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 110),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${section.items.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            ...section.items.map(
              (thread) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    onTap: () => _showThreadSheet(thread),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: PersonAvatar(
                        name: thread.person.displayName,
                        avatarUrl: thread.person.avatarUrl,
                        photoBytes: thread.person.photoBytes,
                        showOnline: thread.person.isOnline,
                      ),
                      title: Text(
                        thread.person.displayName,
                        style: TextStyle(
                          color: thread.missedCount > 0 ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _threadSubtitle(thread, l10n),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                      trailing: SizedBox(
                        width: 92,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(thread.latest.startedAt, l10n),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _startCall(thread.person, false),
                                  child: Icon(
                                    Icons.call_outlined,
                                    size: 18,
                                    color: Colors.green.withValues(alpha: 0.92),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => _startCall(thread.person, true),
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    size: 18,
                                    color: Colors.blue.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _threadSubtitle(CallThreadSummary thread, AppLocalizations l10n) {
    final type = thread.latest.isVideo ? l10n.videoCallLabel : l10n.voiceCallLabel;
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

  String _directionLabel(dynamic direction, AppLocalizations l10n) {
    return direction.name == 'incoming' ? l10n.incomingCall : l10n.outgoingCall;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes.clamp(1, 59));
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterdayLabel;
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }

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
                    Navigator.of(sheetContext).pop();
                    _startCall(thread.person, false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam_outlined),
                  title: Text(l10n.videoCallLabel),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _startCall(thread.person, true);
                  },
                ),
                if (thread.person.remoteUserId != null)
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline_rounded),
                    title: Text(l10n.sendMessageCallAction),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openChat(thread.person);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: Text(l10n.delete),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _controller.deleteEntry(thread.latest.id);
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

class _CallsSummaryCard extends StatelessWidget {
  const _CallsSummaryCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_ic_call_outlined, color: Colors.white),
          ),
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
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _TopContactChip extends StatelessWidget {
  const _TopContactChip({
    required this.person,
    required this.onTap,
  });

  final PersonEntry person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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
            const SizedBox(height: 8),
            SizedBox(
              width: 64,
              child: Text(
                person.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
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
