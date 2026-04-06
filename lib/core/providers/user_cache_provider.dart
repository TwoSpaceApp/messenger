import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/future_provider.dart';
import 'package:two_space_app/core/providers/service_providers.dart';

/// LRU cache implementation for user profiles using LinkedHashMap
/// for O(1) access-order operations.
class UserProfileCache {
  UserProfileCache({this.capacity = 100})
    : _cache = LinkedHashMap<String, Map<String, dynamic>>();
  final int capacity;
  final LinkedHashMap<String, Map<String, dynamic>> _cache;

  /// Get a profile from the cache (O(1) — moves to end for LRU).
  Map<String, dynamic>? get(String userId) {
    final value = _cache.remove(userId);
    if (value != null) {
      _cache[userId] = value; // Re-insert at the end (most recently used).
      return value;
    }
    return null;
  }

  /// Add or update a profile in the cache
  void set(String userId, Map<String, dynamic> profile) {
    _cache.remove(userId); // Remove first so re-insert goes to end.
    if (_cache.length >= capacity) {
      _cache.remove(_cache.keys.first); // Evict least recently used.
    }
    _cache[userId] = profile;
  }

  /// Clear the entire cache
  void clear() {
    _cache.clear();
  }
}

/// Provider for the user profile cache
final userCacheProvider = Provider<UserProfileCache>((ref) {
  final cache = UserProfileCache();

  ref.onDispose(cache.clear);

  return cache;
});

/// Cached user profile provider with automatic cache management
final FutureProviderFamily<Map<String, dynamic>, String>
cachedUserProfileProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, userId) async {
        final cache = ref.watch(userCacheProvider);
        final profileService = ref.watch(aegisChatServiceProvider);

        final cachedProfile = cache.get(userId);
        if (cachedProfile != null) {
          return cachedProfile;
        }

        final profile = await profileService.getUserInfo(userId);
        cache.set(userId, profile);

        final link = ref.keepAlive();
        final timer = Timer(const Duration(minutes: 5), link.close);
        ref.onDispose(timer.cancel);

        return profile;
      },
    );

/// Batch user profiles provider with optimized concurrent fetching
final FutureProviderFamily<List<Map<String, dynamic>>, List<String>>
batchUserProfilesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, List<String>>(
      (ref, userIds) async {
        final cache = ref.watch(userCacheProvider);
        final profileService = ref.watch(aegisChatServiceProvider);

        final uniqueIds = userIds.toSet().toList();
        final cachedProfiles = <Map<String, dynamic>>[];
        final idsToFetch = <String>[];

        for (final id in uniqueIds) {
          final cached = cache.get(id);
          if (cached != null) {
            cachedProfiles.add(cached);
          } else {
            idsToFetch.add(id);
          }
        }

        if (idsToFetch.isEmpty) {
          return cachedProfiles;
        }

        final fetchedProfiles = await Future.wait(
          idsToFetch.map(profileService.getUserInfo),
        );
        for (final profile in fetchedProfiles) {
          final id = profile['id']?.toString();
          if (id != null && id.isNotEmpty) {
            cache.set(id, profile);
          }
        }

        final link = ref.keepAlive();
        final timer = Timer(const Duration(minutes: 5), link.close);
        ref.onDispose(timer.cancel);

        return [...cachedProfiles, ...fetchedProfiles];
      },
    );
