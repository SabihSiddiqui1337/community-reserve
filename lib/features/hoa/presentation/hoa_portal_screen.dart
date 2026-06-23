import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_theme.dart';
import '../../community/application/tenant_providers.dart';
import '../data/portal_opener.dart';

/// A thin, embedded WebView that surfaces a community's existing resident
/// portal (e.g. ResMan) inside the app. We do NOT call any portal API, scrape
/// pages, store credentials, or cache page data — this is purely a hosted
/// browser tab. The portal owns auth, payments and statements; we just keep the
/// session alive across launches so residents stay logged in.
///
/// The URL comes from `community.residentPortalUrl`. When it's null/empty the
/// "HOA" tab is hidden upstream, but we render a safe placeholder regardless.
class HoaPortalScreen extends ConsumerStatefulWidget {
  const HoaPortalScreen({super.key});

  @override
  ConsumerState<HoaPortalScreen> createState() => _HoaPortalScreenState();
}

class _HoaPortalScreenState extends ConsumerState<HoaPortalScreen> {
  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefresh;

  double _progress = 0;
  bool _loading = true;
  bool _hasError = false;

  /// Standard mobile-browser UA. Some portals mis-render under the default
  /// WebView UA, so we present as a normal mobile Chrome/Safari client.
  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    // PullToRefresh isn't supported on web/desktop; guard it.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _pullToRefresh = PullToRefreshController(
        settings: PullToRefreshSettings(color: AppTheme.lime),
        onRefresh: () async {
          if (defaultTargetPlatform == TargetPlatform.android) {
            await _controller?.reload();
          } else {
            final url = await _controller?.getUrl();
            if (url != null) {
              await _controller?.loadUrl(urlRequest: URLRequest(url: url));
            }
          }
        },
      );
    }
  }

  String? get _portalUrl {
    final raw = ref.read(activeCommunityProvider).residentPortalUrl?.trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  Future<void> _logoutOfPortal() async {
    final messenger = ScaffoldMessenger.of(context);
    // Clear only this site's session — cookies + web storage. We never clear
    // on dispose, so this menu action is the only way a resident is signed out.
    await CookieManager.instance().deleteAllCookies();
    if (!kIsWeb) {
      try {
        await WebStorageManager.instance().deleteAllData();
      } catch (_) {
        // Not supported on every platform; best-effort.
      }
    }
    await _controller?.reload();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Logged out of resident portal')),
    );
  }

  Future<void> _openInBrowser() async {
    final url = _portalUrl;
    if (url == null) return;
    final messenger = ScaffoldMessenger.of(context);
    var ok = false;
    try {
      // Anchor-click on web (popup-blocker-proof), system browser on native.
      ok = await openPortal(url);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the resident portal.')),
      );
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _loading = true;
    });
    _controller?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(activeCommunityProvider);
    final url = _portalUrl;
    final portalTitle = community.name.isNotEmpty
        ? '${community.name} Portal'
        : 'Resident Portal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final controller = _controller;
        if (controller != null && await controller.canGoBack()) {
          await controller.goBack();
          return;
        }
        if (!mounted) return;
        navigator.maybePop();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // The overflow menu (Log out of portal / Open in browser) only
            // applies to the embedded WebView, which runs on native. On web the
            // fallback screen has its own "Open Portal" button, so hide it.
            if (url != null && !kIsWeb)
              PopupMenuButton<String>(
                color: AppTheme.surface1,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'logout':
                      _logoutOfPortal();
                    case 'browser':
                      _openInBrowser();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Log out of portal'),
                  ),
                  PopupMenuItem(
                    value: 'browser',
                    child: Text('Open in browser'),
                  ),
                ],
              ),
          ],
        ),
        body: url == null
            ? _NotConfigured()
            : kIsWeb
                // On Flutter web the WebView is an <iframe>, and real portals
                // (ResMan etc.) block embedding via X-Frame-Options — so the
                // embedded view only works in the native app. On web we offer a
                // clean "open in a new tab" path instead of a blank frame.
                ? _WebFallback(title: portalTitle, onOpen: _openInBrowser)
                : Column(
                children: [
                  if (_loading && _progress < 1.0)
                    LinearProgressIndicator(
                      value: _progress == 0 ? null : _progress,
                      minHeight: 2,
                      backgroundColor: AppTheme.surface2,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.lime),
                    ),
                  Expanded(
                    child: _hasError
                        ? _ErrorState(onRetry: _retry, onBrowser: _openInBrowser)
                        : _buildWebView(url),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWebView(String url) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      pullToRefreshController: _pullToRefresh,
      initialSettings: InAppWebViewSettings(
        userAgent: _userAgent,
        useOnDownloadStart: true,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: true,
        // Keep the session: don't run as incognito.
        incognito: false,
        cacheEnabled: true,
        // Uploads (camera + gallery) need file access on Android.
        allowFileAccess: true,
        allowContentAccess: true,
        useHybridComposition: true,
        // iOS: let inline media (e.g. camera capture previews) play inline.
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStart: (_, _) {
        if (!mounted) return;
        setState(() {
          _loading = true;
          _hasError = false;
        });
      },
      onLoadStop: (controller, _) async {
        await _pullToRefresh?.endRefreshing();
        if (!mounted) return;
        setState(() => _loading = false);
      },
      onProgressChanged: (_, progress) {
        if (progress == 100) _pullToRefresh?.endRefreshing();
        if (!mounted) return;
        setState(() => _progress = progress / 100.0);
      },
      onReceivedError: (controller, request, error) {
        // Only the main frame failing is a real "page is broken" state;
        // ignore sub-resource failures (ads, trackers, etc.).
        if (request.isForMainFrame ?? false) {
          _pullToRefresh?.endRefreshing();
          if (!mounted) return;
          setState(() {
            _loading = false;
            _hasError = true;
          });
        }
      },
      onReceivedHttpError: (controller, request, response) {
        if (request.isForMainFrame ?? false) {
          _pullToRefresh?.endRefreshing();
          if (!mounted) return;
          setState(() {
            _loading = false;
            _hasError = true;
          });
        }
      },
      // target=_blank / window.open → load in the SAME webview so the
      // authenticated session carries (e.g. payment-processor pop-ups).
      onCreateWindow: (controller, createWindowAction) async {
        final req = createWindowAction.request;
        if (req.url != null) {
          await controller.loadUrl(urlRequest: req);
        }
        return false;
      },
      // Keep navigation inside the webview. Rent-payment flows redirect to
      // third-party processors — ALLOW everything so the session continues.
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        return NavigationActionPolicy.ALLOW;
      },
      onDownloadStartRequest: (controller, request) async {
        // On mobile the platform handles the download natively. On
        // web/desktop fall back to opening the file URL in the system browser.
        if (kIsWeb ||
            (defaultTargetPlatform != TargetPlatform.android &&
                defaultTargetPlatform != TargetPlatform.iOS)) {
          await launchUrl(request.url, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class _NotConfigured extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resident portal not configured',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Web-only: the embedded WebView can't host most resident portals (iframe
/// blocking), so we present a friendly launcher that opens the portal in a new
/// browser tab. The full in-app embedded experience ships on iOS/Android.
class _WebFallback extends StatelessWidget {
  const _WebFallback({required this.title, required this.onOpen});

  final String title;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Pay Rent, View Statements, and Submit Maintenance Requests '
              "in your Community's Resident Portal.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Resident Portal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.onBrowser});

  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load the resident portal",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onBrowser,
              child: const Text('Open in browser'),
            ),
          ],
        ),
      ),
    );
  }
}
