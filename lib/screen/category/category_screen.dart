import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/category_tile.dart';
import '../../widget/segmented_toggle.dart';

/// "Category - Actions & Details", the tab behind the second nav slot: the
/// Expenses / Income toggle over the full category list, with a plus in the
/// corner for adding one.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('category'.tr, style: AppTextStyles.appBarTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => Get.toNamed<void>(AppRoutes.addCategory),
            splashRadius: 22,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
          ),
          child: Obx(
            () => Column(
              children: <Widget>[
                const SizedBox(height: 8),
                SegmentedToggle(
                  labels: <String>['expenses'.tr, 'income'.tr],
                  selectedIndex:
                      controller.filter.value == OperationType.expense ? 0 : 1,
                  onChanged: (int index) => controller.setFilter(
                    index == 0 ? OperationType.expense : OperationType.income,
                  ),
                ),
                const SizedBox(height: 13),
                Expanded(
                  child: ListView(
                    children: controller.visible
                        .map(
                          (CategoryModel category) =>
                              CategoryTile(category: category),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
