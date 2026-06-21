import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// In-app inbox item mirroring a push (`communities/{cid}/notifications/{id}`).
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    @Default('') String title,
    @Default('') String body,
    @Default('general') String type,
    @Default(false) bool read,
    // Deep-link target for a notification tap (e.g. '/book/slots/{amenityId}').
    String? route,
    String? amenityId,
    @TimestampConverter() DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
