/// Centralized route paths. The app uses a persistent bottom-nav shell with
/// five branches (Events, Book, My Bookings, Admin, Profile).
class Routes {
  const Routes._();

  static const splash = '/';

  // Auth & onboarding
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const joinCommunity = '/join';
  static const residencyVerification = '/residency';
  static const residencyStatus = '/residency-status';

  // Shell tabs
  static const events = '/events';
  static const book = '/book';
  static const myBookings = '/bookings';
  static const profile = '/profile';

  // Book flow (within the Book branch)
  static const bookSlots = '/book/slots/:amenityId';
  static const bookCheckout = '/book/checkout/:amenityId';
  static String bookSlotsTo(String amenityId) => '/book/slots/$amenityId';
  static String bookCheckoutTo(String amenityId,
          {required String start, required String end}) =>
      '/book/checkout/$amenityId?start=${Uri.encodeComponent(start)}&end=${Uri.encodeComponent(end)}';

  // Reservation detail (within the My Bookings branch)
  static const reservationDetail = '/bookings/reservation/:reservationId';
  static String reservationTo(String id) => '/bookings/reservation/$id';

  // Admin (within the Admin branch)
  static const admin = '/admin';
  static const adminApprovals = '/admin/approvals';
  static const adminAmenities = '/admin/amenities';
  static const adminReservations = '/admin/reservations';
  static const adminReports = '/admin/reports';
  static const adminBranding = '/admin/branding';
  static const adminMembers = '/admin/members';
  static const adminSettings = '/admin/settings';
}
