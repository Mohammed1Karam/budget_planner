import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/category_tile.dart';
import '../../widget/segmented_toggle.dart';

/// "New Operation Category - Expenses" and "- Incomes": the toggle at y=110
/// and the list of categories under it. Pops with the picked category.
///
/// Which side is showing is held here rather than on [CategoryController].
/// The Category tab owns that controller's `filter` and stays mounted inside
/// the tab shell's IndexedStack, so writing to it from this screen would mark
/// the tab's Obx dirty while this route is still mounting — which Flutter
/// rejects. The two toggles are separate pieces of UI state anyway, and
/// keeping them separate also stops opening the picker from silently changing
/// what the Category tab is showing behind it.
class OperationCategoryScreen extends StatefulWidget {
  const OperationCategoryScreen({super.key});

  @override
  State<OperationCategoryScreen> createState() =>
      _OperationCategoryScreenState();
}

class _OperationCategoryScreenState extends State<OperationCategoryScreen> {
  late OperationType _type;

  @override
  void initState() {
    super.initState();
    // The form opens this screen with the side already chosen.
    final Object? argument = Get.arguments;
    _type = argument is OperationType ? argument : OperationType.expense;
  }

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    return AppScaffold(
      title: 'category'.tr,
      action: IconButton(
        onPressed: () => Get.toNamed<void>(AppRoutes.addCategory),
        splashRadius: 22,
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          SegmentedToggle(
            labels: <String>['expenses'.tr, 'income'.tr],
            selectedIndex: _type == OperationType.expense ? 0 : 1,
            onChanged: (int index) => setState(
              () => _type = index == 0
                  ? OperationType.expense
                  : OperationType.income,
            ),
          ),
          const SizedBox(height: 13),
          // Obx so a category added from the "+" action shows up on return.
          Expanded(
            child: Obx(
              () => ListView(
                children: controller
                    .ofType(_type)
                    .map(
                      (CategoryModel category) => CategoryTile(
                        category: category,
                        onTap: () =>
                            Get.back<CategoryModel>(result: category),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
