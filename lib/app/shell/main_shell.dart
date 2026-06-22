import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/community_chat_sheet.dart';
import '../../features/community/application/tenant_providers.dart';
import '../../features/notifications/data/fcm_service.dart';
import '../theme/app_theme.dart';

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
      Icons.confirmation_number, 'Bookings'),
  _Tab(_Branch.profile, Icons.person_outline, Icons.person, 'Profile'),
];

const _adminTabs = <_Tab>[
  _Tab(_Branch.events, Icons.campaign_outlined, Icons.campaign, 'Events'),
  _Tab(_Branch.book, Icons.add_circle_outline, Icons.add_circle, 'Book'),
  _Tab(_Branch.bookings, Icons.confirmation_number_outlined,
      Icons.confirmation_number, 'Bookings'),
  _Tab(_Branch.admin, Icons.shield_outlined, Icons.shield, 'Admin'),
  _Tab(_Branch.profile, Icons.person_outline, Icons.person, 'Profile'),
];

/// App shell: a floating, animated bottom navigation pill (the highlight slides
/// to the selected tab). The Admin tab only appears for community admins.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    ref.watch(fcmRegistrationProvider); // best-effort push registration
    final tabs = isAdmin ? _adminTabs : _residentTabs;

    var selected =
        tabs.indexWhere((t) => t.branch == navigationShell.currentIndex);
    if (selected < 0) selected = 0;

    // Community Chat is reachable from the main content tabs.
    final showChat = navigationShell.currentIndex == _Branch.events ||
        navigationShell.currentIndex == _Branch.book ||
        navigationShell.currentIndex == _Branch.bookings;

    return Scaffold(
      // Body stops above the floating nav so screen content, bottom action
      // bars (e.g. the Book "Reserve" bar) and FABs aren't covered by it.
      extendBody: false,
      body: navigationShell,
      floatingActionButton: showChat
          ? _ChatFab(onTap: () => showCommunityChat(context, ref))
          : null,
      bottomNavigationBar: _FloatingNav(
        tabs: tabs,
        selected: selected,
        onSelect: (i) => navigationShell.goBranch(
          tabs[i].branch,
          initialLocation: tabs[i].branch == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Dark circular Community-Chat button with a small unread dot (IMG 1552).
class _ChatFab extends StatelessWidget {
  const _ChatFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F26),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2A2E37)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.forum_outlined, color: Colors.white, size: 24),
            Positioned(
              top: 14,
              right: 15,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: AppTheme.lime,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1C1F26), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<_Tab> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final n = tabs.length;
    // Highlight pill alignment slides between -1 (first) and 1 (last).
    final align = n > 1 ? (selected / (n - 1)) * 2 - 1 : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF15171C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF24272F)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding lime highlight behind the selected tab.
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(align, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lime,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(
                      child: _NavItem(
                        tab: tabs[i],
                        active: i == selected,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.tab, required this.active, required this.onTap});
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.onLime : AppTheme.muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? tab.activeIcon : tab.icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 10.5,
              height: 1,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
