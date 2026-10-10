import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// One of the paired 182x92 Expenses / Income cards on the operation forms.
///
/// The design draws both as white lifted cards with a coloured arrow above the
/// label — red and pointing up for money out, green and pointing down for
/// money in. Selecting one outlines it in its own colour rather than filling
/// it, which is how "Expense Details" shows which side a saved row is on.
class TypeCard extends StatelessWidget {
  const TypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
    this.amountLabel,
  });

  final OperationType type;
  final bool selected;
  final VoidCallback onTap;

  /// Shown above the label when the form has a running total to report.
  final String? amountLabel;

  bool get _isExpense => type == OperationType.expense;

  Color get _accent => _isExpense ? AppColors.expense : AppColors.income;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        // A minimum rather than a fixed height: at the design's text size the
        // card is exactly the Figma 92pt, but it grows instead of overflowing
        // when the system font is enlarged.
        constraints: const BoxConstraints(
          minHeight: AppDimens.typeCardHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: selected ? _accent : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AppDimens.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (amountLabel != null) ...<Widget>[
              Text(
                amountLabel!,
                style: AppTextStyles.listTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ] else ...<Widget>[
              Icon(
                _isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20,
                color: _accent,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              _isExpense ? 'expenses'.tr : 'income'.tr,
              style: AppTextStyles.fieldLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
