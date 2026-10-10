import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../preferences/app_preferences.dart';
import '../utils/app_assets.dart';
import '../utils/app_routes.dart';

/// Drives the three onboarding pages and the progress bar above them.
class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt page = 0.obs;

  static const List<OnboardingPage> pages = <OnboardingPage>[
    OnboardingPage(
      titleKey: 'onboarding_title_0',
      bodyKey: 'onboarding_body_0',
      image: AppAssets.onboarding0,
    ),
    OnboardingPage(
      titleKey: 'onboarding_title_1',
      bodyKey: 'onboarding_body_1',
      image: AppAssets.onboarding1,
    ),
    OnboardingPage(
      titleKey: 'onboarding_title_2',
      bodyKey: 'onboarding_body_2',
      image: AppAssets.onboarding2,
    ),
  ];

  bool get isLast => page.value == pages.length - 1;

  /// The last page's button reads "Let's start" instead of "Next".
  String get actionKey => isLast ? 'lets_start' : 'next';

  void onPageChanged(int index) => page.value = index;

  void next() {
    if (isLast) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> finish() async {
    await AppPreferences.instance.setOnboardingSeen();
    await Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

/// The copy and illustration for one onboarding page.
class OnboardingPage {
  const OnboardingPage({
    required this.titleKey,
    required this.bodyKey,
    required this.image,
  });

  final String titleKey;
  final String bodyKey;
  final String image;
}
