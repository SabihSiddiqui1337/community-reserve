import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format/contact.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/data/membership_repository.dart';
import '../data/document_picker.dart';
import '../data/residency_repository.dart';

class ResidencyVerificationScreen extends ConsumerStatefulWidget {
  const ResidencyVerificationScreen({super.key});

  @override
  ConsumerState<ResidencyVerificationScreen> createState() =>
      _ResidencyVerificationScreenState();
}

class _ResidencyVerificationScreenState
    extends ConsumerState<ResidencyVerificationScreen> {
  final _unit = TextEditingController();
  final _phone = TextEditingController();
  Uint8List? _bytes;
  String? _fileName;
  bool _submitting = false;
  bool _phoneFilled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Re-evaluate the Submit button as the address field changes.
    _unit.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _unit.dispose();
    _phone.dispose();
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
    final unit = _unit.text.trim();
    if (unit.isEmpty) {
      setState(() => _error = 'Please enter your unit, household, or address.');
      return;
    }
    if (cid == null || uid == null || bytes == null) {
      setState(() => _error = 'Please choose a document first.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final phoneDigits = _phone.text.replaceAll(RegExp(r'\D'), '');
      if (phoneDigits.isNotEmpty) {
        await ref
            .read(userRepositoryProvider)
            .updateProfile(uid, phone: phoneDigits);
      }
      final url = await ref.read(residencyRepositoryProvider).uploadDocument(
            communityId: cid,
            uid: uid,
            fileName: _fileName ?? 'residency.jpg',
            bytes: bytes,
          );
      await ref.read(membershipRepositoryProvider).submitResidency(
            cid, uid, url, unit: unit);
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

    // Submit is enabled only once an address AND a document are provided.
    final canSubmit = _unit.text.trim().isNotEmpty && _bytes != null;

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
                Text('One more step',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Add your details and upload a document so ${community.name} '
                  'can confirm you live in the community.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit, household, or address',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
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
                  label: Text(_submitting ? 'Submitting…' : 'Submit for review'),
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
