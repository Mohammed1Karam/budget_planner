import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';

/// App-wide state: who is signed in and which language is active.
///
/// Registered permanently in [main], so any screen can reach the profile
/// without threading it through constructors.
class AppController extends GetxController {
  AppController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final Rx<UserModel> user = const UserModel().obs;

  /// Locale as a `language_COUNTRY` code, matching the AppTranslations keys.
  final RxString localeCode = 'en_US'.obs;

  @override
  void onInit() {
    super.onInit();
    final AppPreferences prefs = AppPreferences.instance;
    localeCode.value = prefs.localeCode ?? 'en_US';
    loadUser();
  }

  Future<void> loadUser() async {
    user.value = await _api.fetchUser();
  }

  Future<void> saveUser(UserModel value) async {
    user.value = value;
    await _api.saveUser(value);
  }

  String get currencySymbol => _symbolFor(user.value.currencyCode);

  static String _symbolFor(String code) {
    switch (code) {
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      default:
        return r'$';
    }
  }

  /// Turns a stored `language_COUNTRY` code into a [Locale].
  ///
  /// Pulled out of [changeLocale] because it is the part worth asserting on:
  /// applying the locale goes through Get.updateLocale, which rebuilds the
  /// whole app and only works under a live widget binding.
  static Locale localeOf(String code) {
    final List<String> parts = code.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  Future<void> changeLocale(String code) async {
    localeCode.value = code;
    await AppPreferences.instance.saveLocaleCode(code);
    Get.updateLocale(localeOf(code));
  }

  Future<void> logout() async {
    await AppPreferences.instance.setLoggedIn(false);
  }

  Future<void> deleteAccount() async {
    await AppPreferences.instance.clear();
    user.value = const UserModel();
  }
}
