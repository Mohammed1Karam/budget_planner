import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/home_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Home's numbers: what counts towards the daily limit, when the screen flips
/// to its reach-limit variant, and how the history groups by day.
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

  OperationModel op(CategoryModel category, double amount, DateTime date) =>
      OperationModel(
        id: 'op_${date.microsecondsSinceEpoch}_$amount',
        category: category,
        title: category.name,
        amount: amount,
        date: date,
      );

  late HomeController controller;

  Future<void> seed(List<OperationModel> operations, {double limit = 500}) async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance
        .saveUser(UserModel(name: 'Yana', dailyLimit: limit, pin: '1234'));
    await AppPreferences.instance.saveOperations(operations);

    Get.reset();
    Get.put(AppController());
    await Get.find<AppController>().loadUser();
    controller = Get.put(HomeController());
    await controller.load();
  }

  tearDown(Get.reset);

  test('an empty ledger spends nothing and keeps the full limit', () async {
    await seed(<OperationModel>[]);
    expect(controller.spentToday, 0);
    expect(controller.remainingToday, 500);
    expect(controller.hasReachedLimit, isFalse);
  });

  test('only today\'s expenses count towards the limit', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      op(food, 120, now),
      op(food, 80, now),
      op(food, 999, now.subtract(const Duration(days: 2))),
    ]);

    expect(controller.spentToday, 200);
    expect(controller.remainingToday, 300);
  });

  test('income does not offset the daily limit', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      op(food, 200, now),
      op(salary, 5000, now),
    ]);

    expect(
      controller.spentToday,
      200,
      reason: 'the design labels this "spent today", not a net figure',
    );
  });

  test('reaching the limit trips the banner', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[op(food, 500, now)]);

    expect(controller.hasReachedLimit, isTrue);
    expect(controller.remainingToday, 0);
  });

  test('overspending never reports a negative balance', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[op(food, 900, now)]);

    expect(controller.remainingToday, 0);
    expect(controller.hasReachedLimit, isTrue);
  });

  test('with no limit set the banner stays off', () async {
    await seed(<OperationModel>[op(food, 900, DateTime.now())], limit: 0);
    expect(controller.hasReachedLimit, isFalse);
  });

  test('Home previews only the four most recent rows', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      for (int i = 0; i < 9; i++)
        op(food, 10.0 + i, now.subtract(Duration(hours: i))),
    ]);

    expect(controller.operations, hasLength(9));
    expect(controller.recent, hasLength(4));
  });

  test('operations come back newest first', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      op(food, 1, now.subtract(const Duration(days: 3))),
      op(food, 2, now),
      op(food, 3, now.subtract(const Duration(days: 1))),
    ]);

    final List<DateTime> dates =
        controller.operations.map((o) => o.date).toList();
    for (int i = 1; i < dates.length; i++) {
      expect(dates[i].isBefore(dates[i - 1]), isTrue);
    }
  });

  test('the history groups by calendar day, newest day first', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      op(food, 10, now),
      op(food, 20, now.subtract(const Duration(hours: 2))),
      op(food, 30, now.subtract(const Duration(days: 1))),
    ]);

    final Map<DateTime, List<OperationModel>> grouped = controller.groupedByDay;
    expect(grouped, hasLength(2));

    final List<DateTime> days = grouped.keys.toList();
    expect(days.first.isAfter(days.last), isTrue);
    expect(grouped[days.first], hasLength(2));
    expect(grouped[days.last], hasLength(1));
  });

  test('totals split by side of the ledger', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[
      op(food, 100, now),
      op(food, 50, now),
      op(salary, 3000, now),
    ]);

    expect(controller.totalOf(OperationType.expense), 150);
    expect(controller.totalOf(OperationType.income), 3000);
  });

  test('deleting a row drops it and reloads', () async {
    final DateTime now = DateTime.now();
    await seed(<OperationModel>[op(food, 100, now), op(salary, 20, now)]);

    final String id = controller.operations.first.id;
    await controller.delete(id);

    expect(controller.operations, hasLength(1));
    expect(controller.operations.any((o) => o.id == id), isFalse);
  });
}
