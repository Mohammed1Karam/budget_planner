import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/operation_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// One row of the actions list: emoji tile, category over description, and the
/// signed amount on the right.
class OperationTile extends StatelessWidget {
  const OperationTile({
    super.key,
    required this.operation,
    required this.currencySymbol,
    this.onTap,
  });

  final OperationModel operation;
  final String currencySymbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final NumberFormat format = NumberFormat.decimalPattern();
    final String sign = operation.isIncome ? '+' : '-';
    final Color amountColor =
        operation.isIncome ? AppColors.income : AppColors.expense;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Container(
              width: AppDimens.operationAvatar,
              height: AppDimens.operationAvatar,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Text(
                operation.category.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    operation.category.name,
                    style: AppTextStyles.listTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    operation.title,
                    style: AppTextStyles.listSubtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$sign $currencySymbol${format.format(operation.amount)}',
              style: AppTextStyles.amount.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// The centred "Today" / "19 May" divider between groups of operations.
class OperationDateDivider extends StatelessWidget {
  const OperationDateDivider({super.key, required this.date});

  final DateTime date;

  String get _label {
    final DateTime now = DateTime.now();
    final DateTime day = DateTime(date.year, date.month, date.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diff = today.difference(day).inDays;
    if (diff == 0) return 'today'.tr;
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(child: Text(_label, style: AppTextStyles.caption)),
    );
  }
}
