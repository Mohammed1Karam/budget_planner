import 'package:budget_planner/getx_controller/app_controller.dart';
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
import 'package:budget_planner/screen/auth/create_account_success_screen.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/screen/auth/pin_code_screen.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/category/add_category_screen.dart';
import 'package:budget_planner/screen/home/all_actions_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/screen/lunch/splash_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/screen/operation/operation_currency_screen.dart';
import 'package:budget_planner/screen/operation/operation_success_screen.dart';
import 'package:budget_planner/screen/setting/setting_screen.dart';
import 'package:budget_planner/screen/tips/tip_article_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Renders every screen on phones smaller than the Figma frame, and again
/// with the system font enlarged.
///
/// The board is drawn at 414x896. Plenty of phones in use are shorter than
/// that — an iPhone 12 mini is 375x812 and an SE is 375x667 — and a layout
/// that only ever fits at design size overflows on them. Flutter reports that
/// as a RenderFlex error during layout, which `takeException` picks up here.
///
/// The enlarged-text pass matters just as much: a person who has bumped the
/// system font size gets taller text in the same box, and that is the other
/// common way one of these screens breaks in the wild.
void main() {
  /// Sizes in logical pixels, plus the status/home insets a real device has.
  const Map<String, Size> devices = <String, Size>{
    'iPhone SE (375x667)': Size(375, 667),
    'iPhone 12 mini (375x812)': Size(375, 812),
  };

  const EdgeInsets insets = EdgeInsets.only(top: 47, bottom: 34);

  const CategoryModel food = CategoryModel(
    id: 'food',
    name: 'Food',
    emoji: '🍕',
    type: OperationType.expense,
  );

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
    await AppPreferences.instance.saveOperations(<OperationModel>[
      OperationModel(
        id: 'op_1',
        category: food,
        title: 'Pizza Day',
        amount: 223,
        date: DateTime.now(),
      ),
    ]);

    Get.reset();
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  /// Every screen, with whatever it needs registered first.
  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'splash': () => const SplashScreen(),
    'onboarding': () => const OnboardingScreen(),
    'login': () => const LoginScreen(),
    'create account': () => const CreateAccountScreen(),
    'create account success': () => const CreateAccountSuccessScreen(),
    'pin code': () => const PinCodeScreen(),
    'tab shell': () {
      Get.put(HomeController());
      Get.put(CategoryController());
      Get.put(TipsController());
      return const BottomNavBarScreen();
    },
    'all actions': () {
      Get.put(HomeController());
      return const AllActionsScreen();
    },
    'add operation': () {
      Get.put(CategoryController());
      Get.put(OperationController());
      return const AddOperationScreen();
    },
    'operation category': () {
      Get.put(CategoryController());
      return const OperationCategoryScreen();
    },
    'operation currency': () => const OperationCurrencyScreen(),
    'operation success': () => const OperationSuccessScreen(),
    'add category': () {
      Get.put(CategoryController());
      return const AddCategoryScreen();
    },
    'tip article': () => const TipArticleScreen(),
    'setting': () => const SettingScreen(),
    'about': () => const AboutScreen(),
  };

  /// Screens that navigate onwards on a timer, so the test drains it.
  const Set<String> autoAdvancing = <String>{
    'splash',
    'create account success',
    'operation success',
  };

  /// 1.0 is the system default; 1.3 is a common accessibility setting.
  const Map<String, double> textScales = <String, double>{
    '': 1.0,
    ' at 1.3x text': 1.3,
  };

  devices.forEach((String device, Size size) {
    textScales.forEach((String scaleLabel, double scale) {
      group('$device$scaleLabel', () {
        screens.forEach((String name, Widget Function() build) {
          testWidgets('$name fits', (WidgetTester tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            tester.view.padding = FakeViewPadding(
              top: insets.top,
              bottom: insets.bottom,
            );
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: harnessScreen(build(), pages: AppPages.pages),
              ),
            );
            await tester.pump(const Duration(milliseconds: 150));
            await tester.pump(const Duration(milliseconds: 150));

            expect(
              tester.takeException(),
              isNull,
              reason: '$name overflows on $device$scaleLabel',
            );

            if (autoAdvancing.contains(name)) {
              await tester.pump(const Duration(seconds: 2));
              await tester.pumpAndSettle();
            }
          });
        });
      });
    });
  });
}
