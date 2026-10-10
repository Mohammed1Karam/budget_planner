import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';

/// "Create Account - Success": a thumbs-up mark, a heading, one line of copy.
///
/// The frame has no button, so it sends the user on by itself.
class CreateAccountSuccessScreen extends StatefulWidget {
  const CreateAccountSuccessScreen({super.key});

  @override
  State<CreateAccountSuccessScreen> createState() =>
      _CreateAccountSuccessScreenState();
}

class _CreateAccountSuccessScreenState
    extends State<CreateAccountSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    await Get.offAllNamed<void>(AppRoutes.bottomNav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppSvg(AppAssets.icDone, width: 120, height: 115),
            const SizedBox(height: 29),
            Text('congratulations'.tr, style: AppTextStyles.headline),
            const SizedBox(height: 12),
            Text('you_have_registered'.tr, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
