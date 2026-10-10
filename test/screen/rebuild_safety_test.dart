import 'package:budget_planner/getx_controller/app_controller.dart';
import 'package:budget_planner/getx_controller/auth_controller.dart';
import 'package:budget_planner/models/user_model.dart';
import 'package:budget_planner/preferences/app_preferences.dart';
import 'package:budget_planner/screen/auth/login_screen.dart';
import 'package:budget_planner/utils/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/harness.dart';

/// Screens that register their controller from `build` are re-registering it on
/// every rebuild. Get.put replaces the existing instance rather than reusing
/// it, so anything the user has typed would be lost the moment the widget
/// rebuilds — which happens as soon as the keyboard opens and MediaQuery
/// changes.
void main() {
  const Size frame = Size(414, 896);

  setUp(() async {
    resetPreferences();
    await AppPreferences.init();
    await AppPreferences.instance.saveUser(const UserModel());
    Get.reset();
    Get.put(AppController());
  });

  tearDown(Get.reset);

  testWidgets('typed input survives a rebuild of the login screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harnessScreen(const LoginScreen(), pages: AppPages.pages),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField).first, 'yana@example.com');
    await tester.pump();

    final AuthController before = Get.find<AuthController>();
    expect(before.emailController.text, 'yana@example.com');

    // Force the rebuild a keyboard or rotation would cause.
    tester.view.physicalSize = const Size(414, 600);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('yana@example.com'),
      findsOneWidget,
      reason: 'the field was cleared by a rebuild',
    );
    expect(
      identical(Get.find<AuthController>(), before),
      isTrue,
      reason: 'the controller was replaced on rebuild',
    );
  });
}
