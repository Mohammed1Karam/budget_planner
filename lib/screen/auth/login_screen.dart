import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/auth_controller.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';
import '../../widget/primary_button.dart';

/// Login: the 120x115 budget mark, a title, two plain fields and the button,
/// with "Create here!" underneath.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 60),
              const Center(
                child: AppSvg(AppAssets.icBudget, width: 120, height: 115),
              ),
              const SizedBox(height: 33),
              Text(
                'login'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 11),
              Text(
                'login_intro'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 50),
              _FilledField(
                controller: controller.emailController,
                hint: 'email_address_hint'.tr,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => controller.touch(),
              ),
              const SizedBox(height: 15),
              Obx(
                () => _PinSummaryField(
                  filled: controller.pin.value.length,
                  onTap: () async {
                    final Object? pin =
                        await Get.toNamed<Object?>(AppRoutes.pinCode);
                    if (pin is String) controller.setPin(pin);
                  },
                ),
              ),
              const SizedBox(height: 30),
              Obx(
                () => PrimaryButton(
                  label: 'login_action'.tr,
                  loading: controller.loading.value,
                  onPressed: controller.canLogin ? controller.submitLogin : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text('not_registered'.tr, style: AppTextStyles.body),
                    TextButton(
                      onPressed: () =>
                          Get.toNamed<void>(AppRoutes.createAccount),
                      child: Text(
                        'create_here'.tr,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 374x45 grey input used on Login -- the design's only filled field.
class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusField),
        boxShadow: AppDimens.fieldShadow,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.fieldLabel,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: AppTextStyles.fieldValue,
        ),
      ),
    );
  }
}

/// Stands in for the pin field: tapping it opens the keypad screen.
class _PinSummaryField extends StatelessWidget {
  const _PinSummaryField({required this.filled, required this.onTap});

  final int filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusField),
          boxShadow: AppDimens.fieldShadow,
        ),
        child: Row(
          children: <Widget>[
            Text(
              filled == 0 ? 'pin_code_hint'.tr : '•' * filled,
              style: filled == 0
                  ? AppTextStyles.fieldValue
                  : AppTextStyles.fieldLabel,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
