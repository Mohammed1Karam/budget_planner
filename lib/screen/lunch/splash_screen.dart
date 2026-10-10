import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../preferences/app_preferences.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';

/// LG_splash_screen: the 170x167 logo centred with the product name under it,
/// held for a beat before the app decides where to go.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final AppPreferences prefs = AppPreferences.instance;
    if (!prefs.onboardingSeen) {
      await Get.offAllNamed<void>('/onboarding');
    } else if (prefs.isLoggedIn) {
      await Get.offAllNamed<void>('/app');
    } else {
      await Get.offAllNamed<void>('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppSvg(AppAssets.logo, width: 170, height: 167),
            const SizedBox(height: 29),
            Text('app_name'.tr, style: AppTextStyles.splashTitle),
          ],
        ),
      ),
    );
  }
}
