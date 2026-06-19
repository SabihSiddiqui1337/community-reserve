import 'package:freezed_annotation/freezed_annotation.dart';

part 'amenity.freezed.dart';
part 'amenity.g.dart';

enum AmenityStatus { active, comingSoon, maintenance }

@freezed
abstract class AmenityPricing with _$AmenityPricing {
  const factory AmenityPricing({
    @Default(false) bool isPaid,
    @Default(0) int amountCents,
    @Default('USD') String currency,
    @Default(0) int depositCents,
  }) = _AmenityPricing;

  factory AmenityPricing.fromJson(Map<String, dynamic> json) =>
      _$AmenityPricingFromJson(json);
}

/// A bookable amenity (`communities/{cid}/amenities/{id}`). Open hours, slot
/// length, capacity and pricing are all admin-editable (PROJECT-BRIEF §6).
@freezed
abstract class Amenity with _$Amenity {
  const factory Amenity({
    required String id,
    @Default('generic') String type,
    @Default('') String name,
    @Default('') String description,
    String? photoUrl,
    @Default(AmenityStatus.active) AmenityStatus status,
    @Default(60) int slotMinutes,
    @Default(0) int bufferMinutes,
    @Default(1) int capacity,
    @Default(true) bool requiresPin,
    @Default(6) int openHour,
    @Default(22) int closeHour,
    @Default(AmenityPricing()) AmenityPricing pricing,
  }) = _Amenity;

  factory Amenity.fromJson(Map<String, dynamic> json) =>
      _$AmenityFromJson(json);
}

extension AmenityX on Amenity {
  bool get isBookable => status == AmenityStatus.active;
}
