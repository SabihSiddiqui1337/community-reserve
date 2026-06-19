import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/amenities_manager/presentation/amenities_manager_screen.dart';
import '../../features/admin/approvals/presentation/approvals_screen.dart';
import '../../features/admin/branding_editor/presentation/branding_editor_screen.dart';
import '../../features/admin/members/presentation/members_screen.dart';
import '../../features/admin/reports/presentation/reports_screen.dart';
import '../../features/admin/reservations_calendar/presentation/admin_reservations_screen.dart';
import '../../features/admin/settings/presentation/community_settings_screen.dart';
import '../../features/amenities/presentation/amenities_list_screen.dart';
import '../../features/amenities/presentation/amenity_detail_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/reservations/presentation/reservation_detail_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/application/onboarding.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/community/presentation/join_community_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notifications/presentation/inbox_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/waitlist/presentation/waitlist_screen.dart';
import '../../features/residency/presentation/residency_status_screen.dart';
import '../../features/residency/presentation/residency_verification_screen.dart';
import 'routes.dart';

/// App-wide router with an onboarding-gated `redirect`. The redirect reads the
/// [onboardingStageProvider] and keeps the user on the correct screen for their
/// state (signed out → join → verify → pending → home), so they can't deep-link
/// past a gate.
final routerProvider = Provider<GoRouter>((ref) {
  // Refresh routing whenever onboarding state changes.
  final refresh = _ProviderRefresh(ref);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final stage = ref.read(onboardingStageProvider);
      final loc = state.matchedLocation;

      switch (stage) {
        case OnboardingStage.loading:
          return loc == Routes.splash ? null : Routes.splash;
        case OnboardingStage.signedOut:
          return (loc == Routes.signIn || loc == Routes.signUp)
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
          // Allow the status screen and the resubmit form.
          return (loc == Routes.residencyStatus ||
                  loc == Routes.residencyVerification)
              ? null
              : Routes.residencyStatus;
        case OnboardingStage.ready:
          const onboarding = {
            Routes.splash,
            Routes.signIn,
            Routes.signUp,
            Routes.joinCommunity,
            Routes.residencyVerification,
            Routes.residencyStatus,
          };
          return onboarding.contains(loc) ? Routes.home : null;
      }
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
          path: Routes.joinCommunity,
          builder: (_, _) => const JoinCommunityScreen()),
      GoRoute(
          path: Routes.residencyVerification,
          builder: (_, _) => const ResidencyVerificationScreen()),
      GoRoute(
          path: Routes.residencyStatus,
          builder: (_, _) => const ResidencyStatusScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),

      // Resident
      GoRoute(
          path: Routes.amenities,
          builder: (_, _) => const AmenitiesListScreen()),
      GoRoute(
        path: Routes.amenityDetail,
        builder: (_, state) => AmenityDetailScreen(
            amenityId: state.pathParameters['amenityId']!),
      ),
      GoRoute(
        path: Routes.booking,
        builder: (_, state) =>
            BookingScreen(amenityId: state.pathParameters['amenityId']!),
      ),
      GoRoute(
        path: Routes.reservationDetail,
        builder: (_, state) => ReservationDetailScreen(
            reservationId: state.pathParameters['reservationId']!),
      ),
      GoRoute(path: Routes.waitlist, builder: (_, _) => const WaitlistScreen()),
      GoRoute(path: Routes.inbox, builder: (_, _) => const InboxScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),

      // Admin
      GoRoute(
          path: Routes.admin, builder: (_, _) => const AdminDashboardScreen()),
      GoRoute(
          path: Routes.adminApprovals,
          builder: (_, _) => const ApprovalsScreen()),
      GoRoute(
          path: Routes.adminAmenities,
          builder: (_, _) => const AmenitiesManagerScreen()),
      GoRoute(
          path: Routes.adminReservations,
          builder: (_, _) => const AdminReservationsScreen()),
      GoRoute(
          path: Routes.adminReports,
          builder: (_, _) => const ReportsScreen()),
      GoRoute(
          path: Routes.adminBranding,
          builder: (_, _) => const BrandingEditorScreen()),
      GoRoute(
          path: Routes.adminSettings,
          builder: (_, _) => const CommunitySettingsScreen()),
      GoRoute(
          path: Routes.adminMembers,
          builder: (_, _) => const MembersScreen()),
    ],
  );
});

/// Bridges Riverpod state changes to GoRouter's [Listenable] refresh.
class _ProviderRefresh extends ChangeNotifier {
  _ProviderRefresh(Ref ref) {
    ref.listen(onboardingStageProvider, (_, _) => notifyListeners());
  }
}
