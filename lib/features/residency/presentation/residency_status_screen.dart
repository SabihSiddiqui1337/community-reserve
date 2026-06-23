import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';
import '../../auth/application/auth_controller.dart';
import '../../community/application/tenant_providers.dart';
import '../../community/domain/membership.dart';

/// Shown while residency is pending review, or if it was rejected (with a
/// reason and the option to resubmit).
class ResidencyStatusScreen extends ConsumerWidget {
  const ResidencyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membership = ref.watch(currentMembershipProvider);
    final community = ref.watch(activeCommunityProvider);
    final rejected =
        membership?.residencyStatus == ResidencyStatus.rejected;

    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rejected ? Icons.error_outline : Icons.verified_outlined,
                      size: 64,
                      color: rejected
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      rejected
                          ? 'Verification Declined'
                          : 'Verification In Progress',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (rejected)
                      Text(
                        membership?.rejectionReason ??
                            'Your document could not be verified.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      // Community name in the lime accent.
                      Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                                text:
                                    'Congratulations! Your document was uploaded. '
                                    "Verification is in progress — you'll get "
                                    'access to '),
                            TextSpan(
                              text: community.name,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                                text: ' as soon as an admin approves it.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 28),
                    if (rejected) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () =>
                              context.go(Routes.residencyVerification),
                          child: const Text('Resubmit document'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Same style as the Sign out button in the More tab.
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD33A3F),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => ref
                            .read(authControllerProvider.notifier)
                            .signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out'),
                      ),
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
