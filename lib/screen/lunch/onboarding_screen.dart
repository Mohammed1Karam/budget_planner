import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/onboarding_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';
import '../../widget/primary_button.dart';

/// LG_onboarding_0/1/2 as a single pager.
///
/// The three frames share a layout -- progress bar at y=62, headline at 117,
/// body at 152, illustration filling the middle, button at 752 and Skip at
/// 824 -- so only the copy and the illustration change between them.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 18),
            Obx(() => _ProgressBar(
                  count: OnboardingController.pages.length,
                  current: controller.page.value,
                )),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: OnboardingController.pages.length,
                itemBuilder: (BuildContext context, int index) {
                  final OnboardingPage page =
                      OnboardingController.pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenPadding,
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 35),
                        Text(
                          page.titleKey.tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline,
                        ),
                        const SizedBox(height: 11),
                        Text(
                          page.bodyKey.tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: AppSvg(page.image, fit: BoxFit.contain),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
              ),
              child: Obx(
                () => PrimaryButton(
                  label: controller.actionKey.tr,
                  onPressed: controller.next,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.finish,
              child: Text(
                'skip'.tr,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// The 199x10 three-segment indicator at the top of each onboarding frame.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 199,
      height: 10,
      child: Row(
        children: List<Widget>.generate(count, (int index) {
          final bool filled = index <= current;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: filled ? AppColors.primary : AppColors.track,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
