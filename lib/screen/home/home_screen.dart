import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../models/operation_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/budget_donut.dart';
import '../../widget/operation_tile.dart';
import '../../widget/primary_button.dart';
import '../../widget/tip_banner.dart';

/// Home, and its "Home - Reach Limit" variant.
///
/// The two frames differ by one thing: once the daily limit is spent, an amber
/// banner slots in above the donut and everything below shifts down. That is
/// driven here by [HomeController.hasReachedLimit] rather than a second file.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final AppController app = Get.find<AppController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.primary,
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
              ),
              children: <Widget>[
                _Header(name: app.user.value.name),
                if (controller.hasReachedLimit) ...<Widget>[
                  const SizedBox(height: 8),
                  TipBanner(
                    message: 'daily_limit_reached'.tr,
                    onTap: () => Get.toNamed<void>(AppRoutes.allActions),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: BudgetDonut(
                    spent: controller.spentToday,
                    limit: controller.dailyLimit,
                    currencySymbol: controller.currencySymbol,
                  ),
                ),
                const SizedBox(height: 23),
                Text('last_actions'.tr, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                if (controller.recent.isEmpty)
                  const _EmptyActions()
                else
                  ...controller.recent.map(
                    (OperationModel operation) => OperationTile(
                      operation: operation,
                      currencySymbol: controller.currencySymbol,
                      onTap: () => Get.toNamed<void>(
                        AppRoutes.expenseDetails,
                        arguments: operation,
                      ),
                    ),
                  ),
                const SizedBox(height: 31),
                PrimaryButton(
                  label: 'see_more'.tr,
                  onPressed: () => Get.toNamed<void>(AppRoutes.allActions),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The avatar on the left, the title, and the gear that opens Settings.
class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.surfaceTinted,
          child: Text(
            name.isEmpty ? '🙂' : name.characters.first.toUpperCase(),
            style: AppTextStyles.fieldLabel
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        Text('home'.tr, style: AppTextStyles.appBarTitle),
        const Spacer(),
        IconButton(
          onPressed: () => Get.toNamed<void>(AppRoutes.setting),
          splashRadius: 22,
          icon: const Icon(
            Icons.settings_outlined,
            size: 26,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyActions extends StatelessWidget {
  const _EmptyActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Text(
          'No operations yet. Tap + to add your first one.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
