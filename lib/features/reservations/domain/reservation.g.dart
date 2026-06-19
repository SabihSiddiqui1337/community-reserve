// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  id: json['id'] as String,
  amenityId: json['amenityId'] as String,
  userId: json['userId'] as String,
  startTime: const TimestampConverter().fromJson(json['startTime']),
  endTime: const TimestampConverter().fromJson(json['endTime']),
  status:
      $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']) ??
      ReservationStatus.booked,
  pinHash: json['pinHash'] as String?,
  salt: json['salt'] as String?,
  qrToken: json['qrToken'] as String?,
  accessCredentialId: json['accessCredentialId'] as String?,
  checkedInAt: const TimestampConverter().fromJson(json['checkedInAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  cancelledAt: const TimestampConverter().fromJson(json['cancelledAt']),
  paymentId: json['paymentId'] as String?,
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amenityId': instance.amenityId,
      'userId': instance.userId,
      'startTime': const TimestampConverter().toJson(instance.startTime),
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'pinHash': instance.pinHash,
      'salt': instance.salt,
      'qrToken': instance.qrToken,
      'accessCredentialId': instance.accessCredentialId,
      'checkedInAt': const TimestampConverter().toJson(instance.checkedInAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'cancelledAt': const TimestampConverter().toJson(instance.cancelledAt),
      'paymentId': instance.paymentId,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.booked: 'booked',
  ReservationStatus.checkedIn: 'checkedIn',
  ReservationStatus.completed: 'completed',
  ReservationStatus.noShow: 'noShow',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.expired: 'expired',
};
