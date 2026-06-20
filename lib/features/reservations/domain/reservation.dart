import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

enum ReservationStatus {
  booked,
  checkedIn,
  completed,
  noShow,
  cancelled,
  expired,
}

/// A booking (`communities/{cid}/reservations/{id}`). Created and mutated by
/// Cloud Functions; the client reads its own. PIN is stored hashed only.
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String amenityId,
    required String userId,
    @TimestampConverter() DateTime? startTime,
    @TimestampConverter() DateTime? endTime,
    @Default(ReservationStatus.booked) ReservationStatus status,
    int? court, // assigned court number (1-based) for multi-court amenities
    String? pinHash,
    String? salt,
    String? qrToken,
    String? accessCredentialId,
    @TimestampConverter() DateTime? checkedInAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? cancelledAt,
    String? paymentId,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}

extension ReservationX on Reservation {
  bool get isActiveNow {
    final now = DateTime.now();
    return (status == ReservationStatus.booked ||
            status == ReservationStatus.checkedIn) &&
        startTime != null &&
        endTime != null &&
        now.isAfter(startTime!) &&
        now.isBefore(endTime!);
  }

  bool get isUpcoming =>
      (status == ReservationStatus.booked ||
          status == ReservationStatus.checkedIn) &&
      endTime != null &&
      endTime!.isAfter(DateTime.now());
}
