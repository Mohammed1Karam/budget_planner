import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/utils/app_colors.dart';
import 'package:budget_planner/utils/app_dimens.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/widget/date_picker_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// "New Operation - Date": the time wheel the Date row opens.
void main() {
  const Size frame = Size(414, 896);

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(
      const UserModel(name: 'Yana', dailyLimit: 2032, pin: '1234'),
    );

    Get.reset();
    Get.put(AppController(), permanent: true);
    await Get.find<AppController>().loadUser();
  });

  tearDown(Get.reset);

  Future<void> openForm(WidgetTester tester) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Get.put(CategoryController());
    Get.put(OperationController());

    await tester.pumpWidget(
      harnessScreen(const AddOperationScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('the Date row opens the sheet', (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerSheet), findsOneWidget);
    expect(find.text('Pick time'), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sheet is the height the design draws',
      (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(CupertinoDatePicker)).height,
      AppDimens.pickerWheelHeight,
    );
  });

  testWidgets('the wheel uses the app typeface', (WidgetTester tester) async {
    await openForm(tester);

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();

    final CupertinoTheme theme = tester.widget<CupertinoTheme>(
      find
          .ancestor(
            of: find.byType(CupertinoDatePicker),
            matching: find.byType(CupertinoTheme),
          )
          .first,
    );
    final TextStyle style = theme.data.textTheme.dateTimePickerTextStyle;
    expect(style.fontSize, 23);
    expect(style.color, AppColors.wheelSelected);
  });

  testWidgets('confirming returns a date to the form',
      (WidgetTester tester) async {
    await openForm(tester);

    final OperationController controller = Get.find<OperationController>();
    final String before = controller.dateLabel;

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();

    // Spin the day column, then confirm.
    await tester.drag(
      find.byType(CupertinoDatePicker),
      const Offset(0, -AppDimens.pickerRowHeight * 2),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, 'Add').last);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerSheet), findsNothing);
    expect(controller.dateLabel, isNot(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissing leaves the date alone', (WidgetTester tester) async {
    await openForm(tester);

    final OperationController controller = Get.find<OperationController>();
    final String before = controller.dateLabel;

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(DatePickerSheet))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerSheet), findsNothing);
    expect(controller.dateLabel, before);
  });
}
