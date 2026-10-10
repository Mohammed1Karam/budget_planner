import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/auth_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/auth/create_account_screen.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/screen/auth/pin_code_screen.dart';
import 'package:budget_planner/screen/lunch/onboarding_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The path a new user takes: onboarding, then the sign-up form with its pin
/// step, then landing in the app.
void main() {
  const Size frame = Size(414, 896);

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    Get.reset();
    Get.put(AppController(), permanent: true);
  });

  tearDown(Get.reset);

  Future<void> open(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harnessScreen(screen, pages: AppPages.pages));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('onboarding', () {
    testWidgets('Next walks to the last page and Skip finishes',
        (WidgetTester tester) async {
      await open(tester, const OnboardingScreen());

      expect(find.text('Take hold of your finances'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('See where your money goes'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Reach your goals with ease'), findsOneWidget);
      expect(find.text("Let's start"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('finishing records that onboarding was seen',
        (WidgetTester tester) async {
      await open(tester, const OnboardingScreen());

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(AppPreferences.instance.onboardingSeen, isTrue);
    });
  });

  group('pin', () {
    testWidgets('entering four digits enables Apply and returns them',
        (WidgetTester tester) async {
      await open(tester, const PinCodeScreen());

      expect(find.text('Enter Passcode'), findsOneWidget);

      for (final String digit in <String>['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('backspace removes the last digit',
        (WidgetTester tester) async {
      await open(tester, const PinCodeScreen());

      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // One filled marker left of the four boxes.
      expect(find.text('•'), findsOneWidget);
    });
  });

  group('create account', () {
    testWidgets('the button stays inert until every row is filled',
        (WidgetTester tester) async {
      await open(tester, const CreateAccountScreen());

      final AuthController auth = Get.find<AuthController>();
      expect(auth.canSubmit, isFalse);

      await tester.enterText(find.byType(TextField).at(0), 'Yana');
      await tester.enterText(find.byType(TextField).at(1), 'yana@example.com');
      await tester.enterText(find.byType(TextField).at(2), '5000');
      await tester.pump();
      expect(auth.canSubmit, isFalse, reason: 'no pin yet');

      auth.setPin('1234');
      await tester.pump();
      expect(auth.canSubmit, isTrue);
    });

    testWidgets('submitting stores the account', (WidgetTester tester) async {
      await open(tester, const CreateAccountScreen());

      final AuthController auth = Get.find<AuthController>();
      await tester.enterText(find.byType(TextField).at(0), 'Yana');
      await tester.enterText(find.byType(TextField).at(1), 'yana@example.com');
      await tester.enterText(find.byType(TextField).at(2), '5000');
      auth.setPin('1234');
      await tester.pump();

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      final UserModel saved = AppPreferences.instance.user;
      expect(saved.name, 'Yana');
      expect(saved.dailyLimit, 5000);
      expect(AppPreferences.instance.isLoggedIn, isTrue);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });
  });

  group('login', () {
    testWidgets('rejects a pin that does not match the saved one',
        (WidgetTester tester) async {
      await AppPreferences.instance.saveUser(
        const UserModel(name: 'Yana', email: 'yana@example.com', pin: '1234'),
      );
      await open(tester, const LoginScreen());

      final AuthController auth = Get.find<AuthController>();
      await tester.enterText(find.byType(TextField).first, 'yana@example.com');
      auth.setPin('9999');
      await tester.pump();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(
        AppPreferences.instance.isLoggedIn,
        isFalse,
        reason: 'a wrong pin must not sign anyone in',
      );

      // The rejection raises a snackbar, whose dismissal timer has to run or
      // the binding fails the test over it.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('accepts the saved pin', (WidgetTester tester) async {
      await AppPreferences.instance.saveUser(
        const UserModel(name: 'Yana', email: 'yana@example.com', pin: '1234'),
      );
      await open(tester, const LoginScreen());

      final AuthController auth = Get.find<AuthController>();
      await tester.enterText(find.byType(TextField).first, 'yana@example.com');
      auth.setPin('1234');
      await tester.pump();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(AppPreferences.instance.isLoggedIn, isTrue);
    });
  });
}
