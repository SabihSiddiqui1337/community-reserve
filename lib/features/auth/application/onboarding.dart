import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';
import '../data/auth_repository.dart';

/// The user's position in the onboarding funnel. The router maps each stage to
/// a destination so users can't skip ahead (e.g. book before being verified).
enum OnboardingStage {
  loading,
  signedOut,
  needsCommunity,
  needsResidency,
  pendingReview,
  rejected,
  ready,
}

final onboardingStageProvider = Provider<OnboardingStage>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return OnboardingStage.loading;
  // The auth stream can momentarily emit null on cold start before the
  // persisted session is restored; fall back to the synchronous currentUser so
  // we show the splash instead of flashing the sign-in screen.
  final user = auth.value ?? ref.read(authRepositoryProvider).currentUser;
  if (user == null) return OnboardingStage.signedOut;

  // On sign-in the membership stream re-queries for the new user. Until it has
  // emitted data tagged with THIS user's uid, treat it as loading — otherwise a
  // stale signed-out empty list (or the prior user's) would route to "find your
  // community" for a split second. Tagging by uid is race-proof regardless of
  // Riverpod's sibling update ordering.
  final data = ref.watch(userMembershipsProvider).value;
  if (data == null || data.uid != user.uid) {
    return OnboardingStage.loading;
  }
  final list = data.records;
  if (list.isEmpty) return OnboardingStage.needsCommunity;

  final m = list.first.membership;
  return switch (m.residencyStatus) {
    ResidencyStatus.verified => OnboardingStage.ready,
    ResidencyStatus.rejected => OnboardingStage.rejected,
    ResidencyStatus.pending => m.verificationDocUrl == null
        ? OnboardingStage.needsResidency
        : OnboardingStage.pendingReview,
  };
});
