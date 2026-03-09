import 'package:riverpod/riverpod.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

final currentUserProvider = FutureProvider<String?>((ref) async {
  final auth = AuthService();
  return auth.getCurrentUserId();
});

final authTokenProvider = FutureProvider<String?>((ref) async {
  final auth = AuthService();
  return auth.getMatrixTokenForUser();
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final auth = AuthService();
  final token = await auth.getMatrixTokenForUser();
  return token != null && token.isNotEmpty;
});
