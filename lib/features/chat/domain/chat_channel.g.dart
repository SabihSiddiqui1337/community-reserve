// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatChannel _$ChatChannelFromJson(Map<String, dynamic> json) => _ChatChannel(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  isGeneral: json['isGeneral'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  lastAt: const TimestampConverter().fromJson(json['lastAt']),
);

Map<String, dynamic> _$ChatChannelToJson(_ChatChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isGeneral': instance.isGeneral,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'lastAt': const TimestampConverter().toJson(instance.lastAt),
    };
