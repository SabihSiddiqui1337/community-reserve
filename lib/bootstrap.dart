import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'app/app.dart';
import 'firebase_options.dart';

/// Host the emulators run on. `10.0.2.2` is the Android emulator's alias for
/// the host machine's `localhost`; everything else uses `127.0.0.1` (the
/// emulators bind to IPv4, and `localhost` can resolve to IPv6 `::1`).
String get _emulatorHost =>
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : '127.0.0.1';

/// App entry pipeline: init timezones + Firebase, wire emulators in debug,
/// then run inside a [ProviderScope]. Errors are caught so a failed Firebase
/// connect (e.g. emulator not running) still boots the UI with demo branding.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      await _connectEmulators();
    }
  } catch (e, s) {
    debugPrint('Firebase init skipped/failed (running with demo data): $e\n$s');
  }

  runApp(const ProviderScope(child: AmenryApp()));
}

/// Wire all emulators BEFORE the app runs. Each service is wired independently
/// so one failure can't block the others, and auth is awaited so no sign-in can
/// race to production identitytoolkit.
Future<void> _connectEmulators() async {
  final host = _emulatorHost;
  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    debugPrint('✓ auth emulator @ $host:9099');
  } catch (e) {
    debugPrint('✗ auth emulator: $e');
  }
  try {
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  } catch (e) {
    debugPrint('✗ firestore emulator: $e');
  }
  try {
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  } catch (e) {
    debugPrint('✗ storage emulator: $e');
  }
  try {
    FirebaseFunctions.instanceFor(region: 'us-central1')
        .useFunctionsEmulator(host, 5001);
  } catch (e) {
    debugPrint('✗ functions emulator: $e');
  }
}
