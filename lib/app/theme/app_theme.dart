import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/community/domain/community.dart';
import 'app_colors.dart';

/// Builds Material 3 [ThemeData] from a tenant's [Branding]. This is the heart
/// of the white-label system: the *same* app reskins per community because the
/// theme is derived from data loaded at runtime, never hardcoded.
class AppTheme {
  const AppTheme._();

  static ThemeData dark(Branding branding) =>
      _build(branding, Brightness.dark);

  static ThemeData light(Branding branding) =>
      _build(branding, Brightness.light);

  /// The brightness a community prefers by default (`branding.theme`).
  static ThemeMode modeFor(Branding branding) =>
      branding.theme == 'light' ? ThemeMode.light : ThemeMode.dark;

  static ThemeData _build(Branding branding, Brightness brightness) {
    final primary = hexToColor(branding.primaryColor);
    final accent = hexToColor(branding.accentColor);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: accent,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true);

    // Cool obsidian for dark mode — a near-black canvas that lets the electric
    // accent pop, modern and premium rather than warm/gold.
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF0A0A0F) : scheme.surface;

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
      ),
      navigationBarTheme: isDark
          ? NavigationBarThemeData(
              backgroundColor: const Color(0xFF101017),
              elevation: 0,
              indicatorColor: scheme.primary.withValues(alpha: 0.20),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: states.contains(WidgetState.selected)
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
