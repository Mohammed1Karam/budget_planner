import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/operation_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_svg.dart';
import '../../widget/info_row.dart';
import '../../widget/money_field.dart';
import '../../widget/primary_button.dart';
import '../../widget/type_card.dart';

/// "Add New Operation", "New Operation - Overall" and "Expense Details".
///
/// All three Figma frames are one form in different states: empty, filled in,
/// and opened on a saved row. [OperationController.editing] decides which,
/// and the only visible difference is the title and the delete action.
class AddOperationScreen extends StatelessWidget {
  const AddOperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OperationController controller = Get.put(OperationController());
    final bool editing = controller.editing != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                if (editing)
                  IconButton(
                    onPressed: controller.delete,
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                  )
                else
                  const SizedBox(width: 48),
                const Spacer(),
                AppCloseButton(onTap: () => Get.back<void>()),
              ],
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
                      'add_operation'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 21),
                    Obx(
                      () => MoneyField(
                        controller: controller.amountController,
                        currencySymbol: controller.currency.value.symbol,
                        onChanged: (_) => controller.touch(),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Obx(
                      () => Row(
                        children: <Widget>[
                          Expanded(
                            child: TypeCard(
                              type: OperationType.expense,
                              selected:
                                  controller.type.value == OperationType.expense,
                              onTap: () =>
                                  controller.setType(OperationType.expense),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TypeCard(
                              type: OperationType.income,
                              selected:
                                  controller.type.value == OperationType.income,
                              onTap: () =>
                                  controller.setType(OperationType.income),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Obx(
                      () => InfoRow(
                        label: 'category'.tr,
                        value: controller.categoryLabel,
                        showChevron: true,
                        onTap: controller.openCategoryPicker,
                      ),
                    ),
                    Obx(
                      () => InfoRow(
                        label: 'date'.tr,
                        value: controller.dateLabel,
                        showChevron: true,
                        onTap: () => controller.pickDate(context),
                      ),
                    ),
                    Obx(
                      () => InfoRow(
                        label: 'currency'.tr,
                        value: controller.currency.value.name,
                        showChevron: true,
                        showDivider: false,
                        onTap: controller.openCurrencyPicker,
                      ),
                    ),
                    const SizedBox(height: 11),
                    NoteField(
                      controller: controller.noteController,
                      onChanged: (_) => controller.touch(),
                    ),
                    const SizedBox(height: 31),
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
                  label: 'add'.tr,
                  loading: controller.saving.value,
                  onPressed: controller.canSave ? controller.save : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
