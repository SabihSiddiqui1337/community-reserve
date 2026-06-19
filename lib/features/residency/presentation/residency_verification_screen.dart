import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/data/membership_repository.dart';
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
  Uint8List? _bytes;
  String? _fileName;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _unit.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _bytes = bytes;
      _fileName = file.name;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final cid = ref.read(currentCommunityIdProvider);
    final uid = ref.read(currentUidProvider);
    final bytes = _bytes;
    if (cid == null || uid == null || bytes == null) {
      setState(() => _error = 'Please choose a document first.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final url = await ref.read(residencyRepositoryProvider).uploadDocument(
            communityId: cid,
            uid: uid,
            fileName: _fileName ?? 'residency.jpg',
            bytes: bytes,
          );
      await ref.read(membershipRepositoryProvider).submitResidency(
            cid, uid, url, unit: _unit.text.trim());
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify residency'),
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
                Text('One last step',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Upload a utility bill, lease, or ID so ${community.name} '
                  'can confirm you live in the community.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit / household (optional)',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                _UploadBox(bytes: _bytes, onTap: _pick),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
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

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.bytes, required this.onTap});
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: bytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  const Text('Tap to choose a document'),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity),
              ),
      ),
    );
  }
}
