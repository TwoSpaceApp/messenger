import 'package:flutter/material.dart';
import 'package:riverpod/src/providers/future_provider.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';

// Global search query notifier
final _searchQueryNotifier = ValueNotifier<String>('');

// Mock list of people for now
final peopleRepositoryProvider = FutureProvider<List<PersonEntry>>((ref) async {
  // Mock data - replace with actual repository calls
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    const PersonEntry(
      id: '1',
      displayName: 'Alice Smith',
      username: 'alice',
      isOnline: true,
    ),
    const PersonEntry(
      id: '2',
      displayName: 'Bob Johnson',
      username: 'bob',
    ),
    const PersonEntry(
      id: '3',
      displayName: 'Charlie Brown',
      username: 'charlie',
      isOnline: true,
    ),
  ];
});

// List of all contacts/people
final peopleListProvider = FutureProvider<List<PersonEntry>>((ref) async {
  return await ref.watch(peopleRepositoryProvider.future);
});

// Filtered people based on search query
final filteredPeopleProvider = FutureProvider<List<PersonEntry>>((ref) async {
  final allPeople = await ref.watch(peopleListProvider.future);
  final query = _searchQueryNotifier.value;

  if (query.isEmpty) {
    return allPeople;
  }

  final lowerQuery = query.toLowerCase();
  return allPeople
      .where(
        (person) =>
            person.displayName.toLowerCase().contains(lowerQuery) ||
            (person.username?.toLowerCase().contains(lowerQuery) ?? false),
      )
      .toList();
});

// Get person by ID
final FutureProviderFamily<PersonEntry?, String> personByIdProvider =
    FutureProvider.family<PersonEntry?, String>((
      ref,
      personId,
    ) async {
      final allPeople = await ref.watch(peopleListProvider.future);
      try {
        return allPeople.firstWhere((p) => p.id == personId);
      } on Object catch (_) {
        return null;
      }
    });

// Getter for search query notifier
ValueNotifier<String> getSearchQueryNotifier() => _searchQueryNotifier;
