import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../api/budget_api.dart';
import '../models/category_model.dart';
import '../models/currency_model.dart';
import '../models/operation_model.dart';
import '../utils/app_routes.dart';
import '../widget/date_picker_sheet.dart';
import 'app_controller.dart';
import 'category_controller.dart';
import 'home_controller.dart';

/// The add/edit operation form, shared by "Add New Operation" and
/// "Expense Details" -- the latter is the same form opened on a saved row.
class OperationController extends GetxController {
  OperationController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final Rx<OperationType> type = OperationType.expense.obs;
  final Rxn<CategoryModel> category = Rxn<CategoryModel>();
  final Rx<DateTime> date = DateTime.now().obs;
  final Rx<CurrencyModel> currency = CurrencyModel.usd.obs;
  final RxBool saving = false.obs;
  final RxInt revision = 0.obs;

  /// Set when the form was opened on an existing row, so saving updates
  /// rather than appends.
  OperationModel? editing;

  @override
  void onInit() {
    super.onInit();
    currency.value = CurrencyModel.byCode(
      Get.find<AppController>().user.value.currencyCode,
    );
    final Object? argument = Get.arguments;
    if (argument is OperationModel) loadForEdit(argument);
  }

  void loadForEdit(OperationModel operation) {
    editing = operation;
    amountController.text = operation.amount.toStringAsFixed(2);
    noteController.text = operation.note;
    type.value = operation.category.type;
    category.value = operation.category;
    date.value = operation.date;
    currency.value = CurrencyModel.byCode(operation.currencyCode);
    touch();
  }

  void touch() => revision.value++;

  double get amount =>
      double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

  bool get canSave {
    revision.value;
    return amount > 0 && category.value != null;
  }

  String get dateLabel => DateFormat('EEE d MMM').format(date.value);

  String get categoryLabel => category.value?.name ?? 'none'.tr;

  /// Flipping the toggle clears a category that belongs to the other side.
  void setType(OperationType value) {
    if (type.value == value) return;
    type.value = value;
    if (category.value?.type != value) category.value = null;
    touch();
  }

  void setCategory(CategoryModel value) {
    category.value = value;
    type.value = value.type;
    touch();
  }

  void setDate(DateTime value) {
    date.value = value;
    touch();
  }

  void setCurrency(CurrencyModel value) {
    currency.value = value;
    touch();
  }

  Future<void> openCategoryPicker() async {
    final Object? picked = await Get.toNamed<Object?>(
      AppRoutes.operationCategory,
      arguments: type.value,
    );
    if (picked is CategoryModel) setCategory(picked);
  }

  Future<void> openCurrencyPicker() async {
    final Object? picked =
        await Get.toNamed<Object?>(AppRoutes.operationCurrency);
    if (picked is CurrencyModel) setCurrency(picked);
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked =
        await DatePickerSheet.show(context, initial: date.value);
    if (picked != null) setDate(picked);
  }

  Future<void> save() async {
    if (!canSave) return;
    saving.value = true;
    try {
      final OperationModel operation = OperationModel(
        id: editing?.id ??
            'op_${DateTime.now().microsecondsSinceEpoch}',
        category: category.value!,
        title: noteController.text.trim().isEmpty
            ? category.value!.name
            : noteController.text.trim(),
        amount: amount,
        date: date.value,
        note: noteController.text.trim(),
        currencyCode: currency.value.code,
      );
      await _api.saveOperation(operation);
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().load();
      }
      await Get.offNamed<void>(AppRoutes.operationSuccess);
    } finally {
      saving.value = false;
    }
  }

  Future<void> delete() async {
    final OperationModel? current = editing;
    if (current == null) return;
    await _api.deleteOperation(current.id);
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().load();
    }
    Get.back<void>();
  }

  /// The categories the picker shows, honouring the toggle.
  List<CategoryModel> categoriesFor(OperationType value) =>
      Get.find<CategoryController>().ofType(value);

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
