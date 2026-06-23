// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      type: json['type'] as String? ?? 'announcement',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$AnnouncementToJson(_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'authorName': instance.authorName,
      'authorId': instance.authorId,
      'type': instance.type,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
