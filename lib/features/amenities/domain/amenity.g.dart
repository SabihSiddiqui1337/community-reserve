// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amenity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AmenityPricing _$AmenityPricingFromJson(Map<String, dynamic> json) =>
    _AmenityPricing(
      isPaid: json['isPaid'] as bool? ?? false,
      amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      depositCents: (json['depositCents'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AmenityPricingToJson(_AmenityPricing instance) =>
    <String, dynamic>{
      'isPaid': instance.isPaid,
      'amountCents': instance.amountCents,
      'currency': instance.currency,
      'depositCents': instance.depositCents,
    };

_Amenity _$AmenityFromJson(Map<String, dynamic> json) => _Amenity(
  id: json['id'] as String,
  type: json['type'] as String? ?? 'generic',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
  status:
      $enumDecodeNullable(_$AmenityStatusEnumMap, json['status']) ??
      AmenityStatus.active,
  slotMinutes: (json['slotMinutes'] as num?)?.toInt() ?? 60,
  bufferMinutes: (json['bufferMinutes'] as num?)?.toInt() ?? 0,
  capacity: (json['capacity'] as num?)?.toInt() ?? 1,
  requiresPin: json['requiresPin'] as bool? ?? true,
  openHour: (json['openHour'] as num?)?.toInt() ?? 6,
  closeHour: (json['closeHour'] as num?)?.toInt() ?? 22,
  pricing: json['pricing'] == null
      ? const AmenityPricing()
      : AmenityPricing.fromJson(json['pricing'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AmenityToJson(_Amenity instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'description': instance.description,
  'photoUrl': instance.photoUrl,
  'status': _$AmenityStatusEnumMap[instance.status]!,
  'slotMinutes': instance.slotMinutes,
  'bufferMinutes': instance.bufferMinutes,
  'capacity': instance.capacity,
  'requiresPin': instance.requiresPin,
  'openHour': instance.openHour,
  'closeHour': instance.closeHour,
  'pricing': instance.pricing,
};

const _$AmenityStatusEnumMap = {
  AmenityStatus.active: 'active',
  AmenityStatus.comingSoon: 'comingSoon',
  AmenityStatus.maintenance: 'maintenance',
};
