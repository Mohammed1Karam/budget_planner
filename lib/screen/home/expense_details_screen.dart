import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../getx_controller/home_controller.dart';
import '../../models/category_model.dart';
import '../../models/currency_model.dart';
import '../../models/operation_model.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_svg.dart';
import '../../widget/info_row.dart';
import '../../widget/type_card.dart';

/// Expense Details: a saved operation shown read-only.
///
/// The frame is the add form with its values filled in, the category as the
/// title and the amount below it, and no Save button — closing is the only
/// action, apart from deleting the row.
class ExpenseDetailsScreen extends StatelessWidget {
  const ExpenseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? argument = Get.arguments;
    if (argument is! OperationModel) {
      return const _MissingOperation();
    }

    final OperationModel operation = argument;
    final CurrencyModel currency =
        CurrencyModel.byCode(operation.currencyCode);
    final NumberFormat amount = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => _confirmDelete(operation),
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                  ),
                ),
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
                      operation.category.name,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currency.symbol} ${amount.format(operation.amount)}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(
                        color: operation.isIncome
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 21),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TypeCard(
                            type: OperationType.expense,
                            selected: !operation.isIncome,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TypeCard(
                            type: OperationType.income,
                            selected: operation.isIncome,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    InfoRow(
                      label: 'category'.tr,
                      value: operation.category.name,
                      showChevron: true,
                    ),
                    InfoRow(
                      label: 'date'.tr,
                      value: DateFormat('EEE d MMM').format(operation.date),
                      showChevron: true,
                    ),
                    InfoRow(
                      label: 'currency'.tr,
                      value: currency.name,
                      showChevron: true,
                      showDivider: false,
                    ),
                    const SizedBox(height: 11),
                    _Note(text: operation.note),
                    const SizedBox(height: 31),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(OperationModel operation) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(operation.category.name, style: AppTextStyles.sectionTitle),
        content: Text(
          'Remove this operation?',
          style: AppTextStyles.body,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text('no'.tr, style: AppTextStyles.fieldValue),
          ),
          TextButton(
            onPressed: () async {
              Get.back<void>();
              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().delete(operation.id);
              }
              Get.back<void>();
            },
            child: Text(
              'yes'.tr,
              style:
                  AppTextStyles.fieldLabel.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// The note box, showing whatever was typed when the row was saved.
class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppDimens.cardShadow,
      ),
      child: Text(
        text.isEmpty ? 'note'.tr : text,
        style: text.isEmpty ? AppTextStyles.fieldValue : AppTextStyles.body,
      ),
    );
  }
}

/// Reached only if the route is opened without an operation, which the app
/// never does; shown rather than thrown so a bad deep link is survivable.
class _MissingOperation extends StatelessWidget {
  const _MissingOperation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(leading: const AppBackButton()),
      body: Center(
        child: Text('No operation selected.', style: AppTextStyles.body),
      ),
    );
  }
}
