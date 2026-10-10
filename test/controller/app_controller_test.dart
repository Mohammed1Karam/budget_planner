import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/utils_lan/app_translations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// App-wide state: the signed-in profile and the active language.
///
/// The language part is asserted here rather than through the Settings screen.
/// Get.updateLocale rebuilds the entire widget tree, which a widget test cannot
/// settle across inside fake_async — so the screen test checks that the sheet
/// offers both languages, and this checks that choosing one takes effect.
void main() {
  late AppController controller;

  Future<void> start() async {
    resetPreferences();
    await AppPreferences.init();
    Get.reset();
    Get.locale = AppTranslations.fallback;
    Get.addTranslations(AppTranslations().keys);
    controller = Get.put(AppController());
  }

  tearDown(() {
    Get.locale = AppTranslations.fallback;
    Get.reset();
  });

  group('language', () {
    test('a stored code maps to a locale', () {
      expect(AppController.localeOf('en_US'), const Locale('en', 'US'));
      expect(AppController.localeOf('ar_JO'), const Locale('ar', 'JO'));
      expect(
        AppController.localeOf('en'),
        const Locale('en'),
        reason: 'a bare language code is still valid',
      );
    });

    test('starts in the fallback', () async {
      await start();
      expect(controller.localeCode.value, 'en_US');
    });

    // These go through testWidgets rather than test: changeLocale calls
    // Get.updateLocale, which reassembles the app and asserts it is running
    // under a widget-test binding.
    testWidgets('switching to Arabic updates the locale and persists it',
        (WidgetTester tester) async {
      await start();
      await tester.pumpWidget(const _Host());

      await controller.changeLocale('ar_JO');
      await tester.pump();

      expect(controller.localeCode.value, 'ar_JO');
      expect(AppPreferences.instance.localeCode, 'ar_JO');
      expect(Get.locale, const Locale('ar', 'JO'));
    });

    testWidgets('translated copy follows the locale',
        (WidgetTester tester) async {
      await start();
      await tester.pumpWidget(const _Host());
      expect('settings'.tr, 'Settings');

      await controller.changeLocale('ar_JO');
      await tester.pump();

      expect('settings'.tr, 'الإعدادات');
    });

    testWidgets('switching back to English works too',
        (WidgetTester tester) async {
      await start();
      await tester.pumpWidget(const _Host());

      await controller.changeLocale('ar_JO');
      await tester.pump();
      await controller.changeLocale('en_US');
      await tester.pump();

      expect(controller.localeCode.value, 'en_US');
      expect(Get.locale, const Locale('en', 'US'));
    });

    testWidgets('the choice is restored on the next launch',
        (WidgetTester tester) async {
      await start();
      await tester.pumpWidget(const _Host());

      await controller.changeLocale('ar_JO');
      await tester.pump();

      // A fresh controller over the same store, as a relaunch would build.
      Get.delete<AppController>();
      expect(Get.put(AppController()).localeCode.value, 'ar_JO');
    });
  });

  group('profile', () {
    test('loads the saved account', () async {
      resetPreferences();
      await AppPreferences.init();
      await AppPreferences.instance.saveUser(
        const UserModel(name: 'Julia', currencyCode: 'EUR'),
      );

      Get.reset();
      controller = Get.put(AppController());
      await controller.loadUser();

      expect(controller.user.value.name, 'Julia');
      expect(controller.currencySymbol, '€');
    });

    test('the currency symbol follows the saved code', () async {
      await start();
      for (final MapEntry<String, String> pair in const <String, String>{
        'USD': r'$',
        'GBP': '£',
        'EUR': '€',
        'JPY': '¥',
      }.entries) {
        await controller.saveUser(
          controller.user.value.copyWith(currencyCode: pair.key),
        );
        expect(controller.currencySymbol, pair.value);
      }
    });

    test('logout keeps the profile, deleting the account does not', () async {
      await start();
      await controller.saveUser(const UserModel(name: 'Julia'));
      await AppPreferences.instance.setLoggedIn(true);

      await controller.logout();
      expect(AppPreferences.instance.isLoggedIn, isFalse);
      expect(AppPreferences.instance.user.name, 'Julia');

      await controller.deleteAccount();
      expect(AppPreferences.instance.user.name, isEmpty);
      expect(controller.user.value.name, isEmpty);
    });
  });
}

/// The smallest app that satisfies Get.updateLocale's need for a live binding.
class _Host extends StatelessWidget {
  const _Host();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: AppTranslations.fallback,
      fallbackLocale: AppTranslations.fallback,
      home: const SizedBox.shrink(),
    );
  }
}
