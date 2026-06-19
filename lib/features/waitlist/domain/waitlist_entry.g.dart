// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WaitlistEntry _$WaitlistEntryFromJson(Map<String, dynamic> json) =>
    _WaitlistEntry(
      id: json['id'] as String,
      amenityId: json['amenityId'] as String,
      userId: json['userId'] as String,
      desiredStart: const TimestampConverter().fromJson(json['desiredStart']),
      desiredEnd: const TimestampConverter().fromJson(json['desiredEnd']),
      status:
          $enumDecodeNullable(_$WaitlistStatusEnumMap, json['status']) ??
          WaitlistStatus.waiting,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$WaitlistEntryToJson(_WaitlistEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amenityId': instance.amenityId,
      'userId': instance.userId,
      'desiredStart': const TimestampConverter().toJson(instance.desiredStart),
      'desiredEnd': const TimestampConverter().toJson(instance.desiredEnd),
      'status': _$WaitlistStatusEnumMap[instance.status]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$WaitlistStatusEnumMap = {
  WaitlistStatus.waiting: 'waiting',
  WaitlistStatus.notified: 'notified',
  WaitlistStatus.fulfilled: 'fulfilled',
  WaitlistStatus.expired: 'expired',
};
