// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunitySummary _$CommunitySummaryFromJson(Map<String, dynamic> json) =>
    _CommunitySummary(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      joinCode: json['joinCode'] as String? ?? '',
      primaryColor: json['primaryColor'] as String? ?? '#5B8DEF',
    );

Map<String, dynamic> _$CommunitySummaryToJson(_CommunitySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'logoUrl': instance.logoUrl,
      'joinCode': instance.joinCode,
      'primaryColor': instance.primaryColor,
    };
