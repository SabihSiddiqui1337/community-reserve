import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/community/domain/community.dart';

/// Fixed modern-dark theme: near-black canvas, white text, electric-lime accent
/// (the look from the reference). Branding-driven colors were removed, so the
/// app no longer reskins per tenant — these are the single source of truth.
class AppTheme {
  const AppTheme._();

  // Core palette.
  static const lime = Color(0xFFC8FA4B); // electric lime accent
  static const onLime = Color(0xFF0A0A0A); // text/icons on lime
  static const black = Color(0xFF0A0A0A); // scaffold background
  static const surface1 = Color(0xFF15171C); // cards
  static const surface2 = Color(0xFF1C1F26); // inputs / raised
  static const outline = Color(0xFF2A2E37);
  static const muted = Color(0xFF9BA1AC);

  // Signatures kept so existing callers compile; branding is ignored.
  static ThemeData dark(Branding branding) => _build();
  static ThemeData light(Branding branding) => _build();
  static ThemeMode modeFor(Branding branding) => ThemeMode.dark;

  static ThemeData _build() {
    const scheme = ColorScheme.dark(
      primary: lime,
      onPrimary: onLime,
      secondary: lime,
      onSecondary: onLime,
      surface: black,
      onSurface: Colors.white,
      surfaceContainerHighest: surface2,
      surfaceContainerHigh: surface1,
      surfaceContainer: surface1,
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: Color(0xFF20242C),
      inverseSurface: Colors.white,
      onInverseSurface: black,
      error: Color(0xFFFF6B6B),
      primaryContainer: Color(0xFF273A12),
      onPrimaryContainer: lime,
      secondaryContainer: Color(0xFF273A12),
      onSecondaryContainer: lime,
    );

    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: black,
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lime,
          foregroundColor: onLime,
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: outline),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: lime),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface1,
        surfaceTintColor: Colors.transparent,
      ),
      // Toasts: a dark floating pill (not the default white inverse-surface),
      // lifted above the floating nav, with lime action text.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface2,
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        actionTextColor: lime,
        elevation: 8,
        // Floating already lifts above the nav/FAB; keep a small margin so it
        // sits at the bottom (not pushed toward the middle).
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lime, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF20242C)),
    );
  }
}
