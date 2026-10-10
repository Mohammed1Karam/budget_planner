import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/currency_model.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';
import '../utils/app_routes.dart';
import 'app_controller.dart';

/// Login, the two create-account steps, and the pin they end in.
///
/// The Figma create-account form is one screen with five rows; the button only
/// lights up once [canSubmit] is true, which is what the "Disactive" button
/// state in the design represents.
class AuthController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dailyLimitController = TextEditingController();

  final Rx<CurrencyModel> currency = CurrencyModel.usd.obs;
  final RxString pin = ''.obs;

  /// Bumped on every field change so the button's enabled state re-evaluates.
  final RxInt revision = 0.obs;

  final RxBool loading = false.obs;

  static const int pinLength = 4;

  @override
  void onInit() {
    super.onInit();
    final UserModel user = AppPreferences.instance.user;
    nameController.text = user.name;
    emailController.text = user.email;
    if (user.dailyLimit > 0) {
      dailyLimitController.text = user.dailyLimit.toStringAsFixed(0);
    }
    currency.value = CurrencyModel.byCode(user.currencyCode);
    pin.value = user.pin;
  }

  void touch() => revision.value++;

  bool get isEmailValid => GetUtils.isEmail(emailController.text.trim());

  double get dailyLimit =>
      double.tryParse(dailyLimitController.text.replaceAll(',', '')) ?? 0;

  /// Mirrors the create-account form's five required rows.
  bool get canSubmit {
    revision.value; // read so Obx rebuilds when a field changes
    return nameController.text.trim().isNotEmpty &&
        isEmailValid &&
        dailyLimit > 0 &&
        pin.value.length == pinLength;
  }

  /// Login only needs an email and the saved pin.
  bool get canLogin {
    revision.value;
    return isEmailValid && pin.value.length == pinLength;
  }

  UserModel buildUser() => UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        currencyCode: currency.value.code,
        dailyLimit: dailyLimit,
        pin: pin.value,
      );

  void selectCurrency(CurrencyModel value) {
    currency.value = value;
    touch();
  }

  /// Called by the pin screen once four digits are in.
  void setPin(String value) {
    pin.value = value;
    touch();
  }

  Future<void> submitCreateAccount() async {
    if (!canSubmit) return;
    loading.value = true;
    try {
      final UserModel user = buildUser();
      await Get.find<AppController>().saveUser(user);
      await AppPreferences.instance.setLoggedIn(true);
      await Get.toNamed<void>(AppRoutes.createAccountSuccess);
    } finally {
      loading.value = false;
    }
  }

  Future<void> submitLogin() async {
    if (!canLogin) return;
    loading.value = true;
    try {
      final UserModel saved = AppPreferences.instance.user;
      if (saved.pin.isNotEmpty && saved.pin != pin.value) {
        Get.snackbar('login'.tr, 'Incorrect pin code');
        return;
      }
      await AppPreferences.instance.setLoggedIn(true);
      await Get.offAllNamed<void>(AppRoutes.bottomNav);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    dailyLimitController.dispose();
    super.onClose();
  }
}
