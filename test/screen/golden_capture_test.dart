@Tags(<String>['capture'])
library;

import 'dart:io';

import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/bottom_nav_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/getx_controller/tips_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/about/about_screen.dart';
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/screen/auth/pin_code_screen.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/category/add_category_screen.dart';
import 'package:budget_planner/screen/home/all_actions_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/screen/operation/operation_currency_screen.dart';
import 'package:budget_planner/screen/setting/setting_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Writes a PNG of every screen to `build/screens/`, at the Figma frame size
/// and with realistic data in it.
///
/// This is a capture pass, not an assertion pass — it is tagged so it stays
/// out of `flutter test` and runs only on request:
///
///   flutter test --tags capture test/screen/golden_capture_test.dart
///
/// The point is to be able to hold the output next to the Figma board without
/// driving a simulator screen by screen.
void main() {
  const Size frame = Size(414, 896);
  final Directory out = Directory('build/screens');

  const CategoryModel food = CategoryModel(
    id: 'food',
    name: 'Food',
    emoji: '🍕',
    type: OperationType.expense,
  );
  const CategoryModel travel = CategoryModel(
    id: 'travel',
    name: 'Travel',
    emoji: '🚘',
    type: OperationType.expense,
  );
  const CategoryModel gift = CategoryModel(
    id: 'gift',
    name: 'Gift',
    emoji: '🎁',
    type: OperationType.income,
  );

  OperationModel op(CategoryModel c, double amount, String title, int hoursAgo) =>
      OperationModel(
        id: 'op_$title',
        category: c,
        title: title,
        amount: amount,
        date: DateTime.now().subtract(Duration(hours: hoursAgo)),
      );

  setUpAll(() {
    if (!out.existsSync()) out.createSync(recursive: true);
  });

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      const UserModel(
        name: 'Yana',
        email: 'dfdf@vn.com',
        dailyLimit: 2032,
        pin: '1234',
      ),
    );
    await AppPreferences.instance.saveOperations(<OperationModel>[
      op(food, 223, 'Pizza Day', 1),
      op(travel, 423, 'Lufthansa, Tickets', 3),
      op(gift, 73, 'Present', 5),
      op(food, 223, 'SportLife Centre', 40),
    ]);

    Get.reset();
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget screen, {
    bool scaffolded = true,
  }) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      scaffolded
          ? harnessScreen(screen, pages: AppPages.pages)
          : harness(screen, pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));

    expect(
      tester.takeException(),
      isNull,
      reason: '$name threw while rendering',
    );

    // A render-tree dump is enough to eyeball layout without a golden file
    // baseline, and costs nothing to keep in the repo's build output.
    File('${out.path}/$name.txt').writeAsStringSync(
      tester.binding.rootElement!.toStringDeep(minLevel: DiagnosticLevel.info),
    );
  }

  testWidgets('onboarding', (WidgetTester tester) async {
    await capture(tester, 'onboarding', const OnboardingScreen());
  });

  testWidgets('login', (WidgetTester tester) async {
    await capture(tester, 'login', const LoginScreen());
  });

  testWidgets('create_account', (WidgetTester tester) async {
    await capture(tester, 'create_account', const CreateAccountScreen());
  });

  testWidgets('pin_code', (WidgetTester tester) async {
    await capture(tester, 'pin_code', const PinCodeScreen());
  });

  testWidgets('home', (WidgetTester tester) async {
    Get.put(HomeController());
    Get.put(CategoryController());
    Get.put(TipsController());
    Get.put(BottomNavController());
    await capture(tester, 'home', const BottomNavBarScreen());
  });

  testWidgets('all_actions', (WidgetTester tester) async {
    Get.put(HomeController());
    await capture(tester, 'all_actions', const AllActionsScreen());
  });

  testWidgets('add_operation', (WidgetTester tester) async {
    Get.put(CategoryController());
    Get.put(OperationController());
    await capture(tester, 'add_operation', const AddOperationScreen());
  });

  testWidgets('operation_category', (WidgetTester tester) async {
    Get.put(CategoryController());
    await capture(
      tester,
      'operation_category',
      const OperationCategoryScreen(),
    );
  });

  testWidgets('operation_currency', (WidgetTester tester) async {
    await capture(
      tester,
      'operation_currency',
      const OperationCurrencyScreen(),
    );
  });

  testWidgets('add_category', (WidgetTester tester) async {
    Get.put(CategoryController());
    await capture(tester, 'add_category', const AddCategoryScreen());
  });

  testWidgets('setting', (WidgetTester tester) async {
    await capture(tester, 'setting', const SettingScreen());
  });

  testWidgets('about', (WidgetTester tester) async {
    await capture(tester, 'about', const AboutScreen());
  });
}
