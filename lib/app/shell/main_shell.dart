import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/community/application/tenant_providers.dart';
import '../../features/notifications/data/fcm_service.dart';

/// Branch indices into the StatefulShellRoute (fixed order).
class _Branch {
  static const events = 0;
  static const book = 1;
  static const bookings = 2;
  static const admin = 3;
  static const profile = 4;
}

class _Tab {
  const _Tab(this.branch, this.icon, this.activeIcon, this.label);
  final int branch;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _residentTabs = <_Tab>[
  _Tab(_Branch.events, Icons.campaign_outlined, Icons.campaign, 'Events'),
  _Tab(_Branch.book, Icons.add_circle_outline, Icons.add_circle, 'Book'),
  _Tab(_Branch.bookings, Icons.confirmation_number_outlined,
      Icons.confirmation_number, 'My Bookings'),
  _Tab(_Branch.profile, Icons.person_outline, Icons.person, 'Profile'),
];

const _adminTabs = <_Tab>[
  _Tab(_Branch.events, Icons.campaign_outlined, Icons.campaign, 'Events'),
  _Tab(_Branch.book, Icons.add_circle_outline, Icons.add_circle, 'Book'),
  _Tab(_Branch.bookings, Icons.confirmation_number_outlined,
      Icons.confirmation_number, 'My Bookings'),
  _Tab(_Branch.admin, Icons.shield_outlined, Icons.shield, 'Admin'),
  _Tab(_Branch.profile, Icons.person_outline, Icons.person, 'Profile'),
];

/// App shell: persistent bottom navigation that stays visible across screens.
/// The Admin tab only appears for community admins.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    ref.watch(fcmRegistrationProvider); // best-effort push registration
    final tabs = isAdmin ? _adminTabs : _residentTabs;

    var selected = tabs.indexWhere((t) => t.branch == navigationShell.currentIndex);
    if (selected < 0) selected = 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => navigationShell.goBranch(
          tabs[i].branch,
          initialLocation: tabs[i].branch == navigationShell.currentIndex,
        ),
        destinations: [
          for (final t in tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.activeIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
