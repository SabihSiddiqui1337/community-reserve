import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../domain/payment_method.dart';
import 'add_payment_sheet.dart';
import 'payment_methods_sheet.dart';

/// Full-screen list of saved cards with add / select / remove. Reached from
/// Account → Payment Info; mirrors the checkout "Select payment method" UI.
class PaymentInfoScreen extends ConsumerStatefulWidget {
  const PaymentInfoScreen({super.key});

  @override
  ConsumerState<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends ConsumerState<PaymentInfoScreen> {
  bool _editing = false;
  String? _selectedId; // staged selection; persisted on Save
  bool _loaded = false;

  String get _uid => ref.read(currentUidProvider)!;

  Future<void> _remove(List<PaymentMethod> cards, PaymentMethod card) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RemoveCardDialog(card: card),
    );
    if (ok != true) return;
    final remaining = cards.where((c) => c.id != card.id).toList();
    if (_selectedId == card.id) {
      _selectedId = remaining.isNotEmpty ? remaining.first.id : null;
    }
    await ref.read(userRepositoryProvider).setPaymentMethods(
          _uid,
          remaining,
          selectedId: _selectedId ?? '',
        );
  }

  Future<void> _save() async {
    final id = _selectedId;
    if (id != null) {
      await ref.read(userRepositoryProvider).selectCard(_uid, id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method saved')));
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final cards = user?.paymentMethods ?? const <PaymentMethod>[];

    // Seed the staged selection once from the saved value.
    if (!_loaded && user != null) {
      _selectedId =
          user.selectedCardId ?? (cards.isNotEmpty ? cards.first.id : null);
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Info'),
        centerTitle: true,
        actions: [
          if (cards.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(_editing ? 'Done' : 'Edit'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No cards on file.',
                    style: theme.textTheme.bodyMedium),
              ),
            ),
          ...cards.map((c) => PaymentCardTile(
                card: c,
                editing: _editing,
                selected: c.id == _selectedId,
                onSelect: () => setState(() => _selectedId = c.id),
                onDelete: () => _remove(cards, c),
              )),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => showAddPaymentSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add payment method'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cards.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: _editing ? null : _save,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: const Text('Save'),
                ),
              ),
            ),
    );
  }
}
