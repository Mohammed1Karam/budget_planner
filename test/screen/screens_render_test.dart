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
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/create_account_success_screen.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/screen/auth/pin_code_screen.dart';
import 'package:budget_planner/screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import 'package:budget_planner/screen/category/add_category_screen.dart';
import 'package:budget_planner/screen/category/category_screen.dart';
import 'package:budget_planner/screen/home/all_actions_screen.dart';
import 'package:budget_planner/screen/home/home_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/screen/lunch/splash_screen.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/operation/operation_category_screen.dart';
import 'package:budget_planner/screen/operation/operation_currency_screen.dart';
import 'package:budget_planner/screen/operation/operation_success_screen.dart';
import 'package:budget_planner/screen/profile/profile_screen.dart';
import 'package:budget_planner/screen/setting/setting_screen.dart';
import 'package:budget_planner/screen/tips/tip_article_screen.dart';
import 'package:budget_planner/screen/tips/tips_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Renders every screen in the app on a device the size of the Figma frame.
///
/// This is the smoke net: it catches a screen that throws on build, overflows
/// its 414x896 frame, or asks for a controller nobody registered. The pumps
/// use `pump` rather than `pumpAndSettle` because several screens hold a timer
/// that navigates onwards, which would never settle.
void main() {
  /// The Figma artboard, so an overflow here is an overflow in the design.
  const Size frame = Size(414, 896);

  Future<void> seed({
    List<OperationModel> operations = const <OperationModel>[],
    double dailyLimit = 2032,
  }) async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      UserModel(
        name: 'Yana',
        email: 'yana@example.com',
        dailyLimit: dailyLimit,
        pin: '1234',
      ),
    );
    await AppPreferences.instance.saveOperations(operations);

    Get.reset();
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
  }

  setUp(() async {
    await seed();
  });

  tearDown(Get.reset);

  Future<void> show(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harnessScreen(screen, pages: AppPages.pages));
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Splash and the two confirmation screens navigate onwards on a timer. The
  /// assertions run while it is still pending, then this lets it fire so the
  /// binding does not fail the test over a live timer at teardown.
  Future<void> drainAutoAdvance(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  group('launch', () {
    testWidgets('splash', (WidgetTester tester) async {
      await show(tester, const SplashScreen());
      expect(find.text('Budget Planner'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainAutoAdvance(tester);
    });

    testWidgets('onboarding shows the first page and its button',
        (WidgetTester tester) async {
      await show(tester, const OnboardingScreen());
      expect(find.text('Take hold of your finances'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onboarding swipes to the last page and changes the button',
        (WidgetTester tester) async {
      await show(tester, const OnboardingScreen());

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Reach your goals with ease'), findsOneWidget);
      expect(find.text("Let's start"), findsOneWidget);
    });
  });

  group('auth', () {
    testWidgets('login', (WidgetTester tester) async {
      await show(tester, const LoginScreen());
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Now!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('create account lists all five rows',
        (WidgetTester tester) async {
      await show(tester, const CreateAccountScreen());

      expect(find.text('Name:'), findsOneWidget);
      expect(find.text('Email Address:'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Daily limit'), findsOneWidget);
      expect(find.text('Set your pin'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pin code renders the full keypad',
        (WidgetTester tester) async {
      await show(tester, const PinCodeScreen());

      for (final String digit in <String>[
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      ]) {
        expect(find.text(digit), findsOneWidget, reason: 'key $digit missing');
      }
      expect(find.text('Apply'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('create account success', (WidgetTester tester) async {
      await show(tester, const CreateAccountSuccessScreen());
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainAutoAdvance(tester);
    });
  });

  group('home', () {
    testWidgets('renders empty', (WidgetTester tester) async {
      Get.put(HomeController());
      await show(tester, const HomeScreen());

      expect(find.text('Last actions'), findsOneWidget);
      expect(find.text('See more'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders operations and today\'s spend',
        (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      await seed(
        operations: <OperationModel>[
          OperationModel(
            id: 'a',
            category: const CategoryModel(
              id: 'food',
              name: 'Food',
              emoji: '🍕',
              type: OperationType.expense,
            ),
            title: 'Pizza Day',
            amount: 423,
            date: now,
          ),
        ],
      );
      Get.put(HomeController());
      await show(tester, const HomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pizza Day'), findsOneWidget);
      expect(find.text(r'$ 423'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the limit banner once the limit is spent',
        (WidgetTester tester) async {
      final DateTime now = DateTime.now();
      await seed(
        dailyLimit: 100,
        operations: <OperationModel>[
          OperationModel(
            id: 'a',
            category: const CategoryModel(
              id: 'food',
              name: 'Food',
              emoji: '🍕',
              type: OperationType.expense,
            ),
            title: 'Pizza Day',
            amount: 150,
            date: now,
          ),
        ],
      );
      Get.put(HomeController());
      await show(tester, const HomeScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your daily limit has been reached'), findsOneWidget);
    });

    testWidgets('all actions', (WidgetTester tester) async {
      Get.put(HomeController());
      await show(tester, const AllActionsScreen());
      expect(find.text('Actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('operations', () {
    testWidgets('add operation', (WidgetTester tester) async {
      Get.put(CategoryController());
      Get.put(OperationController());
      await show(tester, const AddOperationScreen());

      expect(find.text('Add operation'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('category picker lists the expense categories',
        (WidgetTester tester) async {
      Get.put(CategoryController());
      await show(tester, const OperationCategoryScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('currency picker lists all four',
        (WidgetTester tester) async {
      await show(tester, const OperationCurrencyScreen());

      expect(find.text('United States Dollar'), findsOneWidget);
      expect(find.text('Pound (RGP £)'), findsOneWidget);
      expect(find.text('Euro (EUR €)'), findsOneWidget);
      expect(find.text('Yen (JPY ¥)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('operation success', (WidgetTester tester) async {
      await show(tester, const OperationSuccessScreen());
      expect(find.text('Well done!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainAutoAdvance(tester);
    });
  });

  group('categories', () {
    testWidgets('category tab', (WidgetTester tester) async {
      Get.put(CategoryController());
      await show(tester, const CategoryScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Accommodation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('add category', (WidgetTester tester) async {
      Get.put(CategoryController());
      await show(tester, const AddCategoryScreen());

      expect(find.text('Add Category'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('tips', () {
    testWidgets('tips grid', (WidgetTester tester) async {
      Get.put(TipsController());
      await show(tester, const TipsScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Tips'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tip article', (WidgetTester tester) async {
      await show(tester, const TipArticleScreen());
      expect(find.text('How to save a budget 10 tips'), findsOneWidget);
      expect(find.text('eliminate your debt;'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('profile and settings', () {
    testWidgets('profile pre-fills from the saved account',
        (WidgetTester tester) async {
      await show(tester, const ProfileScreen());

      expect(
        find.text('Yana'),
        findsNWidgets(2),
        reason: 'once as the heading, once in the Name field',
      );
      expect(find.text('Change your pin'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings lists both groups', (WidgetTester tester) async {
      await show(tester, const SettingScreen());

      expect(find.text('General'), findsOneWidget);
      expect(find.text('About App'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Account & data'), findsOneWidget);
      expect(find.text('Remove account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('shell', () {
    testWidgets('the four tabs and the add button are all present',
        (WidgetTester tester) async {
      await show(tester, const BottomNavBarScreen());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Home'), findsAtLeastNWidgets(1));
      expect(find.text('Category'), findsAtLeastNWidgets(1));
      expect(find.text('Tips'), findsAtLeastNWidgets(1));
      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a tab switches the body',
        (WidgetTester tester) async {
      await show(tester, const BottomNavBarScreen());
      await tester.pump(const Duration(milliseconds: 100));

      final BottomNavController nav = Get.find<BottomNavController>();
      expect(nav.index.value, 0);

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pump(const Duration(milliseconds: 100));

      expect(nav.index.value, BottomNavController.profile);
    });
  });
}
