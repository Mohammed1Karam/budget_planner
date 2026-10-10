import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/currency_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_scaffold.dart';

/// "New Operation - Currency": four rows, each a flag and the currency's full
/// name. Pops with the chosen currency.
class OperationCurrencyScreen extends StatelessWidget {
  const OperationCurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'currency'.tr,
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 12),
        itemCount: CurrencyModel.all.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final CurrencyModel currency = CurrencyModel.all[index];
          return InkWell(
            onTap: () => Get.back<CurrencyModel>(result: currency),
            child: SizedBox(
              height: 78,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusCard),
                    ),
                    child: Text(
                      currency.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currency.name,
                      style: AppTextStyles.fieldLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
