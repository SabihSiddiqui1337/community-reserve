import 'package:url_launcher/url_launcher.dart';

/// Native: open the portal in the system browser.
Future<bool> openPortal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
