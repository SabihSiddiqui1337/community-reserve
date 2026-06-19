import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../data/community_repository.dart';
import '../data/membership_repository.dart';
import '../domain/community.dart';
import '../domain/membership.dart';

/// All communities the signed-in user belongs to. Empty until they join.
final userMembershipsProvider = StreamProvider<List<MembershipRecord>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(membershipRepositoryProvider).watchUserMemberships(uid);
});

/// The active tenant id — derived from the user's first membership (MVP single
/// community). Null when signed out or not yet joined.
final currentCommunityIdProvider = Provider<String?>((ref) {
  final list = ref.watch(userMembershipsProvider).value ?? const [];
  return list.isEmpty ? null : list.first.communityId;
});

/// The signed-in user's membership in the active community (role/residency).
final currentMembershipProvider = Provider<Membership?>((ref) {
  final list = ref.watch(userMembershipsProvider).value ?? const [];
  return list.isEmpty ? null : list.first.membership;
});

/// The active [Community], streamed live so branding/settings edits reflect
/// immediately. Falls back to the demo community when not joined, so the
/// onboarding screens are still branded.
final currentCommunityProvider = StreamProvider<Community>((ref) {
  final id = ref.watch(currentCommunityIdProvider);
  if (id == null) return Stream.value(Community.demo());
  return ref.watch(communityRepositoryProvider).watch(id);
});

/// Synchronous best-effort community for theming widgets.
final activeCommunityProvider = Provider<Community>((ref) {
  return ref.watch(currentCommunityProvider).maybeWhen(
        data: (c) => c,
        orElse: Community.demo,
      );
});

/// True when the active membership has admin role.
final isAdminProvider = Provider<bool>((ref) {
  final m = ref.watch(currentMembershipProvider);
  return m?.isAdmin ?? false;
});

/// Admin: all memberships in the active community (members list / approvals).
final allMembershipsProvider = StreamProvider<List<Membership>>((ref) {
  final id = ref.watch(currentCommunityIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(membershipRepositoryProvider).watchAll(id);
});
