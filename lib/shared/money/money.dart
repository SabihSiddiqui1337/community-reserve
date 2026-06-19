import 'package:intl/intl.dart';

/// All money is stored and passed around as integer minor units (cents) to
/// avoid floating-point drift. Formatting for display happens only here.
class Money {
  const Money._();

  /// Format `amountCents` (e.g. 1500) as a currency string (e.g. `$15.00`).
  static String format(int amountCents, {String currency = 'USD'}) {
    final fmt = NumberFormat.simpleCurrency(name: currency);
    return fmt.format(amountCents / 100);
  }
}
