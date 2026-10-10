import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The catalogue behind both category screens: the defaults the Figma frames
/// list, plus whatever the user adds.
void main() {
  late CategoryController controller;

  Future<void> start() async {
    resetPreferences();
    await AppPreferences.init();
    Get.reset();
    controller = Get.put(CategoryController());
    await controller.load();
  }

  tearDown(Get.reset);

  test('ships the nine expense categories the frame lists', () async {
    await start();
    final List<String> names = controller
        .ofType(OperationType.expense)
        .map((c) => c.name)
        .toList();

    expect(
      names,
      containsAll(<String>[
        'Shopping',
        'Travel',
        'Food',
        'Medicine',
        'Cash',
        'Sport',
        'Education',
        'Accommodation',
        'Other',
      ]),
    );
  });

  test('ships the five income categories the frame lists', () async {
    await start();
    final List<String> names =
        controller.ofType(OperationType.income).map((c) => c.name).toList();

    expect(
      names,
      containsAll(<String>['Premium', 'Salary', 'Gift', 'Sales', 'Other']),
    );
  });

  test('every default carries an emoji, since the list renders it', () async {
    await start();
    for (final CategoryModel category in controller.categories) {
      expect(category.emoji, isNotEmpty, reason: '${category.name} has no icon');
    }
  });

  test('ids are unique', () async {
    await start();
    final Set<String> ids =
        controller.categories.map((c) => c.id).toSet();
    expect(ids, hasLength(controller.categories.length));
  });

  test('the toggle filters what the list shows', () async {
    await start();
    controller.setFilter(OperationType.expense);
    expect(
      controller.visible.every((c) => c.type == OperationType.expense),
      isTrue,
    );

    controller.setFilter(OperationType.income);
    expect(
      controller.visible.every((c) => c.type == OperationType.income),
      isTrue,
    );
  });

  test('a custom category is added and survives a reload', () async {
    await start();
    final int before = controller.ofType(OperationType.expense).length;

    await controller.add(name: 'Coffee', type: OperationType.expense, emoji: '☕');
    expect(controller.ofType(OperationType.expense), hasLength(before + 1));

    await controller.load();
    final CategoryModel saved =
        controller.categories.firstWhere((c) => c.name == 'Coffee');
    expect(saved.emoji, '☕');
    expect(saved.type, OperationType.expense);
  });

  test('a custom name is trimmed', () async {
    await start();
    await controller.add(name: '  Coffee  ', type: OperationType.expense);
    expect(controller.categories.any((c) => c.name == 'Coffee'), isTrue);
  });

  test('an unknown id falls back rather than throwing', () async {
    await start();
    expect(controller.byId('nope').name, isNotEmpty);
  });
}
