import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/matrix/matrix_auth_service.dart';
import 'package:two_space_app/services/matrix/matrix_media_service.dart';
import 'package:two_space_app/services/matrix/matrix_profile_service.dart';
import 'package:two_space_app/services/matrix/matrix_messaging_service.dart';
import 'dart:async';

/// Provider for MatrixAuthService singleton
final matrixAuthServiceProvider = Provider<MatrixAuthService>((ref) {
  return MatrixAuthService();
});

/// Provider for MatrixMediaService singleton
final matrixMediaServiceProvider = Provider<MatrixMediaService>((ref) {
  return MatrixMediaService();
});

/// Provider for MatrixProfileService singleton
final matrixProfileServiceProvider = Provider<MatrixProfileService>((ref) {
  return MatrixProfileService();
});

/// Provider for MatrixMessagingService singleton
final matrixMessagingServiceProvider = Provider<MatrixMessagingService>((ref) {
  return MatrixMessagingService();
});

/// Provider for current user ID
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(matrixAuthServiceProvider);
  if (await authService.isAuthenticated()) {
    return authService.getCurrentUserId();
  }
  return null;
});

/// Provider for user info with family for parameterization
///
/// Example:
/// ```
/// final user = ref.watch(userInfoProvider('user_id'));
/// user.when(
///   data: (info) => Text(info['display_name']),
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => Text('Error: $e'),
/// );
/// ```
final userInfoProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final profileService = ref.watch(matrixProfileServiceProvider);
    
    // Keep the provider alive for 5 minutes
    ref.keepAlive();
    
    return await profileService.getUserInfo(userId);
  },
);
