import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/tips_controller.dart';
import '../../models/tip_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/article_card.dart';

/// Tips: the search field at y=113, then a two-column grid of 182x230 cards
/// with a 10pt gutter, matching the frame's x=20 / x=212 columns.
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TipsController controller = Get.find<TipsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('tips'.tr, style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
          ),
          child: Column(
            children: <Widget>[
              SearchField(onChanged: controller.search),
              const SizedBox(height: 27),
              Expanded(
                child: Obx(() {
                  final List<TipModel> tips = controller.visible;
                  if (tips.isEmpty) {
                    return Center(
                      child: Text(
                        'Nothing matches that search.',
                        style: AppTextStyles.body,
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 17,
                      crossAxisSpacing: 10,
                      childAspectRatio: 182 / AppDimens.articleCardHeight,
                    ),
                    itemCount: tips.length,
                    itemBuilder: (BuildContext context, int index) {
                      final TipModel tip = tips[index];
                      return ArticleCard(
                        tip: tip,
                        onTap: () => Get.toNamed<void>(
                          AppRoutes.tipArticle,
                          arguments: tip,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
