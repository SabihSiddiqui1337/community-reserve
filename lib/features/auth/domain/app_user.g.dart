// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  globalRole: json['globalRole'] as String? ?? 'resident',
  paymentMethods:
      (json['paymentMethods'] as List<dynamic>?)
          ?.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PaymentMethod>[],
  selectedCardId: json['selectedCardId'] as String?,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'photoUrl': instance.photoUrl,
  'fcmTokens': instance.fcmTokens,
  'globalRole': instance.globalRole,
  'paymentMethods': instance.paymentMethods,
  'selectedCardId': instance.selectedCardId,
};
