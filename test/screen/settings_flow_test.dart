import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/setting/setting_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/utils_lan/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Settings and the destructive actions on it, which are the ones worth being
/// sure about: each has to ask first, and each has to actually do what it says.
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
    await AppPreferences.instance.setLoggedIn(true);
    await AppPreferences.instance.setOnboardingSeen();

    Get.reset();
    Get.locale = AppTranslations.fallback;
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);


  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harnessScreen(const SettingScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lists both groups and every row', (WidgetTester tester) async {
    await open(tester);

    expect(find.text('General'), findsOneWidget);
    expect(find.text('About App'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Account & data'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Remove account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the language row opens a sheet listing both languages',
      (WidgetTester tester) async {
    await open(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // "English" shows twice: as the row's trailing value and in the sheet.
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('English'), findsNWidgets(2));
    expect(find.text('العربية'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Closing it here rather than tapping a language: Get.updateLocale
    // rebuilds the whole app, which a widget test cannot settle across
    // cleanly. That the change itself works is covered by
    // test/controller/app_controller_test.dart.
    Navigator.of(tester.element(find.byType(ListTile).first)).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('logout clears the session but keeps the account',
      (WidgetTester tester) async {
    await open(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(AppPreferences.instance.isLoggedIn, isFalse);
    expect(
      AppPreferences.instance.user.name,
      'Yana',
      reason: 'signing out must not wipe the profile',
    );

  });

  testWidgets('removing the account asks before doing anything',
      (WidgetTester tester) async {
    await open(tester);

    await tester.tap(find.text('Remove account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account data'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(
      AppPreferences.instance.user.name,
      'Yana',
      reason: 'declining must leave everything alone',
    );

  });

  testWidgets('confirming removal wipes the account',
      (WidgetTester tester) async {
    await open(tester);

    await tester.tap(find.text('Remove account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(AppPreferences.instance.user.name, isEmpty);
    expect(AppPreferences.instance.isLoggedIn, isFalse);
    expect(AppPreferences.instance.onboardingSeen, isFalse);

  });

  testWidgets('clearing data also asks first', (WidgetTester tester) async {
    await open(tester);

    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();

    expect(find.text('No'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    expect(AppPreferences.instance.user.name, 'Yana');
  });
}
