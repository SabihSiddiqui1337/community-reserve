import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/community_repository.dart';

class CommunitySettingsScreen extends ConsumerStatefulWidget {
  const CommunitySettingsScreen({super.key});

  @override
  ConsumerState<CommunitySettingsScreen> createState() =>
      _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState
    extends ConsumerState<CommunitySettingsScreen> {
  final _controllers = <String, TextEditingController>{};
  bool _init = false;
  bool _saving = false;
  bool _paymentsEnabled = false;

  static const _fields = <String, String>{
    'maxBookingHoursPerWeek': 'Weekly hour cap',
    'advanceBookingDays': 'Advance booking days',
    'maxActiveReservationsPerUser': 'Max active reservations',
    'checkInGraceMinutes': 'Check-in grace (min)',
    'noShowThreshold': 'No-show threshold',
    'noShowBanDays': 'Ban duration (days)',
    'cancellationCutoffMinutes': 'Cancellation cutoff (min)',
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    setState(() => _saving = true);
    final settings = <String, dynamic>{};
    for (final key in _fields.keys) {
      settings[key] = int.tryParse(_controllers[key]!.text) ?? 0;
    }
    await ref.read(communityRepositoryProvider).update(cid, {
      'settings': settings,
      'featureFlags': {'paymentsEnabled': _paymentsEnabled},
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(activeCommunityProvider);
    if (!_init) {
      final s = community.settings.toJson();
      for (final key in _fields.keys) {
        _controllers[key] = TextEditingController(text: '${s[key]}');
      }
      _paymentsEnabled = community.featureFlags.paymentsEnabled;
      _init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking rules'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final entry in _fields.entries) ...[
            TextField(
              controller: _controllers[entry.key],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: entry.value),
            ),
            const SizedBox(height: 14),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Payments enabled'),
            subtitle: const Text('Require payment for paid amenities'),
            value: _paymentsEnabled,
            onChanged: (v) => setState(() => _paymentsEnabled = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving…' : 'Save settings'),
          ),
        ],
      ),
    );
  }
}
