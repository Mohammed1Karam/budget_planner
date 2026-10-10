import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

/// The chevron at the top-left of every pushed screen.
///
/// Figma exports it as a 180x44 instance, but only the glyph is visible; the
/// rest is the component's transparent hit area, reproduced here as padding.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.icon = Icons.arrow_back_ios_new});

  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ?? () => Get.back<void>(),
      splashRadius: 22,
      icon: Icon(icon, size: 20, color: AppColors.textPrimary),
    );
  }
}

/// The X used instead of a chevron on the modal add/edit screens.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ?? () => Get.back<void>(),
      splashRadius: 22,
      icon: const Icon(Icons.close, size: 24, color: AppColors.textPrimary),
    );
  }
}
