import 'package:get/get.dart';

/// The digits currently entered on the pin screen.
///
/// Kept separate from [AuthController] so the same screen can be pushed to set
/// a pin during sign-up and to change it later from Profile.
class PinController extends GetxController {
  final RxString entered = ''.obs;

  static const int length = 4;

  bool get isComplete => entered.value.length == length;

  void push(String digit) {
    if (entered.value.length >= length) return;
    entered.value += digit;
  }

  void backspace() {
    final String value = entered.value;
    if (value.isEmpty) return;
    entered.value = value.substring(0, value.length - 1);
  }

  void clear() => entered.value = '';
}
