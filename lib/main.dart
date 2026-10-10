import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'getx_controller/app_controller.dart';
import 'preferences/app_preferences.dart';
import 'utils/app_pages.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils_lan/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The whole app reads its state out of here, so it has to be ready before
  // the first frame.
  await AppPreferences.init();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  Get.put(AppController(), permanent: true);

  runApp(const BudgetPlannerApp());
}

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String saved =
        AppPreferences.instance.localeCode ?? 'en_US';
    final List<String> parts = saved.split('_');

    return GetMaterialApp(
      title: 'Budget Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: AppTranslations(),
      locale: Locale(parts.first, parts.length > 1 ? parts[1] : null),
      fallbackLocale: AppTranslations.fallback,
      supportedLocales: AppTranslations.supported,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
