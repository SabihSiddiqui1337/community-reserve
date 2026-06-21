import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/dialogs/confirm.dart';
import '../../../amenities/data/amenity_repository.dart';
import '../../../amenities/domain/amenity.dart';
import '../../../community/application/tenant_providers.dart';

/// Formats raw digit input as currency: typing 8,8,8 → "8.88" (digits fill
/// from the cents place). Pair with a numeric keyboard.
class _CentsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final cents = int.parse(digits);
    final text = (cents / 100).toStringAsFixed(2);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Human label for an amenity status (capitalized, spaced).
String amenityStatusLabel(AmenityStatus s) => switch (s) {
      AmenityStatus.active => 'Active',
      AmenityStatus.comingSoon => 'Coming soon',
      AmenityStatus.maintenance => 'Maintenance',
    };

class AmenitiesManagerScreen extends ConsumerWidget {
  const AmenitiesManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amenities = ref.watch(amenitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amenities manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: amenities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: list
              .map((a) => Card(
                    child: ListTile(
                      title: Text(a.name),
                      subtitle: Text(
                        '${amenityStatusLabel(a.status)} · '
                        '${a.pricing.isPaid ? '\$${(a.pricing.amountCents / 100).toStringAsFixed(2)}/hr' : 'Free'}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _openEditor(context, ref, a),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, Amenity? amenity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // close only via the X (with a discard prompt)
      enableDrag: false,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AmenityEditor(amenity: amenity),
      ),
    );
  }
}

class _AmenityEditor extends ConsumerStatefulWidget {
  const _AmenityEditor({this.amenity});
  final Amenity? amenity;

  @override
  ConsumerState<_AmenityEditor> createState() => _AmenityEditorState();
}

class _AmenityEditorState extends ConsumerState<_AmenityEditor> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _price;
  AmenityStatus _status = AmenityStatus.active;
  int _openHour = 6;
  int _closeHour = 22;
  bool _isPaid = false;
  bool _dirty = false;
  bool _saving = false;

  void _markDirty() => _dirty = true;

  @override
  void initState() {
    super.initState();
    final a = widget.amenity;
    _name = TextEditingController(text: a?.name ?? '');
    _desc = TextEditingController(text: a?.description ?? '');
    _price = TextEditingController(
      text: (a != null && a.pricing.amountCents > 0)
          ? (a.pricing.amountCents / 100).toStringAsFixed(2)
          : '',
    );
    _status = a?.status ?? AmenityStatus.active;
    _openHour = a?.openHour ?? 6;
    _closeHour = a?.closeHour ?? 22;
    _isPaid = a?.pricing.isPaid ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  String _hourLabel(int hour) =>
      TimeOfDay(hour: hour, minute: 0).format(context);

  Future<void> _pickHour({required bool open}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: open ? _openHour : _closeHour, minute: 0),
      helpText: open ? 'Opens at' : 'Closes at',
    );
    if (picked == null) return;
    setState(() {
      if (open) {
        _openHour = picked.hour;
      } else {
        _closeHour = picked.hour;
      }
    });
  }

  Future<void> _save() async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Please enter a name.')));
      return;
    }
    final amenity = (widget.amenity ?? const Amenity(id: '')).copyWith(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      status: _status,
      slotMinutes: 60, // bookings are always 1-hour slots
      openHour: _openHour,
      closeHour: _closeHour,
      pricing: AmenityPricing(
        isPaid: _isPaid,
        amountCents:
            ((double.tryParse(_price.text.trim()) ?? 0) * 100).round(),
        currency: 'USD',
      ),
    );
    setState(() => _saving = true);
    try {
      await ref.read(amenityRepositoryProvider).save(cid, amenity);
      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } on FirebaseException catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
          SnackBar(content: Text('Save failed: ${e.message ?? e.code}')));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _delete() async {
    final cid = ref.read(currentCommunityIdProvider);
    final a = widget.amenity;
    if (cid == null || a == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete amenity?'),
        content: Text('"${a.name}" will be removed.'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(amenityRepositoryProvider).delete(cid, a.id);
      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(const SnackBar(content: Text('Deleted')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _close() async {
    if (_dirty) {
      final discard = await confirmDiscard(context);
      if (!discard) return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      widget.amenity == null ? 'New amenity' : 'Edit amenity',
                      style: theme.textTheme.titleLarge),
                ),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: _close),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _name,
                onChanged: (_) => _markDirty(),
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _desc,
                onChanged: (_) => _markDirty(),
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            DropdownButtonFormField<AmenityStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: AmenityStatus.values
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(amenityStatusLabel(s))))
                  .toList(),
              onChanged: (v) => setState(() {
                _status = v ?? AmenityStatus.active;
                _markDirty();
              }),
            ),
            const SizedBox(height: 20),
            Text('Operating hours',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _HourTile(
                    label: 'Opens',
                    value: _hourLabel(_openHour),
                    onTap: () => _pickHour(open: true)),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('–')),
              Expanded(
                child: _HourTile(
                    label: 'Closes',
                    value: _hourLabel(_closeHour),
                    onTap: () => _pickHour(open: false)),
              ),
            ]),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid amenity'),
              value: _isPaid,
              onChanged: (v) => setState(() {
                _isPaid = v;
                _markDirty();
              }),
            ),
            if (_isPaid)
              TextField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_CentsInputFormatter()],
                onChanged: (_) => _markDirty(),
                decoration: const InputDecoration(
                  labelText: 'Price per hour',
                  prefixText: '\$ ',
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
            if (widget.amenity != null)
              TextButton(
                onPressed: _delete,
                child: Text('Delete',
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A tappable tile showing an "Opens/Closes" hour, opening a time picker.
class _HourTile extends StatelessWidget {
  const _HourTile(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.schedule, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ],
        ),
      ),
    );
  }
}
