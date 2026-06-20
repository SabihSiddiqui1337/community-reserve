// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    _PaymentMethod(
      id: json['id'] as String,
      brand: json['brand'] as String? ?? 'Card',
      last4: json['last4'] as String? ?? '0000',
    );

Map<String, dynamic> _$PaymentMethodToJson(_PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'last4': instance.last4,
    };
