import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// A 374x70 card with an icon, a label, and an optional chevron.
///
/// Settings is a stack of these; the daily-limit banner on Home reuses the
/// same shape with a tinted background.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.showChevron = true,
    this.foreground,
    this.background,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;

  /// Set to [AppColors.danger] for the destructive rows.
  final Color? foreground;

  final Color? background;

  /// Replaces the chevron, for rows that carry a switch or a value.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Color fg = foreground ?? AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          boxShadow: AppDimens.tileShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            child: Container(
              height: AppDimens.tileHeight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 24, color: fg),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.fieldLabel.copyWith(color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (showChevron)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small uppercase-ish heading above a run of [SettingTile]s.
class SettingSectionTitle extends StatelessWidget {
  const SettingSectionTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(label, style: AppTextStyles.sectionTitle),
    );
  }
}
