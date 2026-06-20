import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../domain/payment_method.dart';

/// Bottom sheet to select / edit / add / remove saved cards (IMG 1516/1517).
class PaymentMethodsSheet extends ConsumerStatefulWidget {
  const PaymentMethodsSheet({super.key});

  @override
  ConsumerState<PaymentMethodsSheet> createState() =>
      _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends ConsumerState<PaymentMethodsSheet> {
  bool _editing = false;

  String get _uid => ref.read(currentUidProvider)!;

  Future<void> _select(PaymentMethod card) async {
    await ref.read(userRepositoryProvider).selectCard(_uid, card.id);
  }

  Future<void> _remove(List<PaymentMethod> cards, PaymentMethod card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _RemoveDialog(card: card),
    );
    if (ok != true) return;
    final remaining = cards.where((c) => c.id != card.id).toList();
    await ref.read(userRepositoryProvider).setPaymentMethods(
          _uid,
          remaining,
          selectedId: remaining.isNotEmpty ? remaining.first.id : '',
        );
  }

  Future<void> _add(List<PaymentMethod> cards) async {
    final card = await showDialog<PaymentMethod>(
      context: context,
      builder: (_) => const _AddCardDialog(),
    );
    if (card == null) return;
    await ref.read(userRepositoryProvider).setPaymentMethods(
          _uid,
          [...cards, card],
          selectedId: card.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final cards = user?.paymentMethods ?? const <PaymentMethod>[];
    final selectedId = user?.selectedCardId ??
        (cards.isNotEmpty ? cards.first.id : null);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  child: Text(_editing ? 'Done' : 'Edit'),
                ),
              ],
            ),
            Text('Select payment method', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No cards yet.',
                    style: theme.textTheme.bodyMedium),
              ),
            ...cards.map((c) => _CardTile(
                  card: c,
                  editing: _editing,
                  selected: c.id == selectedId,
                  onSelect: () => _select(c),
                  onDelete: () => _remove(cards, c),
                )),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => _add(cards),
                icon: const Icon(Icons.add),
                label: const Text('Add payment method'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _editing ? null : () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.editing,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
  });
  final PaymentMethod card;
  final bool editing;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = editing
        ? theme.colorScheme.error
        : selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: editing ? null : onSelect,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text('${card.brand}  •••• ${card.last4}',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                if (editing)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                    onPressed: onDelete,
                  )
                else
                  Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveDialog extends StatelessWidget {
  const _RemoveDialog({required this.card});
  final PaymentMethod card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Remove payment method?'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.credit_card),
          const SizedBox(width: 10),
          Text('${card.brand}  •••• ${card.last4}',
              style: theme.textTheme.titleMedium),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog();
  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _last4 = TextEditingController();
  String _brand = 'Visa';

  @override
  void dispose() {
    _last4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add payment method'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _brand,
            decoration: const InputDecoration(labelText: 'Card type'),
            items: const ['Visa', 'Mastercard', 'Discover', 'Amex', 'Card']
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _brand = v ?? 'Card'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _last4,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
                labelText: 'Last 4 digits', hintText: '4242', counterText: ''),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final last4 = _last4.text.trim();
            if (last4.length != 4) return;
            Navigator.pop(
              context,
              PaymentMethod(
                id: 'card_${DateTime.now().microsecondsSinceEpoch}',
                brand: _brand,
                last4: last4,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
