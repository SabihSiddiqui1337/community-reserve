import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../community/application/tenant_providers.dart';
import '../../community/data/membership_repository.dart';
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
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(email.trim(), password);
    });
    if (result.hasError) {
      state = result;
      return false;
    }
    // Success: keep the spinner running. The onboarding redirect swaps this
    // screen for the app once the membership loads, so we never reset to a
    // resting state that would flash the form / splash mid-redirect.
    return true;
  }

  /// Creates the auth account + user profile and, when [communityId] is given,
  /// a pending membership in that community so the onboarding gate advances to
  /// residency. [phone] is stored on the profile when provided.
  Future<bool> signUp(
    String name,
    String email,
    String password, {
    String? communityId,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cred =
          await ref.read(authRepositoryProvider).signUp(email.trim(), password);
      final uid = cred.user!.uid;
      await ref.read(userRepositoryProvider).ensureProfile(
            AppUser(
              uid: uid,
              name: name.trim(),
              email: email.trim(),
              phone: phone?.trim() ?? '',
            ),
          );
      if (communityId != null && communityId.isNotEmpty) {
        // Mirrors the join flow: creates a pending membership (residencyStatus
        // defaults to pending) keyed by uid in the chosen community.
        await ref.read(membershipRepositoryProvider).join(communityId, uid);
      }
    });
    return !state.hasError;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    // Drop the previous user's cached streams so the next sign-in loads fresh
    // instead of resolving on top of stale membership/profile data.
    ref.invalidate(userMembershipsProvider);
    ref.invalidate(currentUserProvider);
    // Re-enable the sign-in button (signIn keeps the spinner on success).
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
