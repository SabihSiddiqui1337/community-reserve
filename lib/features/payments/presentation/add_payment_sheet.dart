import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/dialogs/confirm.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../domain/payment_method.dart';

/// Shows the "Add your payment information" bottom sheet (card info + billing
/// address). On success it appends the new card to the user's saved methods,
/// marks it selected, and returns it. Returns null if dismissed.
///
/// Demo: only the brand + last 4 digits are persisted (never the full PAN).
Future<PaymentMethod?> showAddPaymentSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final card = await showModalBottomSheet<PaymentMethod>(
    context: context,
    isScrollControlled: true,
    isDismissible: false, // close only via the X (with a discard prompt)
    enableDrag: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const AddPaymentSheet(),
  );
  if (card == null) return null;

  final uid = ref.read(currentUidProvider);
  if (uid == null) return card;
  final existing =
      ref.read(currentUserProvider).value?.paymentMethods ?? const [];
  await ref.read(userRepositoryProvider).setPaymentMethods(
        uid,
        [...existing, card],
        selectedId: card.id,
      );
  return card;
}

/// The "Add your payment information" form. Pops a [PaymentMethod] on Continue.
class AddPaymentSheet extends ConsumerStatefulWidget {
  const AddPaymentSheet({super.key});

  @override
  ConsumerState<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _zip = TextEditingController();
  String _country = 'United States';

  static const _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
  ];

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    _zip.dispose();
    super.dispose();
  }

  /// Map the leading digit to a card brand (demo heuristic).
  String _brandFor(String digits) {
    if (digits.isEmpty) return 'Card';
    return switch (digits[0]) {
      '4' => 'Visa',
      '5' => 'Mastercard',
      '3' => 'Amex',
      '6' => 'Discover',
      _ => 'Card',
    };
  }

  bool get _dirty =>
      _number.text.isNotEmpty ||
      _expiry.text.isNotEmpty ||
      _cvc.text.isNotEmpty ||
      _zip.text.isNotEmpty;

  Future<void> _close() async {
    if (_dirty && !await confirmDiscard(context)) return;
    if (mounted) Navigator.pop(context);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    Navigator.pop(
      context,
      PaymentMethod(
        id: 'card_${DateTime.now().microsecondsSinceEpoch}',
        brand: _brandFor(digits),
        last4: digits.substring(digits.length - 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final community = ref.watch(activeCommunityProvider);
    // Sit above the keyboard when fields are focused.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _close,
                  ),
                ),
                Text('Add your payment information',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Card information',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    const _CardBrands(),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _number,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Card number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 13) return 'Enter a valid card number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiry,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_ExpiryFormatter()],
                        decoration: const InputDecoration(
                          hintText: 'MM / YY',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v ?? '').length < 5 ? 'MM / YY' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvc,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'CVC',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v ?? '').length < 3 ? 'CVC' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Billing address',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _country,
                  decoration: const InputDecoration(
                    labelText: 'Country or region',
                    border: OutlineInputBorder(),
                  ),
                  items: _countries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _country = v ?? _country),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _zip,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'ZIP',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter a ZIP code' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'By providing your card information, you allow ${community.name} '
                  'to charge your card for future payments in accordance with '
                  'their terms.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54)),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Small text badges hinting at the accepted card networks.
class _CardBrands extends StatelessWidget {
  const _CardBrands();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['VISA', 'MC', 'AMEX', 'DISC']
          .map((b) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(b,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }
}

/// Formats numeric input as `MM / YY` while typing.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits =
        newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 4 ? digits.substring(0, 4) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(trimmed[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
