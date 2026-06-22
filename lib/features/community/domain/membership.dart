import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

enum ResidencyStatus { pending, verified, rejected }

enum MemberRole { resident, admin }

/// A user's relationship to one community
/// (`communities/{cid}/memberships/{uid}`). Carries residency approval state,
/// role, and no-show standing.
@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String userId,
    @Default(MemberRole.resident) MemberRole role,
    @Default(ResidencyStatus.pending) ResidencyStatus residencyStatus,
    String? verificationDocUrl,
    @Default('') String unit,
    @Default('') String address,
    String? reviewedBy,
    @TimestampConverter() DateTime? reviewedAt,
    String? rejectionReason,
    @Default(0) int noShowCount,
    @Default(0) int cancellationCount,
    @TimestampConverter() DateTime? bannedUntil,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}

extension MembershipX on Membership {
  bool get isVerified => residencyStatus == ResidencyStatus.verified;
  bool get isAdmin => role == MemberRole.admin;
  bool get isBanned =>
      bannedUntil != null && bannedUntil!.isAfter(DateTime.now());
}
