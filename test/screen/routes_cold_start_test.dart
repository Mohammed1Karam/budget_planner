import 'dart:async';

import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils/app_routes.dart';
import 'package:budget_planner/utils_lan/app_translations.dart';
import 'package:budget_planner/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Opens every named route from a cold start.
///
/// Inside the tab shell the controllers are already registered, so a screen
/// that calls `Get.find` for one it did not declare still works — until the
/// route is reached some other way, and then it throws. Each case here pushes
/// the route with nothing registered but the permanent AppController, which is
/// exactly the state a deep link or a notification tap would arrive in.
void main() {
  const Size frame = Size(414, 896);

  final OperationModel sample = OperationModel(
    id: 'op_1',
    category: const CategoryModel(
      id: 'food',
      name: 'Food',
      emoji: '🍕',
      type: OperationType.expense,
    ),
    title: 'Pizza Day',
    amount: 223,
    date: DateTime.now(),
  );

  /// Routes that need something passed in, and what to pass.
  final Map<String, Object?> arguments = <String, Object?>{
    AppRoutes.expenseDetails: sample,
    AppRoutes.operationCategory: OperationType.income,
  };

  /// Routes that navigate onwards by themselves, so the test lets their timer
  /// run rather than leaving it pending.
  const Set<String> autoAdvancing = <String>{
    AppRoutes.splash,
    AppRoutes.createAccountSuccess,
    AppRoutes.operationSuccess,
  };

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
    await AppPreferences.instance.saveOperations(<OperationModel>[sample]);

    Get.reset();
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  for (final GetPage<dynamic> page in AppPages.pages) {
    testWidgets('${page.name} opens cold', (WidgetTester tester) async {
      tester.view.physicalSize = frame;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          translations: AppTranslations(),
          locale: AppTranslations.fallback,
          fallbackLocale: AppTranslations.fallback,
          getPages: AppPages.pages,
          initialRoute: page.name,
          // Get resolves arguments from the navigator, so they are supplied
          // through a push below rather than here.
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      if (arguments.containsKey(page.name)) {
        unawaited(
          Get.toNamed<void>(page.name, arguments: arguments[page.name]),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        tester.takeException(),
        isNull,
        reason: '${page.name} threw on a cold open',
      );

      if (autoAdvancing.contains(page.name)) {
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }
    });
  }
}
