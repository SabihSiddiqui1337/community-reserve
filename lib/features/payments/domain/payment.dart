import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/timestamp_converter.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentStatus { pending, succeeded, refunded, failed }

/// A payment record (`communities/{cid}/payments/{id}`). SCAFFOLD: created by a
/// stubbed Cloud Function that auto-succeeds. Real Stripe PaymentIntents swap
/// in later behind the same model.
@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String userId,
    String? reservationId,
    @Default(0) int amountCents,
    @Default('USD') String currency,
    @Default(PaymentStatus.pending) PaymentStatus status,
    @Default('stripe') String provider,
    String? providerRef,
    @TimestampConverter() DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
