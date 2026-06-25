import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/format/contact.dart';
import '../../../shared/widgets/app_snack.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../auth/domain/app_user.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/data/membership_repository.dart';
import '../../community/domain/membership.dart';

/// Capitalize the first letter (e.g. "pending" -> "Pending").
String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// One-shot fetch of the global `users/{uid}` profile for the detail dialog
/// (name / phone / email join).
final memberProfileProvider =
    FutureProvider.family<AppUser?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watch(uid).first;
});

/// Opens the shared member/residency detail dialog. Shows the membership joined
/// with the global `users/{uid}` profile (Name/Phone/Email/Address/Unit/
/// Residency status). When [showApproveReject] is true, also offers Approve
/// (lime) / Reject (red) behind an "Are you sure?" confirmation.
Future<void> showMemberDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required Membership membership,
  bool showApproveReject = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _MemberDetailDialog(
      membership: membership,
      showApproveReject: showApproveReject,
    ),
  );
}

class _MemberDetailDialog extends ConsumerWidget {
  const _MemberDetailDialog({
    required this.membership,
    required this.showApproveReject,
  });
  final Membership membership;
  final bool showApproveReject;

  Future<bool> _confirm(BuildContext context, {required bool approve}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(approve ? 'Approve resident?' : 'Reject resident?'),
          content: Text(approve
              ? 'Are you sure you want to approve this resident?'
              : 'Are you sure you want to reject this resident?'),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: approve
                        ? null
                        : FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(approve ? 'Approve' : 'Reject'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return ok ?? false;
  }

  void _viewDocument(BuildContext context) {
    final url = membership.verificationDocUrl;
    if (url == null || url.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.8,
                maxWidth: MediaQuery.of(ctx).size.width * 0.92,
              ),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    width: 200,
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          "Couldn't load document",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    if (!await _confirm(context, approve: true)) return;
    if (!context.mounted) return;
    final cid = ref.read(currentCommunityIdProvider);
    final reviewer = ref.read(currentUidProvider);
    if (cid == null || reviewer == null) return;
    await ref
        .read(membershipRepositoryProvider)
        .approve(cid, membership.userId, reviewer);
    if (!context.mounted) return;
    Navigator.pop(context);
    showSnack(context, 'Resident approved');
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    if (!await _confirm(context, approve: false)) return;
    if (!context.mounted) return;
    final cid = ref.read(currentCommunityIdProvider);
    final reviewer = ref.read(currentUidProvider);
    if (cid == null || reviewer == null) return;
    await ref
        .read(membershipRepositoryProvider)
        .reject(cid, membership.userId, reviewer, 'Rejected by admin');
    if (!context.mounted) return;
    Navigator.pop(context);
    showSnack(context, 'Resident rejected');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(memberProfileProvider(membership.userId));

    final name = profile.maybeWhen(
      data: (u) => (u?.name ?? '').isNotEmpty ? u!.name : '—',
      orElse: () => '…',
    );
    final phone = profile.maybeWhen(
      data: (u) => (u?.phone ?? '').isNotEmpty ? formatPhone(u!.phone) : '—',
      orElse: () => '…',
    );
    final email = profile.maybeWhen(
      data: (u) => (u?.email ?? '').isNotEmpty ? _cap(u!.email) : '—',
      orElse: () => '…',
    );
    final address =
        membership.address.isNotEmpty ? addressTwoLine(membership.address) : '—';
    final unit = membership.unit.isNotEmpty ? membership.unit : '—';

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Member Details')),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(icon: Icons.person_outline, label: 'Name', value: name),
            _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: phone),
            _DetailRow(
                icon: Icons.email_outlined, label: 'Email', value: email),
            _DetailRow(
                icon: Icons.home_outlined, label: 'Address', value: address),
            _DetailRow(
                icon: Icons.meeting_room_outlined, label: 'Unit', value: unit),
            _DetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Residency Status',
              value: _cap(membership.residencyStatus.name),
            ),
            _DocumentRow(
              hasDocument: (membership.verificationDocUrl ?? '').isNotEmpty,
              onView: () => _viewDocument(context),
            ),
          ],
        ),
      ),
      // No bottom Close button — the top-right X closes it.
      actions: showApproveReject
          ? [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      onPressed: () => _reject(context, ref),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approve(context, ref),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ]
          : null,
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.hasDocument, required this.onView});
  final bool hasDocument;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, size: 20, color: AppTheme.lime),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                if (hasDocument) ...[
                  Text('Document Uploaded', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lime,
                      side: BorderSide(
                        color: AppTheme.lime.withValues(alpha: 0.6),
                      ),
                    ),
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Document'),
                  ),
                ] else
                  Text(
                    'No document uploaded',
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.lime),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
