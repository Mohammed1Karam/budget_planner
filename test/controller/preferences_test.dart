import 'package:budget_planner/models/category_model.dart';
import 'package:budget_planner/models/operation_model.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// The local store. Everything the app shows survives a restart through here,
/// so each type gets a round trip.
void main() {
  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
  });

  test('a fresh install has seen no onboarding and is signed out', () {
    expect(AppPreferences.instance.onboardingSeen, isFalse);
    expect(AppPreferences.instance.isLoggedIn, isFalse);
    expect(AppPreferences.instance.user.name, isEmpty);
    expect(AppPreferences.instance.operations, isEmpty);
    expect(AppPreferences.instance.customCategories, isEmpty);
  });

  test('the onboarding flag sticks', () async {
    await AppPreferences.instance.setOnboardingSeen();
    expect(AppPreferences.instance.onboardingSeen, isTrue);
  });

  test('the profile round trips', () async {
    const UserModel user = UserModel(
      name: 'Julia',
      email: 'julia@example.com',
      currencyCode: 'EUR',
      dailyLimit: 1200,
      pin: '4321',
    );
    await AppPreferences.instance.saveUser(user);

    final UserModel back = AppPreferences.instance.user;
    expect(back.name, 'Julia');
    expect(back.email, 'julia@example.com');
    expect(back.currencyCode, 'EUR');
    expect(back.dailyLimit, 1200);
    expect(back.pin, '4321');
  });

  test('operations round trip with their category and date', () async {
    final OperationModel operation = OperationModel(
      id: 'op_1',
      category: const CategoryModel(
        id: 'food',
        name: 'Food',
        emoji: '🍕',
        type: OperationType.expense,
      ),
      title: 'Pizza Day',
      amount: 423.5,
      date: DateTime(2021, 5, 19, 14, 30),
      note: 'with Yana',
    );
    await AppPreferences.instance.saveOperations(<OperationModel>[operation]);

    final OperationModel back = AppPreferences.instance.operations.single;
    expect(back.id, 'op_1');
    expect(back.category.emoji, '🍕');
    expect(back.amount, 423.5);
    expect(back.date, DateTime(2021, 5, 19, 14, 30));
    expect(back.note, 'with Yana');
    expect(back.isIncome, isFalse);
    expect(back.signedAmount, -423.5);
  });

  test('income keeps a positive signed amount', () async {
    final OperationModel operation = OperationModel(
      id: 'op_2',
      category: const CategoryModel(
        id: 'salary',
        name: 'Salary',
        emoji: '💵',
        type: OperationType.income,
      ),
      title: 'March',
      amount: 3000,
      date: DateTime(2021, 3, 1),
    );
    await AppPreferences.instance.saveOperations(<OperationModel>[operation]);

    expect(AppPreferences.instance.operations.single.signedAmount, 3000);
  });

  test('custom categories round trip', () async {
    await AppPreferences.instance.saveCustomCategories(<CategoryModel>[
      const CategoryModel(
        id: 'coffee',
        name: 'Coffee',
        emoji: '☕',
        type: OperationType.expense,
      ),
    ]);

    expect(AppPreferences.instance.customCategories.single.name, 'Coffee');
  });

  test('clear wipes everything, as Remove account expects', () async {
    await AppPreferences.instance.setOnboardingSeen();
    await AppPreferences.instance.setLoggedIn(true);
    await AppPreferences.instance.saveUser(const UserModel(name: 'Julia'));

    await AppPreferences.instance.clear();

    expect(AppPreferences.instance.onboardingSeen, isFalse);
    expect(AppPreferences.instance.isLoggedIn, isFalse);
    expect(AppPreferences.instance.user.name, isEmpty);
  });
}
