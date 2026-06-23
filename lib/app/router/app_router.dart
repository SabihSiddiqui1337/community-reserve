import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/amenities_manager/presentation/amenities_manager_screen.dart';
import '../../features/admin/approvals/presentation/approvals_screen.dart';
import '../../features/admin/branding_editor/presentation/branding_editor_screen.dart';
import '../../features/admin/members/presentation/members_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/reports/presentation/reports_screen.dart';
import '../../features/admin/reservations_calendar/presentation/admin_reservations_screen.dart';
import '../../features/admin/settings/presentation/community_settings_screen.dart';
import '../../features/auth/application/onboarding.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/booking/presentation/checkout_screen.dart';
import '../../features/booking/presentation/event_request_screen.dart';
import '../../features/booking/presentation/slot_screen.dart';
import '../../features/booking/presentation/sport_picker_screen.dart';
import '../../features/community/presentation/join_community_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/hoa/presentation/hoa_portal_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/payments/presentation/payment_info_screen.dart';
import '../../features/profile/presentation/account_info_screen.dart';
import '../../features/profile/presentation/account_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reservations/presentation/my_bookings_screen.dart';
import '../../features/reservations/presentation/reservation_deeplink_screen.dart';
import '../../features/residency/presentation/residency_status_screen.dart';
import '../../features/residency/presentation/residency_verification_screen.dart';
import '../shell/main_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// App-wide router: onboarding-gated, then a persistent bottom-nav shell with
/// five branches (Events · Book · My Bookings · Admin · Profile).
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _ProviderRefresh(ref);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final stage = ref.read(onboardingStageProvider);
      final loc = state.matchedLocation;
      const onboarding = {
        Routes.splash,
        Routes.signIn,
        Routes.signUp,
        Routes.joinCommunity,
        Routes.residencyVerification,
        Routes.residencyStatus,
      };

      switch (stage) {
        case OnboardingStage.loading:
          return loc == Routes.splash ? null : Routes.splash;
        case OnboardingStage.signedOut:
          return (loc == Routes.signIn ||
                  loc == Routes.signUp ||
                  loc == Routes.forgotPassword)
              ? null
              : Routes.signIn;
        case OnboardingStage.needsCommunity:
          return loc == Routes.joinCommunity ? null : Routes.joinCommunity;
        case OnboardingStage.needsResidency:
          return loc == Routes.residencyVerification
              ? null
              : Routes.residencyVerification;
        case OnboardingStage.pendingReview:
          return loc == Routes.residencyStatus ? null : Routes.residencyStatus;
        case OnboardingStage.rejected:
          return (loc == Routes.residencyStatus ||
                  loc == Routes.residencyVerification)
              ? null
              : Routes.residencyStatus;
        case OnboardingStage.ready:
          return onboarding.contains(loc) ? Routes.events : null;
      }
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      // No transition between Login/Sign up so the tab toggle just swaps.
      GoRoute(
          path: Routes.signIn,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: SignInScreen())),
      GoRoute(
          path: Routes.signUp,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: SignUpScreen())),
      GoRoute(
          path: Routes.forgotPassword,
          builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
          path: Routes.joinCommunity,
          builder: (_, _) => const JoinCommunityScreen()),
      GoRoute(
          path: Routes.residencyVerification,
          builder: (_, _) => const ResidencyVerificationScreen()),
      GoRoute(
          path: Routes.residencyStatus,
          builder: (_, _) => const ResidencyStatusScreen()),

      // ---- Main app shell with persistent bottom navigation ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // 0 — Events
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.events, builder: (_, _) => const EventsScreen()),
          ]),
          // 1 — Book
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.book,
              builder: (_, _) => const SportPickerScreen(),
              routes: [
                GoRoute(
                  path: 'slots/:amenityId',
                  builder: (_, state) =>
                      SlotScreen(amenityId: state.pathParameters['amenityId']!),
                ),
              ],
            ),
          ]),
          // 2 — My Bookings
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.myBookings,
              builder: (_, _) => const MyBookingsScreen(),
            ),
          ]),
          // 3 — Admin
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.admin,
              builder: (_, _) => const AdminDashboardScreen(),
              routes: [
                GoRoute(
                    path: 'approvals',
                    builder: (_, _) => const ApprovalsScreen()),
                GoRoute(
                    path: 'amenities',
                    builder: (_, _) => const AmenitiesManagerScreen()),
                GoRoute(
                    path: 'reservations',
                    builder: (_, _) => const AdminReservationsScreen()),
                GoRoute(
                    path: 'reports', builder: (_, _) => const ReportsScreen()),
                GoRoute(
                    path: 'branding',
                    builder: (_, _) => const BrandingEditorScreen()),
                GoRoute(
                    path: 'settings',
                    builder: (_, _) => const CommunitySettingsScreen()),
                GoRoute(
                    path: 'members',
                    builder: (_, _) => const MembersScreen()),
              ],
            ),
          ]),
          // 4 — More (was Profile; Admin now lives as a row inside here)
          StatefulShellBranch(routes: [
            GoRoute(
                path: Routes.more, builder: (_, _) => const ProfileScreen()),
          ]),
          // 5 — HOA resident portal (embedded WebView). Hidden as a tab when
          // the community has no residentPortalUrl, but routable.
          StatefulShellBranch(routes: [
            GoRoute(
                path: Routes.hoa, builder: (_, _) => const HoaPortalScreen()),
          ]),
        ],
      ),

      GoRoute(
          path: Routes.notifications,
          builder: (_, _) => const NotificationsScreen()),
      GoRoute(
          path: Routes.reservationDetail,
          builder: (_, state) => ReservationDeepLinkScreen(
              reservationId: state.pathParameters['id']!)),

      // Account pages — full screen (no bottom tab bar), reached from Profile.
      GoRoute(path: Routes.account, builder: (_, _) => const AccountScreen()),
      GoRoute(
          path: Routes.accountInfo,
          builder: (_, _) => const AccountInfoScreen()),
      GoRoute(
          path: Routes.editProfile,
          builder: (_, _) => const EditProfileScreen()),
      GoRoute(
          path: Routes.paymentInfo,
          builder: (_, _) => const PaymentInfoScreen()),

      // Checkout — full screen (no bottom tab bar), matching the reference.
      GoRoute(
        path: Routes.bookCheckout,
        builder: (_, state) => CheckoutScreen(
          amenityId: state.pathParameters['amenityId']!,
          start: DateTime.parse(state.uri.queryParameters['start']!).toLocal(),
          end: DateTime.parse(state.uri.queryParameters['end']!).toLocal(),
        ),
      ),
      // Event reservation request — full screen form.
      GoRoute(
        path: Routes.eventRequest,
        builder: (_, state) => EventRequestScreen(
          amenityId: state.pathParameters['amenityId']!,
          start: DateTime.parse(state.uri.queryParameters['start']!).toLocal(),
          end: DateTime.parse(state.uri.queryParameters['end']!).toLocal(),
        ),
      ),
    ],
  );
});

/// Bridges Riverpod state changes to GoRouter's refresh.
class _ProviderRefresh extends ChangeNotifier {
  _ProviderRefresh(Ref ref) {
    ref.listen(onboardingStageProvider, (_, _) => notifyListeners());
  }
}
