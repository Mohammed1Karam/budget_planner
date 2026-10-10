import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/category_controller.dart';
import 'package:budget_planner/getx_controller/operation_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/operation/add_operation_screen.dart';
import 'package:budget_planner/screen/setting/setting_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:budget_planner/widget/date_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// The sheets, on the small phones and at enlarged text.
///
/// `small_device_test.dart` covers the screens; a sheet only exists once it is
/// opened, so it needs its own pass. The time wheel is 375pt tall on its own,
/// which is over half an SE's screen.
void main() {
  const Map<String, Size> devices = <String, Size>{
    'iPhone SE (375x667)': Size(375, 667),
    'iPhone 12 mini (375x812)': Size(375, 812),
  };
  const Map<String, double> textScales = <String, double>{
    '': 1.0,
    ' at 1.3x text': 1.3,
  };

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

  Future<void> mount(
    WidgetTester tester,
    Widget screen,
    Size size,
    double scale,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: harnessScreen(screen, pages: AppPages.pages),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
  }

  devices.forEach((String device, Size size) {
    textScales.forEach((String label, double scale) {
      group('$device$label', () {
        testWidgets('the time wheel fits', (WidgetTester tester) async {
          Get.put(CategoryController());
          Get.put(OperationController());
          await mount(tester, const AddOperationScreen(), size, scale);

          await tester.tap(find.text('Date'));
          await tester.pumpAndSettle();

          expect(find.byType(DatePickerSheet), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: 'the time wheel overflows on $device$label',
          );
        });

        testWidgets('the language sheet fits', (WidgetTester tester) async {
          await mount(tester, const SettingScreen(), size, scale);

          await tester.tap(find.text('Language'));
          await tester.pumpAndSettle();

          expect(find.byType(ListTile), findsNWidgets(2));
          expect(
            tester.takeException(),
            isNull,
            reason: 'the language sheet overflows on $device$label',
          );

          Navigator.of(tester.element(find.byType(ListTile).first)).pop();
          await tester.pumpAndSettle();
        });

        testWidgets('the delete confirmation fits',
            (WidgetTester tester) async {
          await mount(tester, const SettingScreen(), size, scale);

          await tester.tap(find.text('Remove account'));
          await tester.pumpAndSettle();

          expect(find.text('Yes'), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: 'the confirmation overflows on $device$label',
          );

          await tester.tap(find.text('No'));
          await tester.pumpAndSettle();
        });
      });
    });
  });
}
