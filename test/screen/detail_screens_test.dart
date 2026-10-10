import 'dart:async';

import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/about/about_screen.dart';
import 'package:budget_planner/screen/home/all_actions_screen.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/screen/home/expense_details_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The screens added after the first pass: About, the searchable actions list,
/// and the read-only operation detail.
void main() {
  const Size frame = Size(414, 896);

  const CategoryModel food = CategoryModel(
    id: 'food',
    name: 'Food',
    emoji: '🍕',
    type: OperationType.expense,
  );
  const CategoryModel salary = CategoryModel(
    id: 'salary',
    name: 'Salary',
    emoji: '💵',
    type: OperationType.income,
  );

  OperationModel op(CategoryModel category, double amount, String title,
          {DateTime? date}) =>
      OperationModel(
        id: 'op_$title',
        category: category,
        title: title,
        amount: amount,
        date: date ?? DateTime.now(),
        note: 'a note',
      );

  Future<void> seed([List<OperationModel> operations = const <OperationModel>[]]) async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      const UserModel(name: 'Yana', dailyLimit: 2032, pin: '1234'),
    );
    await AppPreferences.instance.saveOperations(operations);

    Get.reset();
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
  }

  tearDown(Get.reset);

  Future<void> show(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harnessScreen(screen, pages: AppPages.pages));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('About', () {
    testWidgets('shows the product name, credit and version',
        (WidgetTester tester) async {
      await seed();
      await show(tester, const AboutScreen());

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Budget Planner'), findsOneWidget);
      expect(find.text('Budget Planner - Flutter'), findsOneWidget);
      expect(find.text(AboutScreen.version), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('All Actions', () {
    testWidgets('lists every operation under its day',
        (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      await seed(<OperationModel>[
        op(food, 423, 'Pizza Day'),
        op(salary, 3000, 'March',
            date: now.subtract(const Duration(days: 2))),
      ]);
      Get.put(HomeController());
      await show(tester, const AllActionsScreen());

      expect(find.text('Pizza Day'), findsOneWidget);
      expect(find.text('March'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the search field narrows the list',
        (WidgetTester tester) async {
      await seed(<OperationModel>[
        op(food, 423, 'Pizza Day'),
        op(salary, 3000, 'March'),
      ]);
      Get.put(HomeController());
      await show(tester, const AllActionsScreen());

      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump();

      expect(find.text('Pizza Day'), findsOneWidget);
      expect(find.text('March'), findsNothing);
    });

    testWidgets('matches on the category as well as the description',
        (WidgetTester tester) async {
      await seed(<OperationModel>[
        op(food, 423, 'Pizza Day'),
        op(salary, 3000, 'March'),
      ]);
      Get.put(HomeController());
      await show(tester, const AllActionsScreen());

      await tester.enterText(find.byType(TextField), 'salary');
      await tester.pump();

      expect(find.text('March'), findsOneWidget);
      expect(find.text('Pizza Day'), findsNothing);
    });

    testWidgets('says so when nothing matches', (WidgetTester tester) async {
      await seed(<OperationModel>[op(food, 423, 'Pizza Day')]);
      Get.put(HomeController());
      await show(tester, const AllActionsScreen());

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump();

      expect(find.text('Nothing matches that search.'), findsOneWidget);
    });
  });

  group('category picker', () {
    // Regression: the screen used to apply Get.arguments from build(), which
    // writes to an Rx the surrounding Obx observes. That throws
    // "setState() or markNeedsBuild() called during build" as soon as the
    // argument differs from the current filter, which is every time the form
    // opens it on the income side.
    testWidgets('opens on the side it was given without throwing',
        (WidgetTester tester) async {
      await seed();
      Get.put(CategoryController());

      tester.view.physicalSize = frame;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        harnessScreen(const AddOperationScreen(), pages: AppPages.pages),
      );
      await tester.pump(const Duration(milliseconds: 100));

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

    testWidgets('defaults to expenses with no argument',
        (WidgetTester tester) async {
      await seed();
      Get.put(CategoryController());

      tester.view.physicalSize = frame;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        harnessScreen(const OperationCategoryScreen(), pages: AppPages.pages),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Food'), findsOneWidget);
    });
  });

  group('Expense Details', () {
    testWidgets('shows the saved row read-only', (WidgetTester tester) async {
      final OperationModel operation = op(food, 423, 'Pizza Day');
      await seed(<OperationModel>[operation]);
      Get.put(HomeController());

      tester.view.physicalSize = frame;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Navigate for real, so Get.arguments carries the operation the way the
      // actions list passes it.
      await tester.pumpWidget(
        harnessScreen(const AllActionsScreen(), pages: AppPages.pages),
      );
      await tester.pump(const Duration(milliseconds: 100));

      unawaited(
        Get.toNamed<void>(AppRoutes.expenseDetails, arguments: operation),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseDetailsScreen), findsOneWidget);
      expect(find.text('Food'), findsAtLeastNWidgets(1));
      expect(find.text(r'$ 423'), findsOneWidget);
      expect(find.text('a note'), findsOneWidget);
      expect(
        find.text('Add'),
        findsNothing,
        reason: 'the detail frame has no save action',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers to delete the row', (WidgetTester tester) async {
      final OperationModel operation = op(food, 423, 'Pizza Day');
      await seed(<OperationModel>[operation]);
      final HomeController home = Get.put(HomeController());
      await home.load();

      tester.view.physicalSize = frame;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        harnessScreen(const AllActionsScreen(), pages: AppPages.pages),
      );
      await tester.pump(const Duration(milliseconds: 100));

      unawaited(
        Get.toNamed<void>(AppRoutes.expenseDetails, arguments: operation),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Remove this operation?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(home.operations, isEmpty);
    });

    testWidgets('renders the guard when opened with no operation',
        (WidgetTester tester) async {
      await seed();
      await show(tester, const ExpenseDetailsScreen());

      expect(find.text('No operation selected.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
