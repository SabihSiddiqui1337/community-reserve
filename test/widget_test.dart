import 'package:amenry/app/theme/app_colors.dart';
import 'package:amenry/features/community/domain/community.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo community carries sensible branding defaults', () {
    final demo = Community.demo();
    expect(demo.name, isNotEmpty);
    expect(demo.settings.checkInGraceMinutes, 15);
    expect(demo.settings.maxBookingHoursPerWeek, 3);
  });

  test('hexToColor parses branding colors and falls back safely', () {
    expect(hexToColor('#6C5CE7'), const Color(0xFF6C5CE7));
    expect(hexToColor('not-a-color', fallback: const Color(0xFF000000)),
        const Color(0xFF000000));
  });
}
