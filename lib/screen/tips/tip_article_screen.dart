import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/budget_api.dart';
import '../../models/tip_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_svg.dart';

/// Tip Article: a 414x348 illustration bleeding to the edges with the back and
/// share buttons floating on it, then the title, lead, bullet list and body.
class TipArticleScreen extends StatelessWidget {
  const TipArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? argument = Get.arguments;
    final TipModel tip = argument is TipModel ? argument : TipSeed.all.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 348,
                child: ColoredBox(
                  color: AppColors.surfaceTinted,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(58, 12, 58, 16),
                    child: AppSvg(tip.image, fit: BoxFit.contain),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 32, 26, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(tip.title, style: AppTextStyles.headline),
                    const SizedBox(height: 11),
                    Text(tip.lead, style: AppTextStyles.body),
                    const SizedBox(height: 20),
                    ...tip.bullets.map(
                      (String bullet) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(top: 9, right: 9),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                bullet,
                                style: AppTextStyles.fieldLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(tip.body, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _FloatingAction(
                    child: AppBackButton(onTap: () => Get.back<void>()),
                  ),
                  _FloatingAction(
                    child: IconButton(
                      onPressed: () => Get.snackbar(
                        tip.title,
                        'Sharing is not wired up yet.',
                      ),
                      splashRadius: 22,
                      icon: const Icon(
                        Icons.ios_share,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A white puck behind a button so it stays legible over the illustration.
class _FloatingAction extends StatelessWidget {
  const _FloatingAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: AppColors.shadow, blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}
