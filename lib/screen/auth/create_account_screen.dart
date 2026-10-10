import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/auth_controller.dart';
import '../../models/currency_model.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_svg.dart';
import '../../widget/info_row.dart';
import '../../widget/primary_button.dart';

/// Create Account, and "Create Account - Info" once the rows carry values.
///
/// Both Figma frames are the same screen: five rows between hairlines, with
/// the button disabled until every one of them is filled in.
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(onTap: () => Get.back<void>()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(
                      child: AppSvg(
                        AppAssets.icBudget,
                        width: 120,
                        height: 115,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'get_started'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'create_account_intro'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 22),
                    InfoFieldRow(
                      label: 'name'.tr,
                      controller: controller.nameController,
                      hint: 'none'.tr,
                      onChanged: (_) => controller.touch(),
                    ),
                    InfoFieldRow(
                      label: 'email_address'.tr,
                      controller: controller.emailController,
                      hint: 'none'.tr,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => controller.touch(),
                    ),
                    Obx(
                      () => InfoRow(
                        label: 'currency'.tr,
                        value: controller.currency.value.name,
                        showChevron: true,
                        onTap: () async {
                          final Object? picked = await Get.toNamed<Object?>(
                            AppRoutes.operationCurrency,
                          );
                          if (picked is CurrencyModel) {
                            controller.selectCurrency(picked);
                          }
                        },
                      ),
                    ),
                    InfoFieldRow(
                      label: 'daily_limit'.tr,
                      controller: controller.dailyLimitController,
                      hint: r'$ 5000',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => controller.touch(),
                    ),
                    Obx(
                      () => InfoRow(
                        label: 'set_your_pin'.tr,
                        value: controller.pin.value.isEmpty
                            ? 'none'.tr
                            : '•' * controller.pin.value.length,
                        showChevron: true,
                        showDivider: false,
                        onTap: () async {
                          final Object? pin = await Get.toNamed<Object?>(
                            AppRoutes.pinCode,
                          );
                          if (pin is String) controller.setPin(pin);
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                0,
                AppDimens.screenPadding,
                24,
              ),
              child: Obx(
                () => PrimaryButton(
                  label: 'create_account'.tr,
                  loading: controller.loading.value,
                  onPressed: controller.canSubmit
                      ? controller.submitCreateAccount
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
