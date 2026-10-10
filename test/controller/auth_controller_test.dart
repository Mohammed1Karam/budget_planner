import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/auth_controller.dart';
import 'package:budget_planner/models/currency_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The create-account form's gate. In Figma the button is drawn twice, as
/// "Normal" and "Disactive"; [AuthController.canSubmit] is what picks between
/// them, so every rule it encodes is pinned here.
void main() {
  late AuthController controller;

  Future<void> start([UserModel? saved]) async {
    resetPreferences();
    await AppPreferences.init();
    if (saved != null) await AppPreferences.instance.saveUser(saved);

    Get.reset();
    Get.put(AppController());
    controller = Get.put(AuthController());
  }

  void fillValidForm() {
    controller.nameController.text = 'Yana';
    controller.emailController.text = 'yana@example.com';
    controller.dailyLimitController.text = '5000';
    controller.setPin('1234');
  }

  tearDown(Get.reset);

  group('create account', () {
    test('an empty form cannot be submitted', () async {
      await start();
      expect(controller.canSubmit, isFalse);
    });

    test('a fully valid form can', () async {
      await start();
      fillValidForm();
      expect(controller.canSubmit, isTrue);
    });

    test('a blank name blocks it', () async {
      await start();
      fillValidForm();
      controller.nameController.text = '   ';
      expect(controller.canSubmit, isFalse);
    });

    test('a malformed email blocks it', () async {
      await start();
      fillValidForm();
      controller.emailController.text = 'yana@';
      expect(controller.canSubmit, isFalse);
      expect(controller.isEmailValid, isFalse);
    });

    test('a zero daily limit blocks it', () async {
      await start();
      fillValidForm();
      controller.dailyLimitController.text = '0';
      expect(controller.canSubmit, isFalse);
    });

    test('a short pin blocks it', () async {
      await start();
      fillValidForm();
      controller.setPin('12');
      expect(controller.canSubmit, isFalse);
    });

    test('the limit parses past a thousands comma', () async {
      await start();
      controller.dailyLimitController.text = '5,000';
      expect(controller.dailyLimit, 5000);
    });

    test('a non-numeric limit reads as zero rather than throwing', () async {
      await start();
      controller.dailyLimitController.text = 'abc';
      expect(controller.dailyLimit, 0);
    });

    test('the built user carries every field', () async {
      await start();
      fillValidForm();
      controller.selectCurrency(CurrencyModel.all[2]);

      final UserModel user = controller.buildUser();
      expect(user.name, 'Yana');
      expect(user.email, 'yana@example.com');
      expect(user.dailyLimit, 5000);
      expect(user.pin, '1234');
      expect(user.currencyCode, 'EUR');
      expect(user.isComplete, isTrue);
    });

    test('submitting persists the profile', () async {
      await start();
      fillValidForm();
      await Get.find<AppController>().saveUser(controller.buildUser());

      expect(AppPreferences.instance.user.name, 'Yana');
      expect(AppPreferences.instance.user.dailyLimit, 5000);
    });
  });

  group('rehydration', () {
    test('a saved profile pre-fills the form', () async {
      await start(
        const UserModel(
          name: 'Julia',
          email: 'julia@example.com',
          currencyCode: 'GBP',
          dailyLimit: 1200,
          pin: '9876',
        ),
      );

      expect(controller.nameController.text, 'Julia');
      expect(controller.emailController.text, 'julia@example.com');
      expect(controller.dailyLimitController.text, '1200');
      expect(controller.currency.value.code, 'GBP');
      expect(controller.pin.value, '9876');
      expect(controller.canSubmit, isTrue);
    });
  });

  group('login', () {
    test('needs a valid email and a full pin', () async {
      await start();
      expect(controller.canLogin, isFalse);

      controller.emailController.text = 'yana@example.com';
      controller.touch();
      expect(controller.canLogin, isFalse);

      controller.setPin('1234');
      expect(controller.canLogin, isTrue);
    });

    test('login ignores the name and limit rows', () async {
      await start();
      controller.emailController.text = 'yana@example.com';
      controller.setPin('1234');

      expect(controller.canLogin, isTrue);
      expect(controller.canSubmit, isFalse);
    });
  });
}
