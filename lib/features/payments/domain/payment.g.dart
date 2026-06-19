// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  userId: json['userId'] as String,
  reservationId: json['reservationId'] as String?,
  amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
  currency: json['currency'] as String? ?? 'USD',
  status:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
      PaymentStatus.pending,
  provider: json['provider'] as String? ?? 'stripe',
  providerRef: json['providerRef'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'reservationId': instance.reservationId,
  'amountCents': instance.amountCents,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'provider': instance.provider,
  'providerRef': instance.providerRef,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.succeeded: 'succeeded',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.failed: 'failed',
};
