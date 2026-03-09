import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

final aegisChatServiceProvider = Provider<AegisChatService>((ref) {
  return AegisChatService();
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  return AuthService().getCurrentUserId();
});

final userInfoProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final profileService = ref.watch(aegisChatServiceProvider);
    ref.keepAlive();
    return profileService.getUserInfo(userId);
  },
);
