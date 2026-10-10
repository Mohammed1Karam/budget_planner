import 'package:budget_planner/utils/app_colors.dart';
import 'package:budget_planner/utils/app_dimens.dart';
import 'package:budget_planner/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Material fillOf(WidgetTester tester) => tester.widget<Material>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Material),
            )
            .first,
      );

  testWidgets('is the design height', (WidgetTester tester) async {
    await tester.pumpWidget(harness(const PrimaryButton(label: 'Save')));
    final Size size = tester.getSize(find.byType(PrimaryButton));
    expect(size.height, AppDimens.buttonHeight);
  });

  testWidgets('fills with primary and fires when enabled',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      harness(PrimaryButton(label: 'Save', onPressed: () => taps++)),
    );

    expect(fillOf(tester).color, AppColors.primary);
    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('falls back to the disabled fill and ignores taps',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(const PrimaryButton(label: 'Save')));

    expect(fillOf(tester).color, AppColors.primaryDisabled);
    await tester.tap(find.text('Save'));
    // Nothing to assert beyond not throwing: a null callback is a no-op.
  });

  testWidgets('swaps the label for a spinner while loading',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      harness(PrimaryButton(label: 'Save', loading: true, onPressed: () {})),
    );

    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a loading button does not fire', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      harness(
        PrimaryButton(label: 'Save', loading: true, onPressed: () => taps++),
      ),
    );

    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 0);
  });
}
