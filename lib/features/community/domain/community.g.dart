// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Branding _$BrandingFromJson(Map<String, dynamic> json) => _Branding(
  logoUrl: json['logoUrl'] as String?,
  primaryColor: json['primaryColor'] as String? ?? '#FFFFFF',
  accentColor: json['accentColor'] as String? ?? '#C7CBD1',
  backgroundUrl: json['backgroundUrl'] as String?,
  theme: json['theme'] as String? ?? 'dark',
);

Map<String, dynamic> _$BrandingToJson(_Branding instance) => <String, dynamic>{
  'logoUrl': instance.logoUrl,
  'primaryColor': instance.primaryColor,
  'accentColor': instance.accentColor,
  'backgroundUrl': instance.backgroundUrl,
  'theme': instance.theme,
};

_CommunitySettings _$CommunitySettingsFromJson(Map<String, dynamic> json) =>
    _CommunitySettings(
      maxBookingHoursPerWeek:
          (json['maxBookingHoursPerWeek'] as num?)?.toInt() ?? 3,
      advanceBookingDays: (json['advanceBookingDays'] as num?)?.toInt() ?? 7,
      maxActiveReservationsPerUser:
          (json['maxActiveReservationsPerUser'] as num?)?.toInt() ?? 2,
      checkInGraceMinutes: (json['checkInGraceMinutes'] as num?)?.toInt() ?? 15,
      noShowThreshold: (json['noShowThreshold'] as num?)?.toInt() ?? 3,
      noShowBanDays: (json['noShowBanDays'] as num?)?.toInt() ?? 30,
      cancellationCutoffMinutes:
          (json['cancellationCutoffMinutes'] as num?)?.toInt() ?? 60,
      cancellationAllowance:
          (json['cancellationAllowance'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$CommunitySettingsToJson(_CommunitySettings instance) =>
    <String, dynamic>{
      'maxBookingHoursPerWeek': instance.maxBookingHoursPerWeek,
      'advanceBookingDays': instance.advanceBookingDays,
      'maxActiveReservationsPerUser': instance.maxActiveReservationsPerUser,
      'checkInGraceMinutes': instance.checkInGraceMinutes,
      'noShowThreshold': instance.noShowThreshold,
      'noShowBanDays': instance.noShowBanDays,
      'cancellationCutoffMinutes': instance.cancellationCutoffMinutes,
      'cancellationAllowance': instance.cancellationAllowance,
    };

_FeatureFlags _$FeatureFlagsFromJson(Map<String, dynamic> json) =>
    _FeatureFlags(
      paymentsEnabled: json['paymentsEnabled'] as bool? ?? false,
      gymEnabled: json['gymEnabled'] as bool? ?? false,
      waitlistEnabled: json['waitlistEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$FeatureFlagsToJson(_FeatureFlags instance) =>
    <String, dynamic>{
      'paymentsEnabled': instance.paymentsEnabled,
      'gymEnabled': instance.gymEnabled,
      'waitlistEnabled': instance.waitlistEnabled,
    };

_Community _$CommunityFromJson(Map<String, dynamic> json) => _Community(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String? ?? '',
  timezone: json['timezone'] as String? ?? 'America/New_York',
  branding: json['branding'] == null
      ? const Branding()
      : Branding.fromJson(json['branding'] as Map<String, dynamic>),
  settings: json['settings'] == null
      ? const CommunitySettings()
      : CommunitySettings.fromJson(json['settings'] as Map<String, dynamic>),
  featureFlags: json['featureFlags'] == null
      ? const FeatureFlags()
      : FeatureFlags.fromJson(json['featureFlags'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommunityToJson(_Community instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'timezone': instance.timezone,
      'branding': instance.branding,
      'settings': instance.settings,
      'featureFlags': instance.featureFlags,
    };
