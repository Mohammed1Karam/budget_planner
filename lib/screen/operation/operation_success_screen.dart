import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';

/// "New Operation - Success": the same confirmation shape as the sign-up one,
/// with its own copy, then back to the app shell.
class OperationSuccessScreen extends StatefulWidget {
  const OperationSuccessScreen({super.key});

  @override
  State<OperationSuccessScreen> createState() => _OperationSuccessScreenState();
}

class _OperationSuccessScreenState extends State<OperationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
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
            const AppSvg(AppAssets.icUsers, width: 120, height: 115),
            const SizedBox(height: 29),
            Text('well_done'.tr, style: AppTextStyles.headline),
            const SizedBox(height: 12),
            Text('operation_saved'.tr, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
