import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/currency_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The add/edit form's rules: when Save lights up, how the Expenses / Income
/// toggle interacts with the chosen category, and what editing a saved row
/// loads back.
void main() {
  const CategoryModel food = CategoryModel(
    id: 'food',
    name: 'Food',
    emoji: '🍕',
    type: OperationType.expense,
  );
  const CategoryModel salary = CategoryModel(
    id: 'salary',
    name: 'Salary',
    emoji: '💵',
    type: OperationType.income,
  );

  late OperationController controller;

  Future<void> start({OperationModel? editing}) async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance
        .saveUser(const UserModel(name: 'Yana', currencyCode: 'USD'));

    Get.reset();
    loadTranslations();
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
    Get.put(CategoryController());
    controller = Get.put(OperationController());
    if (editing != null) controller.loadForEdit(editing);
  }

  tearDown(Get.reset);

  group('save gate', () {
    test('a blank form cannot be saved', () async {
      await start();
      expect(controller.canSave, isFalse);
    });

    test('an amount with no category cannot be saved', () async {
      await start();
      controller.amountController.text = '245';
      controller.touch();
      expect(controller.canSave, isFalse);
    });

    test('a category with no amount cannot be saved', () async {
      await start();
      controller.setCategory(food);
      expect(controller.canSave, isFalse);
    });

    test('both together can', () async {
      await start();
      controller.amountController.text = '245';
      controller.setCategory(food);
      expect(controller.canSave, isTrue);
    });

    test('a zero amount does not count', () async {
      await start();
      controller.amountController.text = '0';
      controller.setCategory(food);
      expect(controller.canSave, isFalse);
    });

    test('a comma decimal parses', () async {
      await start();
      controller.amountController.text = '12,50';
      expect(controller.amount, 12.5);
    });

    test('junk in the amount reads as zero', () async {
      await start();
      controller.amountController.text = 'abc';
      expect(controller.amount, 0);
      expect(controller.canSave, isFalse);
    });
  });

  group('toggle and category stay consistent', () {
    test('picking an income category flips the toggle to income', () async {
      await start();
      controller.setCategory(salary);
      expect(controller.type.value, OperationType.income);
    });

    test('flipping the toggle clears a category from the other side', () async {
      await start();
      controller.setCategory(food);
      expect(controller.category.value, isNotNull);

      controller.setType(OperationType.income);
      expect(
        controller.category.value,
        isNull,
        reason: 'Food cannot stay selected on the Income side',
      );
    });

    test('flipping to the side already showing changes nothing', () async {
      await start();
      controller.setCategory(food);
      controller.setType(OperationType.expense);
      expect(controller.category.value, food);
    });

    test('the label falls back to "None" with nothing picked', () async {
      await start();
      expect(controller.categoryLabel, 'None');
      controller.setCategory(food);
      expect(controller.categoryLabel, 'Food');
    });
  });

  group('editing an existing row', () {
    test('loads every field back into the form', () async {
      final OperationModel saved = OperationModel(
        id: 'op_1',
        category: salary,
        title: 'March',
        amount: 3000,
        date: DateTime(2021, 9, 2),
        note: 'March',
        currencyCode: 'EUR',
      );
      await start(editing: saved);

      expect(controller.amountController.text, '3000.00');
      expect(controller.noteController.text, 'March');
      expect(controller.category.value, salary);
      expect(controller.type.value, OperationType.income);
      expect(controller.currency.value.code, 'EUR');
      expect(controller.editing, isNotNull);
      expect(controller.canSave, isTrue);
    });

    test('a fresh form is not in edit mode', () async {
      await start();
      expect(controller.editing, isNull);
    });
  });

  group('currency', () {
    test('defaults to the profile currency', () async {
      await start();
      expect(controller.currency.value.code, 'USD');
    });

    test('can be switched', () async {
      await start();
      controller.setCurrency(CurrencyModel.byCode('JPY'));
      expect(controller.currency.value.symbol, '¥');
    });
  });

  group('date', () {
    test('defaults to today and formats the way the frame reads', () async {
      await start();
      expect(controller.dateLabel, isNotEmpty);

      controller.setDate(DateTime(2021, 9, 2));
      expect(controller.dateLabel, 'Thu 2 Sep');
    });
  });
}
