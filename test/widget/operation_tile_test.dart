import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/utils/app_colors.dart';
import 'package:budget_planner/utils/app_dimens.dart';
import 'package:budget_planner/widget/operation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  const CategoryModel food = CategoryModel(
    id: 'food',
    name: 'Food',
    emoji: '🍕',
    type: OperationType.expense,
  );
  const CategoryModel gift = CategoryModel(
    id: 'gift',
    name: 'Gift',
    emoji: '🎁',
    type: OperationType.income,
  );

  OperationModel operation(CategoryModel category, double amount) =>
      OperationModel(
        id: 'op',
        category: category,
        title: 'Pizza Day',
        amount: amount,
        date: DateTime(2021, 5, 19),
      );

  testWidgets('an expense reads minus, in red', (WidgetTester tester) async {
    await tester.pumpWidget(
      harness(
        OperationTile(operation: operation(food, 423), currencySymbol: r'$'),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Pizza Day'), findsOneWidget);
    expect(find.text('🍕'), findsOneWidget);

    final Text amount = tester.widget<Text>(find.text(r'- $423'));
    expect(amount.style?.color, AppColors.expense);
  });

  testWidgets('an income reads plus, in green', (WidgetTester tester) async {
    await tester.pumpWidget(
      harness(
        OperationTile(operation: operation(gift, 73), currencySymbol: r'$'),
      ),
    );

    final Text amount = tester.widget<Text>(find.text(r'+ $73'));
    expect(amount.style?.color, AppColors.income);
  });

  testWidgets('groups thousands the way the design does',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      harness(
        OperationTile(operation: operation(food, 1267), currencySymbol: r'$'),
      ),
    );
    expect(find.text(r'- $1,267'), findsOneWidget);
  });

  testWidgets('the avatar is the Figma square', (WidgetTester tester) async {
    await tester.pumpWidget(
      harness(
        OperationTile(operation: operation(food, 10), currencySymbol: r'$'),
      ),
    );

    final Size size = tester.getSize(
      find
          .ancestor(
            of: find.text('🍕'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(size.width, AppDimens.operationAvatar);
    expect(size.height, AppDimens.operationAvatar);
  });

  testWidgets('fires on tap', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      harness(
        OperationTile(
          operation: operation(food, 10),
          currencySymbol: r'$',
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(OperationTile));
    expect(taps, 1);
  });

  group('date divider', () {
    testWidgets('today reads "today"', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(OperationDateDivider(date: DateTime.now())),
      );
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('an older day reads its date', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          OperationDateDivider(
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ),
      );
      expect(find.text('Today'), findsNothing);
      expect(find.text('Yesterday'), findsNothing);
    });
  });
}
