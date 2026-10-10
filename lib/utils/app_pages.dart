import 'package:get/get.dart';

import '../getx_controller/auth_controller.dart';
import '../getx_controller/category_controller.dart';
import '../getx_controller/home_controller.dart';
import '../getx_controller/operation_controller.dart';
import '../screen/about/about_screen.dart';
import '../screen/auth/create_account_screen.dart';
import '../screen/auth/create_account_success_screen.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/pin_code_screen.dart';
import '../screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import '../screen/category/add_category_screen.dart';
import '../screen/home/all_actions_screen.dart';
import '../screen/home/expense_details_screen.dart';
import '../screen/lunch/onboarding_screen.dart';
import '../screen/lunch/splash_screen.dart';
import '../screen/operation/add_operation_screen.dart';
import '../screen/operation/operation_category_screen.dart';
import '../screen/operation/operation_currency_screen.dart';
import '../screen/operation/operation_success_screen.dart';
import '../screen/profile/profile_screen.dart';
import '../screen/setting/setting_screen.dart';
import '../screen/tips/tip_article_screen.dart';
import 'app_routes.dart';

/// One [GetPage] per route, with the controllers each screen needs bound
/// lazily so nothing is constructed until it is actually navigated to.
class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(AuthController.new)),
    ),
    GetPage<void>(
      name: AppRoutes.createAccount,
      page: () => const CreateAccountScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(AuthController.new)),
    ),
    GetPage<void>(
      name: AppRoutes.createAccountInfo,
      page: () => const CreateAccountScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(AuthController.new)),
    ),
    GetPage<void>(
      name: AppRoutes.createAccountSuccess,
      page: () => const CreateAccountSuccessScreen(),
    ),
    GetPage<String>(
      name: AppRoutes.pinCode,
      page: () => const PinCodeScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.bottomNav,
      page: () => const BottomNavBarScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.allActions,
      page: () => const AllActionsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(HomeController.new, fenix: true),
      ),
    ),
    GetPage<void>(
      name: AppRoutes.expenseDetails,
      page: () => const ExpenseDetailsScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(HomeController.new, fenix: true),
      ),
    ),
    GetPage<void>(
      name: AppRoutes.addOperation,
      page: () => const AddOperationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(CategoryController.new, fenix: true);
        Get.put(OperationController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.operationCategory,
      page: () => const OperationCategoryScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(CategoryController.new, fenix: true),
      ),
    ),
    GetPage<dynamic>(
      name: AppRoutes.operationCurrency,
      page: () => const OperationCurrencyScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.operationSuccess,
      page: () => const OperationSuccessScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.addCategory,
      page: () => const AddCategoryScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(CategoryController.new, fenix: true),
      ),
    ),
    GetPage<void>(
      name: AppRoutes.tipArticle,
      page: () => const TipArticleScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.setting,
      page: () => const SettingScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.about,
      page: () => const AboutScreen(),
    ),
  ];
}
