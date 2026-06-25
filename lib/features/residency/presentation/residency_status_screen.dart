import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';
import '../../auth/application/auth_controller.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';

/// Shown after a resident submits their document (pending review), or if it was
/// rejected (with a reason and the option to resubmit).
class ResidencyStatusScreen extends ConsumerWidget {
  const ResidencyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membership = ref.watch(currentMembershipProvider);
    final community = ref.watch(activeCommunityProvider);
    final rejected = membership?.residencyStatus == ResidencyStatus.rejected;
    final lime = theme.colorScheme.primary;

    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status badge.
                    Center(
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: rejected
                              ? theme.colorScheme.error.withValues(alpha: 0.15)
                              : lime.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          rejected ? Icons.close_rounded : Icons.check_rounded,
                          size: 40,
                          color: rejected ? theme.colorScheme.error : lime,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Scale down so the title + emoji always stay on one line.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        rejected
                            ? 'Verification Declined'
                            : 'Document Uploaded Successfully! 🎉',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: rejected ? theme.colorScheme.error : lime,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (rejected) ...[
                      _InfoBox(
                        icon: Icons.error_outline,
                        title: 'Verification declined',
                        child: Text(
                          membership?.rejectionReason ??
                              'Your document could not be verified. Please '
                                  'upload a clearer document and resubmit.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () =>
                            context.go(Routes.residencyVerification),
                        child: const Text('Resubmit document'),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      // Pending approval explainer.
                      _InfoBox(
                        icon: Icons.info_outline,
                        title: 'Account Pending Approval',
                        child: Text.rich(
                          TextSpan(
                            style: theme.textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                  text:
                                      'Your document was uploaded and is now '
                                      'pending approval from your community '
                                      'administrator. Once approved, you’ll get '
                                      'access to '),
                              TextSpan(
                                text: community.name,
                                style: TextStyle(
                                    color: lime, fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(
                                  text:
                                      ' and receive an email confirmation.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // What's next.
                      _InfoBox(
                        icon: Icons.schedule,
                        title: 'What’s Next?',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _NextStep(
                                n: 1,
                                text:
                                    'Wait for your community administrator’s approval.'),
                            SizedBox(height: 10),
                            _NextStep(
                                n: 2,
                                text:
                                    'You’ll receive an email confirmation once approved.'),
                            SizedBox(height: 10),
                            _NextStep(
                                n: 3,
                                text:
                                    'Once approved, you can log in to your community.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      icon: const Icon(Icons.login),
                      label: const Text('Continue to Login Screen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded panel with a lime-tinted leading icon + title and arbitrary body.
class _InfoBox extends StatelessWidget {
  const _InfoBox(
      {required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// A numbered "What's next" step with a lime number chip.
class _NextStep extends StatelessWidget {
  const _NextStep({required this.n, required this.text});
  final int n;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 22,
          width: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Text('$n',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(text, style: theme.textTheme.bodyMedium),
        )),
      ],
    );
  }
}
