import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/getx_controller/tips_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/create_account_success_screen.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/screen/category/add_category_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/screen/lunch/splash_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_success_screen.dart';
import 'package:budget_planner/screen/profile/profile_screen.dart';
import 'package:budget_planner/screen/tips/tip_article_screen.dart';
import 'package:budget_planner/screen/tips/tips_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/widget/app_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Catches the failure the login screen actually shipped with: an [AppSvg]
/// that resolved to nothing and rendered as an empty box.
///
/// The per-asset tests prove each file loads on its own. These prove the
/// screens ask for paths that exist -- every AppSvg on a screen must resolve to
/// a real SvgPicture, with no placeholders left over.
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
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  /// Renders a screen and asserts every AppSvg on it found its file.
  Future<void> expectAllArtworkResolves(
    WidgetTester tester,
    Widget screen, {
    required int expected,
  }) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harnessScreen(screen, pages: AppPages.pages));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byType(AppSvg),
      findsNWidgets(expected),
      reason: 'the screen no longer asks for $expected pieces of artwork',
    );
    expect(
      find.byType(SvgPicture),
      findsNWidgets(expected),
      reason: 'at least one AppSvg fell back to the empty placeholder',
    );
    expect(tester.takeException(), isNull);
  }

  testWidgets('splash shows the logo', (WidgetTester tester) async {
    await expectAllArtworkResolves(tester, const SplashScreen(), expected: 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('onboarding shows its illustration',
      (WidgetTester tester) async {
    await expectAllArtworkResolves(
      tester,
      const OnboardingScreen(),
      expected: 1,
    );
  });

  testWidgets('login shows the budget mark', (WidgetTester tester) async {
    await expectAllArtworkResolves(tester, const LoginScreen(), expected: 1);
  });

  testWidgets('create account shows the budget mark',
      (WidgetTester tester) async {
    await expectAllArtworkResolves(
      tester,
      const CreateAccountScreen(),
      expected: 1,
    );
  });

  testWidgets('create account success shows the tick',
      (WidgetTester tester) async {
    await expectAllArtworkResolves(
      tester,
      const CreateAccountSuccessScreen(),
      expected: 1,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('add operation shows the budget mark',
      (WidgetTester tester) async {
    Get.put(CategoryController());
    Get.put(OperationController());
    await expectAllArtworkResolves(
      tester,
      const AddOperationScreen(),
      expected: 1,
    );
  });

  testWidgets('operation success shows its mark', (WidgetTester tester) async {
    await expectAllArtworkResolves(
      tester,
      const OperationSuccessScreen(),
      expected: 1,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('add category shows the budget mark',
      (WidgetTester tester) async {
    Get.put(CategoryController());
    await expectAllArtworkResolves(
      tester,
      const AddCategoryScreen(),
      expected: 1,
    );
  });

  testWidgets('profile shows the avatar mark', (WidgetTester tester) async {
    await expectAllArtworkResolves(tester, const ProfileScreen(), expected: 1);
  });

  testWidgets('the tip article shows its hero', (WidgetTester tester) async {
    await expectAllArtworkResolves(
      tester,
      const TipArticleScreen(),
      expected: 1,
    );
  });

  testWidgets('every visible tip card shows its thumbnail',
      (WidgetTester tester) async {
    Get.put(TipsController());
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harnessScreen(const TipsScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    final int cards = find.byType(AppSvg).evaluate().length;
    expect(cards, greaterThan(0), reason: 'the grid rendered no cards');
    expect(
      find.byType(SvgPicture),
      findsNWidgets(cards),
      reason: 'a tip card fell back to the empty placeholder',
    );
    expect(tester.takeException(), isNull);
  });
}
