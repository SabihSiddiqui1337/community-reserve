import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../amenities/data/amenity_repository.dart';
import '../../../amenities/domain/amenity.dart';
import '../../../community/application/tenant_providers.dart';

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
                          '${a.status.name} · ${a.slotMinutes}min · cap ${a.capacity}'),
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
  late TextEditingController _slot;
  late TextEditingController _capacity;
  late TextEditingController _open;
  late TextEditingController _close;
  late TextEditingController _price;
  AmenityStatus _status = AmenityStatus.active;
  String _type = 'generic';
  bool _isPaid = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.amenity;
    _name = TextEditingController(text: a?.name ?? '');
    _desc = TextEditingController(text: a?.description ?? '');
    _slot = TextEditingController(text: '${a?.slotMinutes ?? 60}');
    _capacity = TextEditingController(text: '${a?.capacity ?? 1}');
    _open = TextEditingController(text: '${a?.openHour ?? 6}');
    _close = TextEditingController(text: '${a?.closeHour ?? 22}');
    _price = TextEditingController(text: '${a?.pricing.amountCents ?? 0}');
    _status = a?.status ?? AmenityStatus.active;
    _type = a?.type ?? 'generic';
    _isPaid = a?.pricing.isPaid ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _slot, _capacity, _open, _close, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    setState(() => _saving = true);
    final amenity = (widget.amenity ?? const Amenity(id: '')).copyWith(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      type: _type,
      status: _status,
      slotMinutes: int.tryParse(_slot.text) ?? 60,
      capacity: int.tryParse(_capacity.text) ?? 1,
      openHour: int.tryParse(_open.text) ?? 6,
      closeHour: int.tryParse(_close.text) ?? 22,
      pricing: AmenityPricing(
        isPaid: _isPaid,
        amountCents: int.tryParse(_price.text) ?? 0,
        currency: 'USD',
      ),
    );
    await ref.read(amenityRepositoryProvider).save(cid, amenity);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final cid = ref.read(currentCommunityIdProvider);
    final a = widget.amenity;
    if (cid == null || a == null) return;
    await ref.read(amenityRepositoryProvider).delete(cid, a.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.amenity == null ? 'New amenity' : 'Edit amenity',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'pickleballCourt', child: Text('Pickleball court')),
              DropdownMenuItem(value: 'gym', child: Text('Gym')),
              DropdownMenuItem(value: 'hall', child: Text('Hall')),
              DropdownMenuItem(value: 'generic', child: Text('Generic')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'generic'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AmenityStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: AmenityStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? AmenityStatus.active),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _slot, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Slot min'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _open, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Open hour'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _close, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Close hour'))),
          ]),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Paid amenity'),
            value: _isPaid,
            onChanged: (v) => setState(() => _isPaid = v),
          ),
          if (_isPaid)
            TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (cents)')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
          if (widget.amenity != null)
            TextButton(
              onPressed: _delete,
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
