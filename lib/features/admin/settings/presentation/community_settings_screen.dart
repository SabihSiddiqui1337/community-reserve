import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/community_repository.dart';

/// Plain-language admin screen for the community's booking rules. Settings are
/// grouped into friendly sections; each row pairs a human label + helper
/// subtitle with a number field. Persists through [CommunityRepository.update]
/// exactly as before (the `settings` map keyed by the raw model field names).
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
  bool _taxEnabled = true;

  /// Every raw settings field we persist. Order here drives nothing — the
  /// sections below decide layout — but it keeps save/init in one place.
  static const _fields = <String>[
    'maxBookingHoursPerWeek',
    'advanceBookingDays',
    'maxActiveReservationsPerUser',
    'checkInGraceMinutes',
    'noShowThreshold',
    'noShowBanDays',
    'cancellationCutoffMinutes',
    'cancellationAllowance',
  ];

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
    for (final key in _fields) {
      settings[key] = int.tryParse(_controllers[key]!.text.trim()) ?? 0;
    }
    settings['taxEnabled'] = _taxEnabled;
    await ref.read(communityRepositoryProvider).update(cid, {
      'settings': settings,
      'featureFlags': {'paymentsEnabled': _paymentsEnabled},
    });
    if (mounted) {
      setState(() => _saving = false);
      showSnack(context, 'Settings saved.');
      context.go(Routes.admin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final community = ref.watch(activeCommunityProvider);
    if (!_init) {
      final s = community.settings.toJson();
      for (final key in _fields) {
        _controllers[key] = TextEditingController(text: '${s[key]}');
      }
      _paymentsEnabled = community.featureFlags.paymentsEnabled;
      _taxEnabled = community.settings.taxEnabled;
      _init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Rules'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Set the rules that keep amenity booking fair for everyone. These '
            'apply to every resident in your community.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          _Section(
            title: 'Booking limits',
            icon: Icons.event_available,
            children: [
              _SettingRow(
                controller: _controllers['maxBookingHoursPerWeek']!,
                defaultValue: 3,
                label: 'Hours per week each resident can book',
                helper: 'Total amenity time a resident can reserve in a week.',
                suffix: 'hrs',
              ),
              _SettingRow(
                controller: _controllers['advanceBookingDays']!,
                defaultValue: 7,
                label: 'How far ahead residents can book (days)',
                helper: 'Residents can reserve slots up to this many days out.',
                suffix: 'days',
              ),
              _SettingRow(
                controller: _controllers['maxActiveReservationsPerUser']!,
                defaultValue: 2,
                label: 'Max active reservations per resident',
                helper: 'How many upcoming bookings a resident can hold at once.',
              ),
            ],
          ),
          _Section(
            title: 'Check-in & no-shows',
            icon: Icons.how_to_reg,
            children: [
              _SettingRow(
                controller: _controllers['checkInGraceMinutes']!,
                defaultValue: 15,
                label: 'Check-in grace period (minutes)',
                helper: 'How long after the start time a resident can still '
                    'check in before it counts as a no-show.',
                suffix: 'min',
              ),
              _SettingRow(
                controller: _controllers['noShowThreshold']!,
                defaultValue: 3,
                label: 'No-shows before a ban',
                helper: 'Number of no-shows that triggers a temporary ban.',
              ),
              _SettingRow(
                controller: _controllers['noShowBanDays']!,
                defaultValue: 30,
                label: 'Ban length (days)',
                helper: 'How long a resident is blocked from booking after a ban.',
                suffix: 'days',
              ),
            ],
          ),
          _Section(
            title: 'Cancellations',
            icon: Icons.cancel_schedule_send,
            children: [
              _SettingRow(
                controller: _controllers['cancellationCutoffMinutes']!,
                defaultValue: 60,
                label: 'Free-cancel cutoff before start (minutes)',
                helper: 'Cancelling earlier than this is always free.',
                suffix: 'min',
              ),
              _SettingRow(
                controller: _controllers['cancellationAllowance']!,
                defaultValue: 2,
                label: 'Late-cancellations allowed before flag',
                helper: 'A cancellation only counts if made after the '
                    'reservation start time.',
              ),
            ],
          ),
          _Section(
            title: 'Payments',
            icon: Icons.payments_outlined,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payments enabled'),
                subtitle: const Text('Require payment for paid amenities.'),
                value: _paymentsEnabled,
                onChanged: (v) => setState(() => _paymentsEnabled = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Charge sales tax (8.25%)'),
                subtitle: const Text(
                    'Add 8.25% tax to paid bookings at checkout.'),
                value: _taxEnabled,
                onChanged: (v) => setState(() => _taxEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving…' : 'Save settings'),
          ),
        ],
      ),
    );
  }
}

/// A labelled card grouping related settings under a section header.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 24,
                  color: theme.colorScheme.outline.withValues(alpha: 0.18),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// A single numeric setting: human label + helper subtitle on the left, a
/// compact number field on the right.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.controller,
    required this.label,
    required this.helper,
    required this.defaultValue,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final int defaultValue;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  helper,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // Tapping away from an empty field restores the default value.
              onTapOutside: (_) {
                if (controller.text.trim().isEmpty) {
                  controller.text = '$defaultValue';
                }
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onEditingComplete: () {
                if (controller.text.trim().isEmpty) {
                  controller.text = '$defaultValue';
                }
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                isDense: true,
                suffixText: suffix,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
