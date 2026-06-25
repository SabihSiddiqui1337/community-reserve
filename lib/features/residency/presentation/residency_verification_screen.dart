import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format/contact.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/data/membership_repository.dart';
import '../data/address_autocomplete.dart';
import '../data/document_picker.dart';
import '../data/residency_repository.dart';

const _usStates = <String>[
  'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
  'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
  'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine',
  'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
  'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
  'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
  'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
  'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia',
  'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',
];

class ResidencyVerificationScreen extends ConsumerStatefulWidget {
  const ResidencyVerificationScreen({super.key});

  @override
  ConsumerState<ResidencyVerificationScreen> createState() =>
      _ResidencyVerificationScreenState();
}

class _ResidencyVerificationScreenState
    extends ConsumerState<ResidencyVerificationScreen> {
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  String? _stateValue;
  Uint8List? _bytes;
  String? _fileName;
  bool _submitting = false;
  bool _phoneFilled = false;
  bool _emailFilled = false;
  String? _error;

  Timer? _debounce;
  List<AddressSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Re-evaluate the Submit button as the required address fields change.
    for (final c in [_line1, _city, _zip]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  // Debounced address lookup as the user types in Address Line 1.
  void _onLine1Changed(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await fetchAddressSuggestions(query);
      if (!mounted) return;
      // Ignore stale results if the field changed since the request started.
      if (_line1.text.trim() != query) return;
      setState(() => _suggestions = results);
    });
  }

  Future<void> _selectSuggestion(AddressSuggestion s) async {
    final d = await fetchAddressDetails(s.placeId);
    if (!mounted) return;
    setState(() {
      if (d != null) {
        _line1.text = d.line1;
        _city.text = d.city;
        _zip.text = d.zip;
        if (_usStates.contains(d.state)) _stateValue = d.state;
      }
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _zip.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    // Browse any document (PDF, image, etc.) from the device/computer.
    final picked = await pickDocument();
    if (picked == null) return;
    setState(() {
      _bytes = picked.bytes;
      _fileName = picked.name;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final cid = ref.read(currentCommunityIdProvider);
    final uid = ref.read(currentUidProvider);
    final bytes = _bytes;
    final line1 = _line1.text.trim();
    final city = _city.text.trim();
    final st = _stateValue ?? '';
    final zip = _zip.text.trim();
    if (line1.isEmpty || city.isEmpty || st.isEmpty || zip.isEmpty) {
      setState(() => _error = 'Please complete your address.');
      return;
    }
    if (cid == null || uid == null || bytes == null) {
      setState(() => _error = 'Please choose a document first.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final phoneDigits = _phone.text.replaceAll(RegExp(r'\D'), '');
      final emailVal = _email.text.trim();
      if (phoneDigits.isNotEmpty || emailVal.isNotEmpty) {
        await ref.read(userRepositoryProvider).updateProfile(
              uid,
              phone: phoneDigits.isNotEmpty ? phoneDigits : null,
              email: emailVal.isNotEmpty ? emailVal : null,
            );
      }
      final url = await ref.read(residencyRepositoryProvider).uploadDocument(
            communityId: cid,
            uid: uid,
            fileName: _fileName ?? 'residency.jpg',
            bytes: bytes,
          );
      final address = '$line1, $city, $st $zip';
      await ref.read(membershipRepositoryProvider).submitResidency(
            cid, uid, url, unit: _line2.text.trim(), address: address);
      // onboarding stage advances to pendingReview → router redirects.
    } catch (e) {
      if (mounted) setState(() => _error = 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final community = ref.watch(activeCommunityProvider);

    // Prefill the phone from the profile (entered at sign-up) once it loads —
    // editable. Guarded so it never overwrites what the user has typed.
    final user = ref.watch(currentUserProvider).value;
    if (!_phoneFilled && _phone.text.isEmpty && (user?.phone ?? '').isNotEmpty) {
      _phone.text = formatPhone(user!.phone);
      _phoneFilled = true;
    }
    if (!_emailFilled && _email.text.isEmpty && (user?.email ?? '').isNotEmpty) {
      _email.text = user!.email;
      _emailFilled = true;
    }

    // Submit is enabled only once the address AND a document are provided.
    final canSubmit = _line1.text.trim().isNotEmpty &&
        _city.text.trim().isNotEmpty &&
        (_stateValue ?? '').isNotEmpty &&
        _zip.text.trim().isNotEmpty &&
        _email.text.trim().isNotEmpty &&
        _bytes != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('One More Step',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      const TextSpan(
                          text: 'Add your details and upload a document so '),
                      TextSpan(
                        text: community.name,
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                          text: ' can confirm you live in the community.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Address',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _line1,
                  textInputAction: TextInputAction.next,
                  onChanged: _onLine1Changed,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                if (_suggestions.isNotEmpty) _AddressSuggestionsPanel(
                  suggestions: _suggestions,
                  onSelected: _selectSuggestion,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _line2,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 2 (optional)',
                    hintText: 'Suite, unit, building, etc.',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _city,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [TitleCaseInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      // Type to filter the states, then pick one.
                      child: DropdownMenu<String>(
                        initialSelection: _stateValue,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        expandedInsets: EdgeInsets.zero,
                        menuHeight: 280,
                        label: const Text('State'),
                        inputDecorationTheme: theme.inputDecorationTheme,
                        dropdownMenuEntries: [
                          for (final s in _usStates)
                            DropdownMenuEntry(value: s, label: s),
                        ],
                        onSelected: (v) => setState(() => _stateValue = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _zip,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ZIP'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Double-check your email — we’ll send your approval '
                    'confirmation here.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 16),
                _UploadBox(bytes: _bytes, fileName: _fileName, onPick: _pick),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: (_submitting || !canSubmit) ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_submitting ? 'Submitting…' : 'Submit for Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatefulWidget {
  const _UploadBox(
      {required this.bytes, required this.fileName, required this.onPick});
  final Uint8List? bytes;
  final String? fileName;
  final VoidCallback onPick; // choose / replace the document

  @override
  State<_UploadBox> createState() => _UploadBoxState();
}

class _UploadBoxState extends State<_UploadBox> {
  bool _hovering = false;

  bool get _isImage {
    final n = (widget.fileName ?? '').toLowerCase();
    return n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.webp') ||
        n.endsWith('.heic');
  }

  void _view() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.memory(widget.bytes!, fit: BoxFit.contain),
              ),
            ),
            Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: widget.bytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_outlined,
                    size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                const Text('Tap to choose your document'),
              ],
            )
          : (_isImage
              ? Image.memory(widget.bytes!,
                  fit: BoxFit.cover, width: double.infinity)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 40, color: theme.colorScheme.primary),
                    const SizedBox(height: 10),
                    Text('Document selected',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(widget.fileName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ],
                )),
    );

    // Empty state: the whole box picks a document.
    if (widget.bytes == null) {
      return InkWell(
        onTap: widget.onPick,
        borderRadius: BorderRadius.circular(16),
        child: box,
      );
    }

    // Filled state: hover reveals View (images) + Replace actions over it.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          box,
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _hovering ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isImage)
                      _OverlayAction(
                          icon: Icons.visibility_outlined,
                          label: 'View',
                          onTap: _view),
                    if (_isImage) const SizedBox(width: 14),
                    _OverlayAction(
                        icon: Icons.swap_horiz,
                        label: 'Replace',
                        onTap: widget.onPick),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown panel of address suggestions shown directly below Address Line 1.
class _AddressSuggestionsPanel extends StatelessWidget {
  const _AddressSuggestionsPanel(
      {required this.suggestions, required this.onSelected});
  final List<AddressSuggestion> suggestions;
  final Future<void> Function(AddressSuggestion) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = suggestions.take(6).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in items)
                InkWell(
                  onTap: () => unawaited(onSelected(s)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pill button used in the upload-box hover overlay.
class _OverlayAction extends StatelessWidget {
  const _OverlayAction(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
