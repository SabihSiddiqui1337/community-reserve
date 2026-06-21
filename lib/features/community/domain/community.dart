import 'package:freezed_annotation/freezed_annotation.dart';

part 'community.freezed.dart';
part 'community.g.dart';

/// Visual identity for a tenant. Drives the runtime theme — see [AppTheme].
/// Colors are stored as `#RRGGBB` hex strings so they round-trip cleanly
/// through Firestore without a custom converter.
@freezed
abstract class Branding with _$Branding {
  const factory Branding({
    String? logoUrl,
    @Default('#FFFFFF') String primaryColor, // white (mono B&W)
    @Default('#C7CBD1') String accentColor, // soft grey
    String? backgroundUrl,
    @Default('dark') String theme, // 'dark' | 'light'
  }) = _Branding;

  factory Branding.fromJson(Map<String, dynamic> json) =>
      _$BrandingFromJson(json);
}

/// Booking rules for a community. Every value here is admin-editable and is
/// read at runtime — nothing community-specific is hardcoded in the app.
/// Cloud Functions enforce these server-side (see PROJECT-BRIEF §4).
@freezed
abstract class CommunitySettings with _$CommunitySettings {
  const factory CommunitySettings({
    @Default(3) int maxBookingHoursPerWeek,
    @Default(7) int advanceBookingDays,
    @Default(2) int maxActiveReservationsPerUser,
    @Default(15) int checkInGraceMinutes,
    @Default(3) int noShowThreshold,
    @Default(30) int noShowBanDays,
    @Default(60) int cancellationCutoffMinutes,
  }) = _CommunitySettings;

  factory CommunitySettings.fromJson(Map<String, dynamic> json) =>
      _$CommunitySettingsFromJson(json);
}

/// Per-tenant feature toggles. Gym/payments etc. light up per community.
@freezed
abstract class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    @Default(false) bool paymentsEnabled,
    @Default(false) bool gymEnabled,
    @Default(true) bool waitlistEnabled,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}

/// A tenant. Root of multi-tenant isolation — every other record is scoped
/// under `communities/{id}/...`.
@freezed
abstract class Community with _$Community {
  const factory Community({
    required String id,
    required String name,
    @Default('') String address,
    @Default('America/New_York') String timezone,
    @Default(Branding()) Branding branding,
    @Default(CommunitySettings()) CommunitySettings settings,
    @Default(FeatureFlags()) FeatureFlags featureFlags,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  /// Offline fallback so the app renders branded UI even before the
  /// emulator/seed is running. Mirrors the seeded demo community.
  factory Community.demo() => const Community(
        id: 'demo-hoa',
        name: 'Maple Grove HOA',
        address: '100 Maplewood Dr, Austin, TX',
        timezone: 'America/Chicago',
        branding: Branding(
          primaryColor: '#FFFFFF',
          accentColor: '#C7CBD1',
          theme: 'dark',
        ),
        featureFlags: FeatureFlags(waitlistEnabled: true),
      );
}
