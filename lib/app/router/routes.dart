/// Centralized route paths/names. Screens land phase by phase; later phases
/// fill in the amenity/booking/admin sub-routes.
class Routes {
  const Routes._();

  static const splash = '/';
  static const home = '/home';

  // Auth & onboarding (Phase 1)
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const joinCommunity = '/join';
  static const residencyVerification = '/residency';
  static const residencyStatus = '/residency-status';

  // Resident (Phase 2+)
  static const amenities = '/amenities';
  static const amenityDetail = '/amenities/:amenityId';
  static const booking = '/book/:amenityId';
  static const reservationDetail = '/reservation/:reservationId';
  static const waitlist = '/waitlist';
  static const inbox = '/inbox';
  static const profile = '/profile';

  static String amenityDetailTo(String id) => '/amenities/$id';
  static String bookingTo(String amenityId) => '/book/$amenityId';
  static String reservationTo(String id) => '/reservation/$id';

  // Admin (Phase 1 approvals; Phase 6 the rest)
  static const admin = '/admin';
  static const adminApprovals = '/admin/approvals';
  static const adminAmenities = '/admin/amenities';
  static const adminReservations = '/admin/reservations';
  static const adminReports = '/admin/reports';
  static const adminBranding = '/admin/branding';
  static const adminMembers = '/admin/members';
  static const adminSettings = '/admin/settings';
}
