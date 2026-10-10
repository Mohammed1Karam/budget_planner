import 'package:budget_planner/utils/app_theme.dart';
import 'package:budget_planner/utils_lan/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps a widget in the same GetX app the real screens run inside, so `.tr`
/// resolves and Get.back / Get.toNamed work in a test.
Widget harness(
  Widget child, {
  List<GetPage<dynamic>> pages = const <GetPage<dynamic>>[],
}) {
  return GetMaterialApp(
    theme: AppTheme.light,
    translations: AppTranslations(),
    locale: AppTranslations.fallback,
    fallbackLocale: AppTranslations.fallback,
    getPages: pages,
    home: Scaffold(body: child),
  );
}

/// The same wrapper for a widget that brings its own Scaffold.
Widget harnessScreen(
  Widget child, {
  List<GetPage<dynamic>> pages = const <GetPage<dynamic>>[],
}) {
  return GetMaterialApp(
    theme: AppTheme.light,
    translations: AppTranslations(),
    locale: AppTranslations.fallback,
    fallbackLocale: AppTranslations.fallback,
    getPages: pages,
    home: child,
  );
}

/// Loads the translation maps into GetX for a unit test that has no
/// GetMaterialApp above it. Without this, `.tr` echoes the key back, so an
/// assertion on user-facing copy would pass against the wrong string.
void loadTranslations() {
  Get.addTranslations(AppTranslations().keys);
  Get.locale = AppTranslations.fallback;
  Get.fallbackLocale = AppTranslations.fallback;
}

/// A clean SharedPreferences for a test that touches AppPreferences.
void resetPreferences([Map<String, Object> initial = const <String, Object>{}]) {
  SharedPreferences.setMockInitialValues(initial);
}
