import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/community/application/tenant_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget. Watches the active community and rebuilds the entire app theme
/// from its branding — so the same binary reskins per tenant at runtime.
class AmenryApp extends ConsumerWidget {
  const AmenryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(activeCommunityProvider);
    final router = ref.watch(routerProvider);
    final branding = community.branding;

    return MaterialApp.router(
      title: 'Amenry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(branding),
      darkTheme: AppTheme.dark(branding),
      themeMode: AppTheme.modeFor(branding),
      routerConfig: router,
      // Mobile-first: on wide screens (desktop browser), cap the app to a
      // phone width and align it to the left, instead of stretching edge-to-edge.
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFF08080B),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
