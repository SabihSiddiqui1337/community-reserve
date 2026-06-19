import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../domain/app_user.dart';

/// Drives the sign-in / sign-up forms. State is the async status of the last
/// submission so screens can show spinners and surface errors.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(email.trim(), password);
    });
    return !state.hasError;
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred =
          await ref.read(authRepositoryProvider).signUp(email.trim(), password);
      final uid = cred.user!.uid;
      await ref.read(userRepositoryProvider).ensureProfile(
            AppUser(uid: uid, name: name.trim(), email: email.trim()),
          );
    });
    return !state.hasError;
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
