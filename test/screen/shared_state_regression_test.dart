import 'dart:async';

import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/bottom_nav_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/category/category_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Guards against a route mutating controller state that a screen already on
/// screen is observing.
///
/// The tab shell keeps every tab mounted in an IndexedStack, so the Category
/// tab's Obx stays live while another route is pushed over it. A pushed screen
/// that wrote to the same Rx while mounting marked that live Obx dirty mid-
/// build, and Flutter threw "setState() or markNeedsBuild() called during
/// build". Opening the picker from the tab shell is what reproduces it — the
/// earlier tests missed it because they pushed the picker with no tab shell
/// underneath, so nothing else was observing.
void main() {
  const Size frame = Size(414, 896);

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      const UserModel(name: 'Yana', dailyLimit: 2032, pin: '1234'),
    );

    Get.reset();
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  Future<void> openShell(WidgetTester tester) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harnessScreen(const BottomNavBarScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('the category tab stays mounted behind a pushed route',
      (WidgetTester tester) async {
    await openShell(tester);

    // Move to the Category tab so its Obx is definitely live.
    Get.find<BottomNavController>().select(BottomNavController.category);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CategoryScreen), findsOneWidget);

    unawaited(
      Get.toNamed<void>(
        AppRoutes.operationCategory,
        arguments: OperationType.income,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'pushing the picker over the live Category tab threw',
    );
    expect(find.byType(OperationCategoryScreen), findsOneWidget);
  });

  testWidgets('the picker opens on the side it was handed',
      (WidgetTester tester) async {
    await openShell(tester);

    unawaited(
      Get.toNamed<void>(
        AppRoutes.operationCategory,
        arguments: OperationType.income,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Salary'), findsOneWidget);
    expect(
      find.text('Food'),
      findsNothing,
      reason: 'an expense category must not show on the income side',
    );
  });

  testWidgets('opening the picker does not change what the tab shows',
      (WidgetTester tester) async {
    await openShell(tester);

    final CategoryController categories = Get.find<CategoryController>();
    expect(categories.filter.value, OperationType.expense);

    unawaited(
      Get.toNamed<void>(
        AppRoutes.operationCategory,
        arguments: OperationType.income,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      categories.filter.value,
      OperationType.expense,
      reason: 'the tab behind must keep showing the side the user left it on',
    );
  });

  testWidgets('the picker toggles between sides on its own',
      (WidgetTester tester) async {
    await openShell(tester);

    unawaited(Get.toNamed<void>(AppRoutes.operationCategory));
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
