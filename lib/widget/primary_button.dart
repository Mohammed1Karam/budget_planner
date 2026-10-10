import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// The 374x60 indigo button, the only button shape in the design.
///
/// Figma draws two states of it, "Blu / Normal" and "Blue / Disactive"; a null
/// [onPressed] renders the disabled one.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double? width;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimens.buttonHeight,
      child: Material(
        color: _enabled ? AppColors.primary : AppColors.primaryDisabled,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : Text(label, style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}
