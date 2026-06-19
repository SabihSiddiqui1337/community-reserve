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
  if (auth.value == null) return OnboardingStage.signedOut;

  final memberships = ref.watch(userMembershipsProvider);
  if (memberships.isLoading && !memberships.hasValue) {
    return OnboardingStage.loading;
  }
  final list = memberships.value ?? const [];
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
