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
                      rejected ? Icons.error_outline : Icons.hourglass_top,
                      size: 64,
                      color: rejected
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      rejected ? 'Verification declined' : 'Pending review',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rejected
                          ? (membership?.rejectionReason ??
                              'Your document could not be verified.')
                          : 'A ${community.name} admin is reviewing your '
                              'residency document. You\'ll get access as soon '
                              'as it\'s approved.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    if (rejected)
                      FilledButton(
                        onPressed: () =>
                            context.go(Routes.residencyVerification),
                        child: const Text('Resubmit document'),
                      ),
                    TextButton(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                      child: const Text('Sign out'),
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
