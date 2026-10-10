import 'package:budget_planner/utils/app_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks that the asset layer is coherent.
///
/// The illustrations and icons are exported from Figma by
/// `tool/figma_assets.py`, which may not have run yet. So these tests assert
/// the things that must hold either way -- paths well formed, no duplicates,
/// all under a declared directory -- and then report, without failing, how
/// many files are actually present. The one that does fail on a missing file
/// is guarded so it only runs once the export has happened.
void main() {
  /// Every path AppAssets exposes, paired with the constant's name.
  const Map<String, String> declared = <String, String>{
    'logo': AppAssets.logo,
    'icBudget': AppAssets.icBudget,
    'icDone': AppAssets.icDone,
    'icUsers': AppAssets.icUsers,
    'icArrowLeftDark': AppAssets.icArrowLeftDark,
    'icArrowLittle': AppAssets.icArrowLittle,
    'icClose': AppAssets.icClose,
    'icShareDark': AppAssets.icShareDark,
    'icOther': AppAssets.icOther,
    'icInfo': AppAssets.icInfo,
    'icLanguage': AppAssets.icLanguage,
    'icLogout': AppAssets.icLogout,
    'icDeleteForever': AppAssets.icDeleteForever,
    'icPersonRemove': AppAssets.icPersonRemove,
    'icSettings': AppAssets.icSettings,
    'icAddCircle': AppAssets.icAddCircle,
    'icSearch': AppAssets.icSearch,
    'onboarding0': AppAssets.onboarding0,
    'onboarding1': AppAssets.onboarding1,
    'onboarding2': AppAssets.onboarding2,
    'articleHero': AppAssets.articleHero,
  };

  group('asset paths', () {
    test('every path sits under a directory pubspec declares', () {
      for (final MapEntry<String, String> entry in declared.entries) {
        expect(
          entry.value.startsWith('assets/icons/') ||
              entry.value.startsWith('assets/images/'),
          isTrue,
          reason: '${entry.key} points outside the declared asset roots',
        );
      }
    });

    test('no two constants point at the same file', () {
      final Set<String> seen = <String>{};
      for (final MapEntry<String, String> entry in declared.entries) {
        expect(
          seen.add(entry.value),
          isTrue,
          reason: '${entry.key} duplicates an earlier path',
        );
      }
    });

    test('names are lower snake case, matching the exporter slug', () {
      final RegExp slug = RegExp(r'^assets/(icons|images)/[a-z0-9_]+\.(svg|png)$');
      for (final MapEntry<String, String> entry in declared.entries) {
        expect(
          slug.hasMatch(entry.value),
          isTrue,
          reason: '${entry.key} is "${entry.value}", which '
              'tool/figma_assets.py would never produce',
        );
      }
    });

    test('article thumbnails reuse the onboarding illustrations', () {
      expect(AppAssets.articleThumbnails, hasLength(3));
      for (final String path in AppAssets.articleThumbnails) {
        expect(declared.values, contains(path));
      }
    });
  });

  group('bundled files', () {
    /// Asks the bundle for the asset itself rather than reading the manifest.
    /// The manifest moved to a binary format, so loading it by name in a test
    /// silently yields nothing and every asset looks absent.
    Future<bool> isBundled(String path) async {
      try {
        final ByteData data = await rootBundle.load(path);
        return data.lengthInBytes > 0;
      } on FlutterError {
        return false;
      }
    }

    test('every declared asset resolves and is non-empty', () async {
      final List<String> missing = <String>[];
      for (final MapEntry<String, String> entry in declared.entries) {
        if (!await isBundled(entry.value)) missing.add(entry.key);
      }

      expect(
        missing,
        isEmpty,
        reason: 'not in the bundle: ${missing.join(', ')}',
      );
    });

    test('an undeclared path really does fail to load', () async {
      expect(
        await isBundled('assets/icons/definitely_not_here.svg'),
        isFalse,
        reason: 'the check would pass vacuously otherwise',
      );
    });
  });
}
