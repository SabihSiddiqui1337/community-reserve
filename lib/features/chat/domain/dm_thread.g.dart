// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DmThread _$DmThreadFromJson(Map<String, dynamic> json) => _DmThread(
  id: json['id'] as String,
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  participantNames:
      (json['participantNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  isGroup: json['isGroup'] as bool? ?? false,
  lastText: json['lastText'] as String? ?? '',
  lastAt: const TimestampConverter().fromJson(json['lastAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$DmThreadToJson(_DmThread instance) => <String, dynamic>{
  'id': instance.id,
  'participantIds': instance.participantIds,
  'participantNames': instance.participantNames,
  'isGroup': instance.isGroup,
  'lastText': instance.lastText,
  'lastAt': const TimestampConverter().toJson(instance.lastAt),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
