import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Runs once before every test in this tree.
///
/// A plain `test()` never initialises a binding, but the design-token tests
/// read text styles, so the binding is brought up here for all of them.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await testMain();
}
