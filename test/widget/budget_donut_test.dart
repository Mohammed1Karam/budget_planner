import 'package:budget_planner/utils/app_dimens.dart';
import 'package:budget_planner/widget/budget_donut.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('arithmetic', () {
    test('half the limit spent is half the ring', () {
      const BudgetDonut donut =
          BudgetDonut(spent: 250, limit: 500, currencySymbol: r'$');
      expect(donut.progress, 0.5);
      expect(donut.remaining, 250);
      expect(donut.isOverLimit, isFalse);
    });

    test('spending exactly the limit fills it and trips the flag', () {
      const BudgetDonut donut =
          BudgetDonut(spent: 500, limit: 500, currencySymbol: r'$');
      expect(donut.progress, 1.0);
      expect(donut.isOverLimit, isTrue);
      expect(donut.remaining, 0);
    });

    test('an overspend clamps rather than wrapping past the ring', () {
      const BudgetDonut donut =
          BudgetDonut(spent: 900, limit: 500, currencySymbol: r'$');
      expect(donut.progress, 1.0);
      expect(donut.remaining, 0);
    });

    test('no limit set means no progress and no warning', () {
      const BudgetDonut donut =
          BudgetDonut(spent: 120, limit: 0, currencySymbol: r'$');
      expect(donut.progress, 0);
      expect(donut.isOverLimit, isFalse);
    });

    test('nothing spent leaves the whole limit', () {
      const BudgetDonut donut =
          BudgetDonut(spent: 0, limit: 500, currencySymbol: r'$');
      expect(donut.progress, 0);
      expect(donut.remaining, 500);
    });
  });

  group('rendering', () {
    testWidgets('is the Figma size and shows both figures',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          const BudgetDonut(spent: 765, limit: 2032, currencySymbol: r'$'),
        ),
      );

      expect(
        tester.getSize(find.byType(BudgetDonut)),
        const Size(AppDimens.donutSize, AppDimens.donutSize),
      );
      expect(find.text(r'$ 765'), findsOneWidget);
      expect(find.text('spent today'), findsOneWidget);
      expect(find.text('balance for today'), findsOneWidget);
      expect(find.text(r'$ 1,267'), findsOneWidget);
    });

    testWidgets('honours a non-dollar symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(const BudgetDonut(spent: 40, limit: 100, currencySymbol: '€')),
      );
      expect(find.text('€ 40'), findsOneWidget);
      expect(find.text('€ 60'), findsOneWidget);
    });
  });
}
