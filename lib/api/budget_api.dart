import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../models/tip_model.dart';
import '../models/user_model.dart';
import '../preferences/app_preferences.dart';
import 'api_client.dart';

/// Every read and write the app performs, in one place.
///
/// Today each call resolves against [AppPreferences]; the [ApiClient] field is
/// already threaded through so the bodies can move to the network one at a
/// time without touching the controllers.
class BudgetApi {
  BudgetApi({ApiClient? client, AppPreferences? preferences})
      : _client = client ?? ApiClient(),
        _preferences = preferences ?? AppPreferences.instance;

  // ignore: unused_field -- held for the eventual move off local storage.
  final ApiClient _client;
  final AppPreferences _preferences;

  Future<UserModel> fetchUser() async => _preferences.user;

  Future<void> saveUser(UserModel user) => _preferences.saveUser(user);

  Future<List<OperationModel>> fetchOperations() async {
    final List<OperationModel> operations = _preferences.operations;
    operations.sort((a, b) => b.date.compareTo(a.date));
    return operations;
  }

  Future<void> saveOperation(OperationModel operation) async {
    final List<OperationModel> operations = _preferences.operations;
    final int index = operations.indexWhere((o) => o.id == operation.id);
    if (index >= 0) {
      operations[index] = operation;
    } else {
      operations.add(operation);
    }
    await _preferences.saveOperations(operations);
  }

  Future<void> deleteOperation(String id) async {
    final List<OperationModel> operations = _preferences.operations
      ..removeWhere((o) => o.id == id);
    await _preferences.saveOperations(operations);
  }

  Future<List<CategoryModel>> fetchCustomCategories() async =>
      _preferences.customCategories;

  Future<void> saveCustomCategory(CategoryModel category) async {
    final List<CategoryModel> categories = _preferences.customCategories;
    final int index = categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      categories[index] = category;
    } else {
      categories.add(category);
    }
    await _preferences.saveCustomCategories(categories);
  }

  /// The Tips grid. Static for now -- the design ships six fixed articles.
  Future<List<TipModel>> fetchTips() async => TipSeed.all;
}

/// The article copy as it appears on the Tip Article frame.
class TipSeed {
  const TipSeed._();

  static final List<TipModel> all = <TipModel>[
    TipModel(
      id: 'save-budget-10-tips',
      title: 'How to save a budget 10 tips',
      publishedAt: DateTime.now().subtract(const Duration(days: 90)),
      image: 'assets/images/yana_ui_kit_illustration_01.svg',
      lead:
          'We all want to save money, but doing it consistently is the hard '
          'part. A budget only works when it survives contact with an ordinary '
          'week, so start with the habits rather than the spreadsheet.',
      bullets: <String>[
        'eliminate your debt;',
        'set savings goals;',
        'pay yourself first;',
        'stop smoking.',
      ],
      body:
          'For most of us, keeping to a budget means deciding once and then '
          'letting the decision carry the month. Review it after four weeks, '
          'adjust the categories that never fit, and leave the rest alone.',
    ),
    TipModel(
      id: 'see-where-money-goes',
      title: 'See where your money goes',
      publishedAt: DateTime.now().subtract(const Duration(days: 365)),
      image: 'assets/images/yana_ui_kit_illustration_02.svg',
      lead:
          'Tracking beats guessing. Log a fortnight of ordinary spending and '
          'the pattern shows up on its own.',
      bullets: <String>[
        'log every expense;',
        'group by category;',
        'compare week to week;',
        'cut one habit.',
      ],
      body:
          'Once the categories are honest, the daily limit stops feeling '
          'arbitrary and starts doing real work.',
    ),
    TipModel(
      id: 'take-hold-of-finances',
      title: 'Take hold of your finances',
      publishedAt: DateTime.now().subtract(const Duration(days: 90)),
      image: 'assets/images/yana_ui_kit_illustration_03.svg',
      lead:
          'Managing your finances can be effortless once the routine is in '
          'place and the numbers are in front of you.',
      bullets: <String>[
        'automate your savings;',
        'keep one month of buffer;',
        'review subscriptions;',
        'set a daily limit.',
      ],
      body:
          'Small, repeated decisions compound far faster than one dramatic '
          'month of restraint.',
    ),
  ];
}
