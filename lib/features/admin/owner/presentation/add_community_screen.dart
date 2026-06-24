import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/app_snack.dart';
import '../../../community/data/community_directory_repository.dart';
import '../../../community/data/community_repository.dart';

/// Owner-only: create a brand-new community, or — when [communityId] is set —
/// edit an existing one (including its HOA resident-portal link). New
/// communities appear on the Sign-up screen; editing keeps the public
/// directory entry in sync.
class AddCommunityScreen extends ConsumerStatefulWidget {
  const AddCommunityScreen({super.key, this.communityId});

  /// When non-null, the screen edits this community instead of creating one.
  final String? communityId;

  @override
  ConsumerState<AddCommunityScreen> createState() => _AddCommunityScreenState();
}

class _AddCommunityScreenState extends ConsumerState<AddCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _portal = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();
  final _joinCode = TextEditingController();

  bool _busy = false;
  bool _loading = false;

  bool get _isEdit => widget.communityId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _load();
  }

  /// Edit mode: pre-fill the fields from the community + directory docs.
  Future<void> _load() async {
    setState(() => _loading = true);
    final id = widget.communityId!;
    final community = await ref.read(communityRepositoryProvider).fetch(id);
    final summary =
        await ref.read(communityDirectoryRepositoryProvider).fetch(id);
    if (!mounted) return;
    _name.text = community.name;
    _portal.text = community.residentPortalUrl ?? '';
    // Prefer the discrete street; fall back to the full address for older
    // communities that predate split address fields.
    _address.text = (summary?.street ?? '').isNotEmpty
        ? summary!.street
        : community.address;
    _city.text = summary?.city ?? '';
    _state.text = summary?.state ?? '';
    _zip.text = summary?.zip ?? '';
    _joinCode.text = summary?.joinCode ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _portal.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _zip.dispose();
    _joinCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      if (_isEdit) {
        await repo.updateCommunity(
          id: widget.communityId!,
          name: _name.text.trim(),
          address: _address.text.trim(),
          residentPortalUrl: _portal.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          zip: _zip.text.trim(),
          joinCode: _joinCode.text.trim(),
        );
      } else {
        await repo.createCommunity(
          name: _name.text.trim(),
          address: _address.text.trim(),
          residentPortalUrl: _portal.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
          zip: _zip.text.trim(),
          joinCode: _joinCode.text.trim(),
        );
      }
      if (!mounted) return;
      showSnack(context, _isEdit ? 'Community updated' : 'Community created');
      context.go(Routes.adminAllCommunities);
    } catch (_) {
      if (!mounted) return;
      showError(context,
          _isEdit ? 'Could not save changes.' : 'Could not create the community.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Community' : 'Add Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(_isEdit ? Routes.adminAllCommunities : Routes.admin),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _isEdit
                  ? 'Update this community. Adding an HOA link replaces its '
                      '"Coming Soon" screen with the live resident portal.'
                  : 'New communities appear on the Sign-up screen and get their '
                      'own HOA portal link.',
              style: TextStyle(color: AppTheme.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Community name',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _portal,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'HOA / Resident portal link',
                hintText: 'https://…',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _address,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _city,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _state,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _zip,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Zip code',
                      prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _joinCode,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_UpperCaseFormatter()],
              decoration: const InputDecoration(
                labelText: 'Join code',
                prefixIcon: Icon(Icons.qr_code_2),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.onLime,
                        ),
                      )
                    : Text(_isEdit ? 'Save changes' : 'Create community'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forces input to uppercase as the user types (for the join code).
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
