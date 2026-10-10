import 'package:budget_planner/utils/app_assets.dart';
import 'package:budget_planner/widget/app_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Proves the assets actually reach the screen.
///
/// [AppSvg] falls back to a soft block when a file is absent, which is exactly
/// what made the login screen render an empty square. These tests assert the
/// real SVG is picked for every declared asset, and that the fallback still
/// works for one that genuinely is not there.
void main() {
  Future<void> show(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(harness(child));
    // The existence probe is async, so the first frame is always the fallback.
    await tester.pumpAndSettle();
  }

  const Map<String, String> assets = <String, String>{
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

  for (final MapEntry<String, String> entry in assets.entries) {
    testWidgets('${entry.key} renders as a real SVG, not the fallback',
        (WidgetTester tester) async {
      await show(tester, AppSvg(entry.value, width: 64, height: 64));

      expect(
        find.byType(SvgPicture),
        findsOneWidget,
        reason: '${entry.value} fell back to the placeholder',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a missing asset falls back instead of throwing',
      (WidgetTester tester) async {
    await show(
      tester,
      const AppSvg('assets/icons/not_a_real_file.svg', width: 64, height: 64),
    );

    expect(find.byType(SvgPicture), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('honours the size it is given', (WidgetTester tester) async {
    await show(tester, const AppSvg(AppAssets.logo, width: 120, height: 90));
    expect(tester.getSize(find.byType(AppSvg)), const Size(120, 90));
  });

  testWidgets('a tint is applied as a colour filter',
      (WidgetTester tester) async {
    await show(
      tester,
      const AppSvg(
        AppAssets.icClose,
        width: 24,
        height: 24,
        color: Color(0xFFFF0000),
      ),
    );

    final SvgPicture picture = tester.widget<SvgPicture>(
      find.byType(SvgPicture),
    );
    expect(picture.colorFilter, isNotNull);
  });
}
