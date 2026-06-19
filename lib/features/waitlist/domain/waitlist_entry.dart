import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'waitlist_entry.freezed.dart';
part 'waitlist_entry.g.dart';

enum WaitlistStatus { waiting, notified, fulfilled, expired }

/// A "notify me when it opens" request (`communities/{cid}/waitlist/{id}`).
@freezed
abstract class WaitlistEntry with _$WaitlistEntry {
  const factory WaitlistEntry({
    required String id,
    required String amenityId,
    required String userId,
    @TimestampConverter() DateTime? desiredStart,
    @TimestampConverter() DateTime? desiredEnd,
    @Default(WaitlistStatus.waiting) WaitlistStatus status,
    @TimestampConverter() DateTime? createdAt,
  }) = _WaitlistEntry;

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) =>
      _$WaitlistEntryFromJson(json);
}
