/// Named routes, one per Figma frame.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String createAccountInfo = '/create-account/info';
  static const String createAccountSuccess = '/create-account/success';
  static const String pinCode = '/pin-code';

  static const String bottomNav = '/app';
  static const String allActions = '/actions';
  static const String expenseDetails = '/actions/details';

  static const String addOperation = '/operation/new';
  static const String operationCategory = '/operation/category';
  static const String operationCurrency = '/operation/currency';
  static const String operationSuccess = '/operation/success';

  static const String addCategory = '/category/new';

  static const String tipArticle = '/tips/article';

  static const String profile = '/profile';
  static const String setting = '/setting';
  static const String about = '/setting/about';
}
