import 'package:flutter/foundation.dart';
import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/call_history_service.dart';

enum CallsFilter { all, missed, incoming, outgoing, video }

class CallsSection {
  const CallsSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<CallThreadSummary> items;
}

class CallThreadSummary {
  const CallThreadSummary({
    required this.person,
    required this.entries,
  });

  final PersonEntry person;
  final List<CallHistoryEntry> entries;

  CallHistoryEntry get latest => entries.first;
  int get totalCount => entries.length;
  int get missedCount => entries.where((entry) => entry.isMissed).length;
  bool get hasVideo => entries.any((entry) => entry.isVideo);
  Duration get totalDuration => entries.fold(
        Duration.zero,
        (sum, entry) => sum + entry.duration,
      );
}

class CallsController extends ChangeNotifier {
  CallsController({CallHistoryService? service})
      : _service = service ?? CallHistoryService.instance;

  final CallHistoryService _service;

  List<CallHistoryEntry> _history = const <CallHistoryEntry>[];
  CallsFilter _filter = CallsFilter.all;
  String _query = '';
  bool _loading = true;

  List<CallHistoryEntry> get history => _history;
  CallsFilter get filter => _filter;
  String get query => _query;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _history = await _service.loadHistory();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setFilter(CallsFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
    await load();
  }

  Future<void> deleteEntries(List<String> ids) async {
    await _service.deleteEntries(ids);
    await load();
  }

  List<PersonEntry> get topContacts {
    final grouped = _groupedThreads;
    final values = grouped.values.toList()
      ..sort((a, b) {
        final countCompare = b.totalCount.compareTo(a.totalCount);
        if (countCompare != 0) return countCompare;
        return b.latest.startedAt.compareTo(a.latest.startedAt);
      });
    return values.take(8).map((item) => item.person).toList();
  }

  List<CallsSection> buildSections({
    required String todayLabel,
    required String yesterdayLabel,
    required String thisWeekLabel,
    required String earlierLabel,
  }) {
    final sections = <String, Map<String, List<CallHistoryEntry>>>{};
    final personById = <String, PersonEntry>{};
    for (final entry in _filteredHistory) {
      final sectionKey = _sectionTitle(
        entry.startedAt,
        todayLabel: todayLabel,
        yesterdayLabel: yesterdayLabel,
        thisWeekLabel: thisWeekLabel,
        earlierLabel: earlierLabel,
      );
      final bucket =
          sections.putIfAbsent(sectionKey, () => <String, List<CallHistoryEntry>>{});
      personById[entry.person.id] = entry.person;
      bucket.putIfAbsent(entry.person.id, () => <CallHistoryEntry>[]).add(entry);
    }

    return sections.entries.map((section) {
      final items = section.value.entries
          .map(
            (entry) => CallThreadSummary(
              person: personById[entry.key]!,
              entries: entry.value,
            ),
          )
          .toList()
        ..sort((a, b) => b.latest.startedAt.compareTo(a.latest.startedAt));
      return CallsSection(title: section.key, items: items);
    }).toList();
  }

  Map<String, CallThreadSummary> get _groupedThreads {
    final groupedEntries = <String, List<CallHistoryEntry>>{};
    final personById = <String, PersonEntry>{};
    for (final entry in _filteredHistory) {
      personById[entry.person.id] = entry.person;
      groupedEntries
          .putIfAbsent(entry.person.id, () => <CallHistoryEntry>[])
          .add(entry);
    }
    return groupedEntries.map(
      (personId, entries) => MapEntry(
        personId,
        CallThreadSummary(
          person: personById[personId]!,
          entries: entries,
        ),
      ),
    );
  }

  List<CallHistoryEntry> get _filteredHistory {
    return _history.where((entry) {
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        final phoneMatches = entry.person.phones.any(
          (phone) => phone.toLowerCase().contains(q),
        );
        if (!entry.person.displayName.toLowerCase().contains(q) &&
            !(entry.person.username?.toLowerCase().contains(q) ?? false) &&
            !phoneMatches) {
          return false;
        }
      }

      switch (_filter) {
        case CallsFilter.all:
          return true;
        case CallsFilter.missed:
          return entry.isMissed;
        case CallsFilter.incoming:
          return entry.direction == CallHistoryDirection.incoming;
        case CallsFilter.outgoing:
          return entry.direction == CallHistoryDirection.outgoing;
        case CallsFilter.video:
          return entry.isVideo;
      }
    }).toList();
  }

  String _sectionTitle(
    DateTime date, {
    required String todayLabel,
    required String yesterdayLabel,
    required String thisWeekLabel,
    required String earlierLabel,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff <= 0) return todayLabel;
    if (diff == 1) return yesterdayLabel;
    if (diff < 7) return thisWeekLabel;
    return earlierLabel;
  }
}
