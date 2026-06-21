import 'package:flutter/material.dart';

/// A subtle, premium gradient backdrop derived from the active theme's primary
/// and secondary colors. Used behind onboarding screens to reinforce the
/// per-tenant branding.
class BrandedBackground extends StatelessWidget {
  const BrandedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            Color.alphaBlend(scheme.primary.withValues(alpha: 0.10), scheme.surface),
            Color.alphaBlend(scheme.secondary.withValues(alpha: 0.08), scheme.surface),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Rounded gradient logo tile showing the community initial. Stands in for a
/// real logo until `branding.logoUrl` is set.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.label, this.size = 64});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : '?',
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
