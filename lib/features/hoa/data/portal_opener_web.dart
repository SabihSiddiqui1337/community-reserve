// dart:html is intentional here — this file is only compiled for web via the
// conditional import in portal_opener.dart.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web: open the portal in a new tab via a programmatic anchor click. Unlike
/// `window.open` (which popup blockers can silently block even from a click),
/// an `<a target="_blank">` click is treated as a user navigation and goes
/// through. The element is attached, clicked, and removed synchronously so the
/// click stays inside the originating user gesture.
Future<bool> openPortal(String url) async {
  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..rel = 'noopener noreferrer';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
