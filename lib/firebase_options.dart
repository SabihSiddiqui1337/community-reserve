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
      case TargetPlatform.android:
      case TargetPlatform.iOS:
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
}
