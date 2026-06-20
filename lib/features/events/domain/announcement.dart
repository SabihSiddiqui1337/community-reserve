import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

/// A community announcement / event post (`communities/{cid}/announcements/{id}`).
/// Shown on the Events tab; admins create them.
@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    @Default('') String title,
    @Default('') String body,
    @Default('') String authorName,
    @Default('announcement') String type, // announcement | event
    @TimestampConverter() DateTime? createdAt,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
