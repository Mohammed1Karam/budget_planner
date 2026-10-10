import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/pin_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/fill_or_scroll.dart';
import '../../widget/pin_keypad.dart';
import '../../widget/primary_button.dart';

/// Pin Code: two digit boxes at y=195, the 3x4 keypad from y=310, and the
/// Apply button at the bottom. Returns the entered pin to whoever pushed it.
class PinCodeScreen extends StatelessWidget {
  const PinCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());

    return AppScaffold(
      body: FillOrScroll(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Text('enter_passcode'.tr, style: AppTextStyles.headline),
            const SizedBox(height: 11),
            Text(
              'new_pin'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 30),
            Obx(
              () => PinDisplay(
                length: PinController.length,
                filled: controller.entered.value.length,
              ),
            ),
            const SizedBox(height: 40),
            PinKeypad(
              onDigit: controller.push,
              onBackspace: controller.backspace,
            ),
            const Spacer(),
            const SizedBox(height: 24),
            Obx(
              () => PrimaryButton(
                label: 'apply'.tr,
                onPressed: controller.isComplete
                    ? () => Get.back<String>(result: controller.entered.value)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// The dotted row above the keypad, kept here so the screen reads top to
/// bottom the way the frame does.
class PinBoxes extends StatelessWidget {
  const PinBoxes({super.key, required this.filled, required this.length});

  final int filled;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (int index) {
        return Container(
          width: 46,
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          ),
          alignment: Alignment.center,
          child: Text(
            index < filled ? '•' : '',
            style: AppTextStyles.keypadDigit,
          ),
        );
      }),
    );
  }
}
