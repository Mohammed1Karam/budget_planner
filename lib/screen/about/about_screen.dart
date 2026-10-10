import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/app_svg.dart';

/// About: the mark, the product name, who built it, and the version.
///
/// The frame is centred vertically with the version pinned near the bottom.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Kept here rather than read from the package so the screen stays a pure
  /// widget; wire it to package_info_plus when the build number matters.
  static const String version = 'V1.0.0';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'about_app'.tr,
      body: Column(
        children: <Widget>[
          const Spacer(flex: 3),
          const AppSvg(AppAssets.logo, width: 120, height: 118),
          const SizedBox(height: 24),
          Text('app_name'.tr, style: AppTextStyles.headline),
          const SizedBox(height: 6),
          Text(
            'about_credit'.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const Spacer(flex: 4),
          Text(version, style: AppTextStyles.caption),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
