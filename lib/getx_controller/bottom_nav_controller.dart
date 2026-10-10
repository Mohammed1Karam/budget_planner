import 'package:get/get.dart';

/// Which of the four tabs is showing.
class BottomNavController extends GetxController {
  final RxInt index = 0.obs;

  static const int home = 0;
  static const int category = 1;
  static const int profile = 2;
  static const int tips = 3;

  void select(int value) => index.value = value;
}
