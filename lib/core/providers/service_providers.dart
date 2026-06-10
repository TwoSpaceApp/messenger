import 'package:flutter_riverpod/flutter_riverpod.dart';
// Needed for FutureProvider type access; no public API alternative
// ignore: implementation_imports
import 'package:riverpod/src/providers/future_provider.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

final aegisChatServiceProvider = Provider<AegisChatService>((ref) {
  return AegisChatService();
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  return AuthService().getCurrentUserId();
});

final FutureProviderFamily<Map<String, dynamic>, String> userInfoProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
      (ref, userId) async {
        final profileService = ref.watch(aegisChatServiceProvider);
        return profileService.getUserInfo(userId);
      },
    );
