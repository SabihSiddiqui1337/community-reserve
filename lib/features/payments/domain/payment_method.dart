import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

/// A saved card on file (demo — last 4 only, no real card data).
@freezed
abstract class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    @Default('Card') String brand, // Visa | Mastercard | Discover | Amex | Card
    @Default('0000') String last4,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}
