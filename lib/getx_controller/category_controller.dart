import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/category_model.dart';

/// The category catalogue: the defaults the design ships plus anything the
/// user adds from "Add New Category".
class CategoryController extends GetxController {
  CategoryController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  /// Which half of the Expenses / Income toggle is showing.
  final Rx<OperationType> filter = OperationType.expense.obs;

  /// The exact list on "New Operation Category - Expenses".
  static const List<CategoryModel> defaultExpenses = <CategoryModel>[
    CategoryModel(id: 'shopping', name: 'Shopping', emoji: '👚', type: OperationType.expense),
    CategoryModel(id: 'travel', name: 'Travel', emoji: '🚘', type: OperationType.expense),
    CategoryModel(id: 'food', name: 'Food', emoji: '🍕', type: OperationType.expense),
    CategoryModel(id: 'medicine', name: 'Medicine', emoji: '💊', type: OperationType.expense),
    CategoryModel(id: 'cash', name: 'Cash', emoji: '💵', type: OperationType.expense),
    CategoryModel(id: 'sport', name: 'Sport', emoji: '🏓', type: OperationType.expense),
    CategoryModel(id: 'education', name: 'Education', emoji: '📚', type: OperationType.expense),
    CategoryModel(id: 'accommodation', name: 'Accommodation', emoji: '🏠', type: OperationType.expense),
    CategoryModel(id: 'other_expense', name: 'Other', emoji: '📦', type: OperationType.expense),
  ];

  /// And the list on "New Operation Category - Incomes".
  static const List<CategoryModel> defaultIncomes = <CategoryModel>[
    CategoryModel(id: 'premium', name: 'Premium', emoji: '🎖️', type: OperationType.income),
    CategoryModel(id: 'salary', name: 'Salary', emoji: '💵', type: OperationType.income),
    CategoryModel(id: 'gift', name: 'Gift', emoji: '🎁', type: OperationType.income),
    CategoryModel(id: 'sales', name: 'Sales', emoji: '💰', type: OperationType.income),
    CategoryModel(id: 'other_income', name: 'Other', emoji: '📦', type: OperationType.income),
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final List<CategoryModel> custom = await _api.fetchCustomCategories();
    categories
      ..clear()
      ..addAll(defaultExpenses)
      ..addAll(defaultIncomes)
      ..addAll(custom);
  }

  List<CategoryModel> get visible =>
      categories.where((c) => c.type == filter.value).toList();

  List<CategoryModel> ofType(OperationType type) =>
      categories.where((c) => c.type == type).toList();

  void setFilter(OperationType type) => filter.value = type;

  CategoryModel byId(String id) => categories.firstWhere(
        (c) => c.id == id,
        orElse: () => defaultExpenses.first,
      );

  Future<void> add({required String name, required OperationType type, String emoji = '📦'}) async {
    final CategoryModel category = CategoryModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      type: type,
    );
    await _api.saveCustomCategory(category);
    categories.add(category);
  }
}
