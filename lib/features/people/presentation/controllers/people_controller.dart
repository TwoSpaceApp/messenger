import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/data/services/people_repository.dart';

class PeopleController extends ChangeNotifier {
  PeopleController({PeopleRepository? repository})
      : _repository = repository ?? PeopleRepository();

  final PeopleRepository _repository;

  PeopleDashboardData? _dashboard;
  PeopleSearchData _searchData = const PeopleSearchData(
    remoteResults: <PersonEntry>[],
    localResults: <PersonEntry>[],
    inviteResults: <PersonEntry>[],
  );
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  String _query = '';
  bool _loading = true;
  bool _searching = false;
  String? _error;
  PeopleSegment _segment = PeopleSegment.all;

  PeopleDashboardData? get dashboard => _dashboard;
  PeopleSearchData get searchData => _searchData;
  String get query => _query;
  bool get loading => _loading;
  bool get searching => _searching;
  String? get error => _error;
  PeopleSegment get segment => _segment;
  bool get isSearchingMode => _query.trim().isNotEmpty;

  Future<void> load({bool requestPermission = true}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _repository.loadDashboard(
        requestPermission: requestPermission,
      );
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _repository.clearVolatileCaches();
    await load();
    if (_query.trim().isNotEmpty) {
      await _performSearch(_query);
    }
  }

  void setSegment(PeopleSegment next) {
    if (_segment == next) return;
    _segment = next;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();

    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 280),
      () => _performSearch(value),
    );
  }

  Future<void> clearSearch() async {
    _query = '';
    _searchDebounce?.cancel();
    _searchData = const PeopleSearchData(
      remoteResults: <PersonEntry>[],
      localResults: <PersonEntry>[],
      inviteResults: <PersonEntry>[],
    );
    notifyListeners();
  }

  Future<void> toggleFavorite(PersonEntry person) async {
    await _repository.toggleFavorite(person);
    await refresh();
  }

  Future<void> rememberPerson(PersonEntry person) async {
    await _repository.rememberPerson(person);
    await load(requestPermission: false);
  }

  Future<void> _performSearch(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _searchRequestId++;
      _searchData = const PeopleSearchData(
        remoteResults: <PersonEntry>[],
        localResults: <PersonEntry>[],
        inviteResults: <PersonEntry>[],
      );
      _error = null;
      notifyListeners();
      return;
    }

    final requestId = ++_searchRequestId;
    _searching = true;
    _searchData = const PeopleSearchData(
      remoteResults: <PersonEntry>[],
      localResults: <PersonEntry>[],
      inviteResults: <PersonEntry>[],
    );
    notifyListeners();
    try {
      final result = await _repository.searchPeople(trimmed);
      if (requestId != _searchRequestId) return;
      _searchData = result;
      _error = null;
    } catch (error) {
      if (requestId != _searchRequestId) return;
      _error = error.toString();
    } finally {
      if (requestId == _searchRequestId) {
        _searching = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
