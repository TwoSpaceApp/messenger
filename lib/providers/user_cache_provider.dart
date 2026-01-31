import 'dart:collection';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/matrix/matrix_profile_service.dart';
import 'service_providers.dart';

/// LRU cache implementation for user profiles
class UserProfileCache {
  final int capacity;
  final Map<String, Map<String, dynamic>> _cache;
  final Queue<String> _queue;

  UserProfileCache({this.capacity = 100})
      : _cache = {},
        _queue = Queue();

  /// Get a profile from the cache
  Map<String, dynamic>? get(String userId) {
    if (_cache.containsKey(userId)) {
      // Move to front to mark as recently used
      _queue.remove(userId);
      _queue.addFirst(userId);
      return _cache[userId];
    }
    return null;
  }

  /// Add or update a profile in the cache
  void set(String userId, Map<String, dynamic> profile) {
    if (_cache.length >= capacity) {
      final lru = _queue.removeLast();
      _cache.remove(lru);
    }
    _cache[userId] = profile;
    _queue.addFirst(userId);
  }

  /// Clear the entire cache
  void clear() {
    _cache.clear();
    _queue.clear();
  }
}

/// Provider for the user profile cache
final userCacheProvider = Provider<UserProfileCache>((ref) {
  final cache = UserProfileCache();
  
  // Clear cache when profile service is disposed (e.g., on logout)
  ref.onDispose(() {
    ref.read(matrixProfileServiceProvider).clearCache();
    cache.clear();
  });
  
  return cache;
});

/// Cached user profile provider with automatic cache management
final cachedUserProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final cache = ref.watch(userCacheProvider);
    final profileService = ref.watch(matrixProfileServiceProvider);

    // Try to get from cache first
    final cachedProfile = cache.get(userId);
    if (cachedProfile != null) {
      return cachedProfile;
    }

    // Otherwise, fetch from the service
    final profile = await profileService.getUserProfile(userId);
    cache.set(userId, profile);
    
    // Keep alive for 5 minutes
    ref.keepAlive();

    return profile;
  },
);

/// Batch user profiles provider with optimized concurrent fetching
final batchUserProfilesProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, List<String>>(
  (ref, userIds) async {
    final cache = ref.watch(userCacheProvider);
    final profileService = ref.watch(matrixProfileServiceProvider);
    
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

    final fetchedProfiles = await profileService.getUsersByIds(idsToFetch);
    for (final profile in fetchedProfiles) {
      cache.set(profile['id'], profile);
    }
    
    // Keep alive for 5 minutes
    ref.keepAlive();

    return [...cachedProfiles, ...fetchedProfiles];
  },
);

extension AutoDisposeRefExtension on AutoDisposeRef {
  void keepAlive() {
    final timer = Timer(const Duration(minutes: 5), () {
      invalidateSelf();
    });
    onDispose(() => timer.cancel());
  }
}
