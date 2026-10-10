import 'dart:io';

import 'package:budget_planner/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps the palette the single source of colour.
///
/// The token file is only worth anything if nothing bypasses it. These tests
/// read the source of every screen and widget and fail on a colour written
/// inline, so that when the exact Figma palette lands, editing AppColors is
/// genuinely enough to retheme the app.
void main() {
  List<File> dartFilesUnder(String path) => Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  group('no colour is written inline', () {
    /// A literal ARGB value. AppColors is where these belong.
    final RegExp hexLiteral = RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)');

    /// The named Material colours, which carry their own palette and would
    /// quietly diverge from the design.
    final RegExp materialNamed = RegExp(
      r'\bColors\.(red|blue|green|purple|indigo|orange|amber|pink|teal|cyan|'
      r'lime|yellow|brown|grey|gray|deepPurple|deepOrange|lightBlue|'
      r'lightGreen|blueGrey)\b',
    );

    test('screens use only AppColors', () {
      for (final File file in dartFilesUnder('lib/screen')) {
        final String source = file.readAsStringSync();
        expect(
          hexLiteral.hasMatch(source),
          isFalse,
          reason: '${file.path} hardcodes an ARGB value',
        );
        expect(
          materialNamed.hasMatch(source),
          isFalse,
          reason: '${file.path} uses a named Material colour',
        );
      }
    });

    test('shared widgets use only AppColors', () {
      for (final File file in dartFilesUnder('lib/widget')) {
        final String source = file.readAsStringSync();
        expect(
          hexLiteral.hasMatch(source),
          isFalse,
          reason: '${file.path} hardcodes an ARGB value',
        );
        expect(
          materialNamed.hasMatch(source),
          isFalse,
          reason: '${file.path} uses a named Material colour',
        );
      }
    });

    test('the palette itself is the one file that may hold literals', () {
      final String source = File('lib/utils/app_colors.dart').readAsStringSync();
      expect(hexLiteral.hasMatch(source), isTrue);
    });
  });

  group('the theme is wired to the palette', () {
    test('every token is fully opaque, since the design has no transparency',
        () {
      const Map<String, Color> opaque = <String, Color>{
        'primary': AppColors.primary,
        'background': AppColors.background,
        'surface': AppColors.surface,
        'textPrimary': AppColors.textPrimary,
        'textOnPrimary': AppColors.textOnPrimary,
        'expense': AppColors.expense,
        'income': AppColors.income,
        'danger': AppColors.danger,
      };
      opaque.forEach((String name, Color color) {
        expect(color.a, 1.0, reason: '$name is not opaque');
      });
    });

    test('the scrim and the two soft shadows are translucent', () {
      expect(AppColors.scrim.a, lessThan(1.0));
      expect(AppColors.shadowSoft.a, lessThan(1.0));
      expect(AppColors.shadowHairline.a, lessThan(1.0));
    });

    test('the card shadow is opaque, as Figma stores it', () {
      expect(
        AppColors.shadow.a,
        1.0,
        reason: 'the design relies on the blur, not on alpha, to soften it',
      );
    });

    test('surfaces are distinguishable from the background', () {
      expect(AppColors.surfaceMuted, isNot(AppColors.background));
      expect(AppColors.surfaceTinted, isNot(AppColors.background));
      expect(AppColors.surfaceMuted, isNot(AppColors.surfaceTinted));
    });

    test('the tinted surface leans towards the brand hue', () {
      expect(
        AppColors.surfaceTinted.b,
        greaterThan(AppColors.surfaceTinted.g),
        reason: 'it should read as a pale indigo, not a neutral grey',
      );
    });

    test('danger and its surface are a light-on-dark pair', () {
      expect(
        AppColors.dangerSurface.computeLuminance(),
        greaterThan(AppColors.danger.computeLuminance()),
      );
    });

    test('warning and its surface are a light-on-dark pair', () {
      expect(
        AppColors.warningSurface.computeLuminance(),
        greaterThan(AppColors.warning.computeLuminance()),
      );
    });

    test('the donut track is lighter than the arc that fills it', () {
      expect(
        AppColors.track.computeLuminance(),
        greaterThan(AppColors.primary.computeLuminance()),
      );
    });

    test('the disabled button is lighter than the live one', () {
      expect(
        AppColors.primaryDisabled.computeLuminance(),
        greaterThan(AppColors.primary.computeLuminance()),
        reason: 'the Figma "Disactive" state is a washed-out primary',
      );
    });
  });
}
