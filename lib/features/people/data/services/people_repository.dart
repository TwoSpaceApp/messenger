import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/call_history_service.dart';
import 'package:two_space_app/features/people/data/services/people_local_store.dart';

enum PeopleSegment { all, twospace, phonebook, recent }
enum DeviceContactsPermission { granted, denied, permanentlyDenied }

class DeviceContactsResult {
  const DeviceContactsResult({
    required this.permission,
    required this.contacts,
  });

  final DeviceContactsPermission permission;
  final List<PersonEntry> contacts;
}

class PeopleDashboardData {
  const PeopleDashboardData({
    required this.permission,
    required this.favoritesAndFrequent,
    required this.recentPeople,
    required this.twoSpacePeople,
    required this.invitePeople,
    required this.callHistory,
  });

  final DeviceContactsPermission permission;
  final List<PersonEntry> favoritesAndFrequent;
  final List<PersonEntry> recentPeople;
  final List<PersonEntry> twoSpacePeople;
  final List<PersonEntry> invitePeople;
  final List<CallHistoryEntry> callHistory;
}

class PeopleSearchData {
  const PeopleSearchData({
    required this.remoteResults,
    required this.localResults,
    required this.inviteResults,
  });

  final List<PersonEntry> remoteResults;
  final List<PersonEntry> localResults;
  final List<PersonEntry> inviteResults;

  bool get isEmpty =>
      remoteResults.isEmpty && localResults.isEmpty && inviteResults.isEmpty;
}

class PeopleRepository {
  PeopleRepository({
    AegisChatService? chatService,
    PeopleLocalStore? localStore,
    CallHistoryService? callHistoryService,
  })  : _chatService = chatService ?? AegisChatService(),
        _localStore = localStore ?? PeopleLocalStore.instance,
        _callHistoryService = callHistoryService ?? CallHistoryService.instance;

  final AegisChatService _chatService;
  final PeopleLocalStore _localStore;
  final CallHistoryService _callHistoryService;
  DeviceContactsResult? _deviceContactsCache;
  List<String>? _favoritesCache;
  List<PersonEntry>? _cachedPeopleCache;
  List<PersonEntry>? _recentPeopleCache;
  final Map<String, List<PersonEntry>> _remoteSearchCache =
      <String, List<PersonEntry>>{};

  Future<PeopleDashboardData> loadDashboard({
    bool requestPermission = true,
  }) async {
    final results = await Future.wait<dynamic>([
      _readFavorites(),
      _readCachedPeople(),
      _readRecentPeople(),
      _callHistoryService.loadHistory(),
      loadDeviceContacts(
        requestPermission: requestPermission,
      ),
    ]);
    final favorites = results[0] as List<String>;
    final cachedRemote = results[1] as List<PersonEntry>;
    final recentPeople = results[2] as List<PersonEntry>;
    final callHistory = results[3] as List<CallHistoryEntry>;
    final contactsResult = results[4] as DeviceContactsResult;

    final mergedRemote = _applyFavoriteIds(
      _mergePeople(<PersonEntry>[
        ...cachedRemote.where((person) => person.isTwoSpaceUser),
        ...recentPeople.where((person) => person.isTwoSpaceUser),
        ...callHistory.map((entry) => entry.person),
      ]),
      favorites,
    );

    final favoritesAndFrequent = _mergePeople(<PersonEntry>[
      ...mergedRemote.where((person) => person.isFavorite),
      ..._topFrequentPeople(callHistory).where(
        (person) => !favorites.contains(person.id),
      ),
    ]);

    final invitePeople = _sortPeople(
      _mergePeople(
        _applyFavoriteIds(
          contactsResult.contacts.where((person) => person.isInvitable).toList(),
          favorites,
        ),
      ),
    );

    return PeopleDashboardData(
      permission: contactsResult.permission,
      favoritesAndFrequent: _sortPeople(favoritesAndFrequent),
      recentPeople: _sortPeople(
        _applyFavoriteIds(
          recentPeople.where((person) => person.id.isNotEmpty).toList(),
          favorites,
        ),
      ),
      twoSpacePeople: _sortPeople(mergedRemote),
      invitePeople: invitePeople,
      callHistory: callHistory,
    );
  }

  Future<PeopleSearchData> searchPeople(
    String query, {
    bool requestPermission = false,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final shouldRunRemoteSearch = normalizedQuery.length >= 2;
    if (normalizedQuery.isEmpty) {
      return const PeopleSearchData(
        remoteResults: <PersonEntry>[],
        localResults: <PersonEntry>[],
        inviteResults: <PersonEntry>[],
      );
    }

    final results = await Future.wait<dynamic>([
      _readFavorites(),
      _readRecentPeople(),
      _readCachedPeople(),
      loadDeviceContacts(
        requestPermission: requestPermission,
      ),
    ]);
    final favorites = results[0] as List<String>;
    final recentPeople = results[1] as List<PersonEntry>;
    final cachedPeople = results[2] as List<PersonEntry>;
    final contactsResult = results[3] as DeviceContactsResult;

    final localMatches = _sortPeople(
      _applyFavoriteIds(
        _mergePeople(<PersonEntry>[
          ...recentPeople,
          ...cachedPeople,
        ]).where((person) => _matchesQuery(person, normalizedQuery)).toList(),
        favorites,
      ),
    );

    final inviteMatches = _sortPeople(
      _applyFavoriteIds(
        contactsResult.contacts
            .where((person) => person.isInvitable)
            .where((person) => _matchesQuery(person, normalizedQuery))
            .toList(),
        favorites,
      ),
    );

    var remoteMatches = <PersonEntry>[];
    if (shouldRunRemoteSearch) {
      remoteMatches = _remoteSearchCache[normalizedQuery] ?? <PersonEntry>[];
      try {
        if (remoteMatches.isEmpty) {
          await _chatService.ensureReady();
          final response = await _chatService.searchUsers(query.trim());
          remoteMatches = _sortPeople(
            _applyFavoriteIds(
              _mergePeople(response.map(_personFromSearchMap).toList()),
              favorites,
            ),
          );
          _remoteSearchCache[normalizedQuery] = remoteMatches;
          if (remoteMatches.isNotEmpty) {
            await _localStore.upsertCachedPeople(remoteMatches);
            _cachedPeopleCache = _mergePeople(<PersonEntry>[
              ...cachedPeople,
              ...remoteMatches,
            ]);
          }
        }
      } catch (_) {
        remoteMatches =
            localMatches.where((person) => person.isTwoSpaceUser).toList();
      }
    }

    return PeopleSearchData(
      remoteResults: remoteMatches,
      localResults: localMatches,
      inviteResults: inviteMatches,
    );
  }

  Future<void> toggleFavorite(PersonEntry person) async {
    final favorites = await _readFavorites();
    if (favorites.contains(person.id)) {
      favorites.remove(person.id);
    } else {
      favorites.add(person.id);
    }
    await _localStore.writeFavorites(favorites);
    _favoritesCache = favorites;
    await _localStore.upsertCachedPeople(<PersonEntry>[
      person.copyWith(isFavorite: favorites.contains(person.id)),
    ]);
    _cachedPeopleCache = _mergePeople(<PersonEntry>[
      ...?_cachedPeopleCache,
      person.copyWith(isFavorite: favorites.contains(person.id)),
    ]);
  }

  Future<void> rememberPerson(PersonEntry person) async {
    final normalized = person.copyWith(
      lastInteractionAt: DateTime.now(),
      clearPhotoBytes: true,
    );
    await _localStore.putRecentPerson(normalized);
    await _localStore.upsertCachedPeople(<PersonEntry>[normalized]);
    _recentPeopleCache = _mergePeople(<PersonEntry>[
      normalized,
      ...?_recentPeopleCache,
    ]);
    _cachedPeopleCache = _mergePeople(<PersonEntry>[
      normalized,
      ...?_cachedPeopleCache,
    ]);
  }

  Future<DeviceContactsResult> loadDeviceContacts({
    bool requestPermission = true,
  }) async {
    // permission_handler and flutter_contacts only work on Android/iOS
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return const DeviceContactsResult(
        permission: DeviceContactsPermission.denied,
        contacts: <PersonEntry>[],
      );
    }

    if (_deviceContactsCache != null &&
        (!requestPermission ||
            _deviceContactsCache!.permission ==
                DeviceContactsPermission.granted)) {
      return _deviceContactsCache!;
    }

    final status = await Permission.contacts.status;

    if (status.isGranted) {
      final result = DeviceContactsResult(
        permission: DeviceContactsPermission.granted,
        contacts: await _fetchDeviceContacts(),
      );
      _deviceContactsCache = result;
      return result;
    }

    if (status.isPermanentlyDenied) {
      return const DeviceContactsResult(
        permission: DeviceContactsPermission.permanentlyDenied,
        contacts: <PersonEntry>[],
      );
    }

    if (!requestPermission) {
      return const DeviceContactsResult(
        permission: DeviceContactsPermission.denied,
        contacts: <PersonEntry>[],
      );
    }

    final result = await Permission.contacts.request();
    if (result.isGranted) {
      final grantedResult = DeviceContactsResult(
        permission: DeviceContactsPermission.granted,
        contacts: await _fetchDeviceContacts(),
      );
      _deviceContactsCache = grantedResult;
      return grantedResult;
    }

    if (result.isPermanentlyDenied) {
      const permanentlyDeniedResult = DeviceContactsResult(
        permission: DeviceContactsPermission.permanentlyDenied,
        contacts: <PersonEntry>[],
      );
      _deviceContactsCache = permanentlyDeniedResult;
      return permanentlyDeniedResult;
    }

    const deniedResult = DeviceContactsResult(
      permission: DeviceContactsPermission.denied,
      contacts: <PersonEntry>[],
    );
    _deviceContactsCache = deniedResult;
    return deniedResult;
  }

  Future<List<PersonEntry>> _fetchDeviceContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      final cachedPeople = await _readCachedPeople();
      final cachedByPhone = <String, PersonEntry>{};
      for (final person in cachedPeople.where((item) => item.isTwoSpaceUser)) {
        for (final phone in person.phones) {
          cachedByPhone[_normalizePhone(phone)] = person;
        }
      }

      return contacts.map((contact) {
        final phones = contact.phones
            .map((phone) => phone.number.trim())
            .where((phone) => phone.isNotEmpty)
            .toSet()
            .toList();
        final matchedRemote = phones
            .map((phone) => cachedByPhone[_normalizePhone(phone)])
            .whereType<PersonEntry>()
            .cast<PersonEntry?>()
            .firstWhere((value) => value != null, orElse: () => null);

        return PersonEntry(
          id: _devicePersonId(contact, phones),
            displayName: contact.displayName.isNotEmpty
              ? contact.displayName
              : 'Unknown',
          phones: phones,
          photoBytes: _photoBytes(contact),
          isDeviceContact: true,
          isTwoSpaceUser: matchedRemote != null,
          remoteUserId: matchedRemote?.remoteUserId,
          username: matchedRemote?.username,
          avatarUrl: matchedRemote?.avatarUrl,
          isOnline: matchedRemote?.isOnline ?? false,
          lastSeenAt: matchedRemote?.lastSeenAt,
          note: matchedRemote != null ? 'twospace' : null,
        );
      }).toList()
        ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    } catch (_) {
      return <PersonEntry>[];
    }
  }

  List<PersonEntry> _topFrequentPeople(List<CallHistoryEntry> history) {
    final counts = <String, int>{};
    final latest = <String, PersonEntry>{};

    for (final entry in history) {
      counts.update(entry.person.id, (value) => value + 1, ifAbsent: () => 1);
      latest[entry.person.id] = entry.person.copyWith(
        lastInteractionAt: entry.startedAt,
      );
    }

    final people = latest.values.toList()
      ..sort((a, b) {
        final countCompare = (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
        if (countCompare != 0) return countCompare;
        return (b.lastInteractionAt ?? DateTime(1970))
            .compareTo(a.lastInteractionAt ?? DateTime(1970));
      });

    return people.take(8).toList();
  }

  PersonEntry _personFromSearchMap(Map<String, dynamic> data) {
    final prefs = (data['prefs'] is Map)
        ? Map<String, dynamic>.from(data['prefs'] as Map<dynamic, dynamic>)
        : <String, dynamic>{};
    final nickname = data['nickname']?.toString();
    final rawName = data['name']?.toString();
    final displayName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (nickname != null && nickname.isNotEmpty)
            ? '@$nickname'
            : data['email']?.toString() ?? 'User';
    final remoteId = (data[r'$id'] ?? data['id'])?.toString() ?? displayName;
    final phone = data['phone']?.toString() ?? prefs['phone']?.toString();

    return PersonEntry(
      id: 'remote_$remoteId',
      displayName: displayName,
      username: nickname,
      avatarUrl: prefs['avatarUrl']?.toString() ?? data['avatar']?.toString(),
      phones: phone == null || phone.isEmpty ? const <String>[] : <String>[phone],
      remoteUserId: remoteId,
      isTwoSpaceUser: true,
      isOnline: (data['presenceStatus'] ?? prefs['presenceStatus']) == 'online' ||
          prefs['online'] == true,
      presenceStatus:
          (data['presenceStatus'] ?? prefs['presenceStatus'])?.toString(),
      lastSeenAt: DateTime.tryParse(
        (data['lastSeenAt'] ??
                data['lastSeen'] ??
                prefs['lastSeenAt'] ??
                prefs['lastSeen'] ??
                '')
            .toString(),
      ),
    );
  }

  List<PersonEntry> _applyFavoriteIds(
    List<PersonEntry> people,
    List<String> favorites,
  ) {
    return people
        .map(
          (person) => person.copyWith(isFavorite: favorites.contains(person.id)),
        )
        .toList();
  }

  List<PersonEntry> _mergePeople(List<PersonEntry> source) {
    final merged = <String, PersonEntry>{};

    for (final person in source.where((value) => value.id.isNotEmpty)) {
      final current = merged[person.id];
      if (current == null) {
        merged[person.id] = person;
        continue;
      }

      merged[person.id] = current.copyWith(
        displayName: person.displayName.isNotEmpty
            ? person.displayName
            : current.displayName,
        username: person.username ?? current.username,
        avatarUrl: person.avatarUrl ?? current.avatarUrl,
        photoBytes: person.photoBytes ?? current.photoBytes,
        phones: <String>{...current.phones, ...person.phones}.toList(),
        remoteUserId: person.remoteUserId ?? current.remoteUserId,
        isTwoSpaceUser: current.isTwoSpaceUser || person.isTwoSpaceUser,
        isDeviceContact: current.isDeviceContact || person.isDeviceContact,
        isFavorite: current.isFavorite || person.isFavorite,
        isOnline: current.isOnline || person.isOnline,
        presenceStatus: person.presenceStatus ?? current.presenceStatus,
        lastSeenAt: _latestDate(current.lastSeenAt, person.lastSeenAt),
        lastInteractionAt:
            _latestDate(current.lastInteractionAt, person.lastInteractionAt),
        note: person.note ?? current.note,
      );
    }

    return merged.values.toList();
  }

  List<PersonEntry> _sortPeople(List<PersonEntry> source) {
    final items = source.toList()
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
        final bTime = b.lastInteractionAt ?? b.lastSeenAt;
        final aTime = a.lastInteractionAt ?? a.lastSeenAt;
        if (aTime != null || bTime != null) {
          return (bTime ?? DateTime(1970)).compareTo(aTime ?? DateTime(1970));
        }
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });
    return items;
  }

  bool _matchesQuery(PersonEntry person, String query) {
    final haystacks = <String>[
      person.displayName,
      if (person.username != null) person.username!,
      ...person.phones,
    ].map((value) => value.toLowerCase());
    return haystacks.any((value) => value.contains(query));
  }

  String _normalizePhone(String raw) {
    final trimmed = raw.trim();
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp('[^0-9]'), '');
    return hasPlus ? '+$digits' : digits;
  }

  String _devicePersonId(Contact contact, List<String> phones) {
    final signature = phones.isNotEmpty
        ? phones.map(_normalizePhone).join('_')
        : contact.displayName.trim().toLowerCase().replaceAll(' ', '_');
    return 'device_$signature';
  }

  Uint8List? _photoBytes(Contact contact) {
    final bytes = contact.photoOrThumbnail;
    if (bytes == null || bytes.isEmpty) return null;
    return bytes;
  }

  DateTime? _latestDate(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  Future<List<String>> _readFavorites() async {
    return _favoritesCache ??= await _localStore.readFavorites();
  }

  Future<List<PersonEntry>> _readCachedPeople() async {
    return _cachedPeopleCache ??= await _localStore.readCachedPeople();
  }

  Future<List<PersonEntry>> _readRecentPeople() async {
    return _recentPeopleCache ??= await _localStore.readRecentPeople();
  }

  void clearVolatileCaches() {
    _deviceContactsCache = null;
    _remoteSearchCache.clear();
  }
}
