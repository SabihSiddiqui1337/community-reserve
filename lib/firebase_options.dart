import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// PLACEHOLDER options for the **Firebase Emulator Suite** only.
///
/// The project id `demo-amenry` is a Firebase *demo project*: the emulators
/// accept it and it can never touch a real Firebase backend, so these dummy
/// credentials are safe to commit. When you're ready to go live, run
/// `flutterfire configure` and it will overwrite this file with real values.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _demo;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _ios;
      case TargetPlatform.android:
        return _demo;
      default:
        return _demo;
    }
  }

  static const FirebaseOptions _demo = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:demoamenry0000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-amenry',
    storageBucket: 'demo-amenry.appspot.com',
  );

  /// iOS/macOS need an iOS-format `appId` (`...:ios:<hex>`), a matching bundle
  /// id, and an `apiKey` in Google's real format (39 chars, starts with `A`).
  /// The native FirebaseCore + FirebaseInstallations SDKs validate all three
  /// and abort the app at launch otherwise — even when only the emulators are
  /// used. These are still dummy values that can never reach a real backend.
  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'AIzaSyDEMOamenryDEMOamenryDEMOamenry123',
    appId: '1:123456789012:ios:0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'demo-amenry',
    storageBucket: 'demo-amenry.appspot.com',
    iosBundleId: 'com.amenry.amenry',
  );
}
