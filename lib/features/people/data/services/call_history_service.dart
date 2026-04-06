import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/people_local_store.dart';

class CallHistoryService {
  CallHistoryService._();

  static final CallHistoryService instance = CallHistoryService._();
  final PeopleLocalStore _store = PeopleLocalStore.instance;

  Future<List<CallHistoryEntry>> loadHistory() => _store.readCallHistory();

  Future<void> deleteEntry(String id) => _store.deleteCallHistory(id);

  Future<void> deleteEntries(List<String> ids) =>
      _store.deleteCallHistoryEntries(ids);

  Future<void> recordOutgoingCall({
    required PersonEntry person,
    required bool isVideo,
    required DateTime startedAt,
    required Duration duration,
    bool connected = true,
  }) async {
    final entry = CallHistoryEntry(
      id: 'call_${startedAt.microsecondsSinceEpoch}_${person.id}',
      person: person,
      startedAt: startedAt,
      duration: duration,
      isVideo: isVideo,
      direction: CallHistoryDirection.outgoing,
      outcome:
          connected ? CallHistoryOutcome.connected : CallHistoryOutcome.canceled,
    );

    await _store.appendCallHistory(entry);
    await _store.putRecentPerson(
      person.copyWith(lastInteractionAt: startedAt.add(duration)),
    );
    await _store.upsertCachedPeople(<PersonEntry>[
      person.copyWith(lastInteractionAt: startedAt.add(duration)),
    ]);
  }
}
