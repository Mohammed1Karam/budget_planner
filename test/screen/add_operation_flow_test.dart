import 'dart:async';

import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/screen/operation/operation_currency_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Walks the add-operation flow the way a person does: open the form from the
/// tab bar, pick a category, pick a currency, type an amount, save.
///
/// Each screen is exercised on its own elsewhere; this is the pass that
/// catches what only goes wrong between them — a value that does not come
/// back from a picker, a controller torn down on the way, a route that mounts
/// over a live tab and throws.
void main() {
  const Size frame = Size(414, 896);

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      const UserModel(
        name: 'Yana',
        email: 'yana@example.com',
        dailyLimit: 2032,
        pin: '1234',
      ),
    );

    Get.reset();
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  Future<void> openForm(WidgetTester tester) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harnessScreen(const BottomNavBarScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(AddOperationScreen), findsOneWidget);
  }

  testWidgets('the add button opens the form from the tab bar',
      (WidgetTester tester) async {
    await openForm(tester);

    expect(find.text('Add operation'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a category brings it back into the form',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    expect(find.byType(OperationCategoryScreen), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(find.byType(AddOperationScreen), findsOneWidget);
    expect(
      Get.find<OperationController>().category.value?.name,
      'Food',
      reason: 'the picked category did not reach the controller',
    );
    expect(find.text('Food'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an income category flips the form to income',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();

    final OperationController controller = Get.find<OperationController>();
    expect(controller.category.value?.name, 'Salary');
    expect(controller.type.value, OperationType.income);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a currency brings it back', (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    expect(find.byType(OperationCurrencyScreen), findsOneWidget);

    await tester.tap(find.text('Euro (EUR €)'));
    await tester.pumpAndSettle();

    expect(Get.find<OperationController>().currency.value.code, 'EUR');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a complete form saves and lands on the confirmation',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextField).first, '245');
    await tester.pump();

    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medicine'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Well done!'), findsOneWidget);

    final HomeController home = Get.find<HomeController>();
    await home.load();
    expect(home.operations, hasLength(1));
    expect(home.operations.single.amount, 245);
    expect(home.operations.single.category.name, 'Medicine');
    expect(tester.takeException(), isNull);

    // Let the confirmation's timer run rather than leaving it pending.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('an incomplete form cannot be saved',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextField).first, '245');
    await tester.pump();

    // No category yet, so Add is inert.
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(AddOperationScreen), findsOneWidget);
    expect(find.text('Well done!'), findsNothing);
  });

  testWidgets('closing the form leaves the tab shell intact',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavBarScreen), findsOneWidget);
    expect(find.byType(AddOperationScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding a category from the picker shows up in the list',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();

    unawaited(Get.toNamed<void>(AppRoutes.addCategory));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Coffee');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(OperationCategoryScreen), findsOneWidget);
    expect(
      find.text('Coffee'),
      findsOneWidget,
      reason: 'the new category did not appear in the picker behind it',
    );
    expect(tester.takeException(), isNull);
  });
}
