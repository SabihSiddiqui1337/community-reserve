import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/routes.dart';
import '../../../shared/format/contact.dart';
import '../../../shared/widgets/app_snack.dart';
import '../../amenities/data/amenity_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../data/event_request_repository.dart';

/// Reserving an event space opens this form (instead of instant paid checkout).
/// The resident fills in their details + a message; it's sent to the organizer.
class EventRequestScreen extends ConsumerStatefulWidget {
  const EventRequestScreen({
    super.key,
    required this.amenityId,
    required this.start,
    required this.end,
  });
  final String amenityId;
  final DateTime start;
  final DateTime end;

  @override
  ConsumerState<EventRequestScreen> createState() => _EventRequestScreenState();
}

class _EventRequestScreenState extends ConsumerState<EventRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    for (final c in [_first, _last, _phone, _email, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cid = ref.read(currentCommunityIdProvider);
    final uid = ref.read(currentUidProvider);
    if (cid == null || uid == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(eventRequestRepositoryProvider).submit(
            communityId: cid,
            amenityId: widget.amenityId,
            userId: uid,
            start: widget.start,
            end: widget.end,
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            message: _message.text.trim(),
          );
      if (mounted) {
        showSnack(context,
            'Request sent! The organizer will reach out to confirm.');
        context.go(Routes.book);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showError(context, "Couldn't send your request. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenity = ref.watch(amenityProvider(widget.amenityId)).value;
    final user = ref.watch(currentUserProvider).value;

    // Prefill from the profile once.
    if (!_seeded && user != null) {
      final parts = user.name.trim().split(' ');
      _first.text = parts.isNotEmpty ? parts.first : '';
      _last.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _phone.text = formatPhone(user.phone);
      _email.text = user.email;
      _seeded = true;
    }

    final hours = widget.end.difference(widget.start).inMinutes ~/ 60;
    final dateLabel = DateFormat('EEEE, MMMM d').format(widget.start);
    final timeLabel =
        '${DateFormat('h:mm a').format(widget.start)} – ${DateFormat('h:mm a').format(widget.end)}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(Routes.bookSlotsTo(widget.amenityId)),
        ),
        title: const Text('Request to Reserve'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            // What they're requesting.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amenity?.name ?? 'Event space',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _line(theme, Icons.event, dateLabel),
                  _line(theme, Icons.schedule,
                      '$timeLabel  ·  $hours hour${hours == 1 ? '' : 's'}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
              child: Text(
                'Fill out your details and a message — we’ll send your request '
                'to the organizer, who will follow up to confirm.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _first,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _last,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v ?? '').replaceAll(RegExp(r'\D'), '').length < 10
                      ? 'Enter a valid phone number'
                      : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _message,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message to the organizer',
                hintText: 'Tell them about your event…',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Add a short message' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              icon: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_outlined),
              label: Text(_busy ? 'Sending…' : 'Send request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(ThemeData theme, IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
}
