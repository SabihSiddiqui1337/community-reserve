// Opens the resident-portal URL in a new tab (web) or the system browser
// (native). Web uses an anchor-element navigation so popup blockers — which
// silently kill `window.open` even from a click — don't stop it. Native uses
// url_launcher. Platform-specific implementation is picked at compile time.
export 'portal_opener_io.dart'
    if (dart.library.html) 'portal_opener_web.dart';
