// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  userId: json['userId'] as String,
  role:
      $enumDecodeNullable(_$MemberRoleEnumMap, json['role']) ??
      MemberRole.resident,
  residencyStatus:
      $enumDecodeNullable(_$ResidencyStatusEnumMap, json['residencyStatus']) ??
      ResidencyStatus.pending,
  verificationDocUrl: json['verificationDocUrl'] as String?,
  unit: json['unit'] as String? ?? '',
  address: json['address'] as String? ?? '',
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: const TimestampConverter().fromJson(json['reviewedAt']),
  rejectionReason: json['rejectionReason'] as String?,
  noShowCount: (json['noShowCount'] as num?)?.toInt() ?? 0,
  cancellationCount: (json['cancellationCount'] as num?)?.toInt() ?? 0,
  bannedUntil: const TimestampConverter().fromJson(json['bannedUntil']),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'residencyStatus': _$ResidencyStatusEnumMap[instance.residencyStatus]!,
      'verificationDocUrl': instance.verificationDocUrl,
      'unit': instance.unit,
      'address': instance.address,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': const TimestampConverter().toJson(instance.reviewedAt),
      'rejectionReason': instance.rejectionReason,
      'noShowCount': instance.noShowCount,
      'cancellationCount': instance.cancellationCount,
      'bannedUntil': const TimestampConverter().toJson(instance.bannedUntil),
    };

const _$MemberRoleEnumMap = {
  MemberRole.resident: 'resident',
  MemberRole.admin: 'admin',
};

const _$ResidencyStatusEnumMap = {
  ResidencyStatus.pending: 'pending',
  ResidencyStatus.verified: 'verified',
  ResidencyStatus.rejected: 'rejected',
};
