import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// The 374x67 centred amount field at the top of the operation form,
/// showing "$ 0,00" until something is typed.
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppDimens.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: AppTextStyles.amountLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 4),
            child: Text(currencySymbol, style: AppTextStyles.amountLarge),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          hintText: '0,00',
          hintStyle: AppTextStyles.amountLarge
              .copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

/// The 374x112 free-text note box under the operation form.
class NoteField extends StatelessWidget {
  const NoteField({super.key, required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppDimens.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppTextStyles.fieldLabel,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: 'note'.tr,
          hintStyle: AppTextStyles.fieldValue,
        ),
      ),
    );
  }
}
