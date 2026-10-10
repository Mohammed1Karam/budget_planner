import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// A label on the left, a value on the right, a hairline underneath.
///
/// The create-account, profile and add-operation forms are all built from a
/// column of these; the Figma layer named "lines" is the run of hairlines.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = false,
    this.showDivider = true,
    this.valueColor,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  /// The small right-pointing arrow on rows that open a picker.
  final bool showChevron;

  /// Off for the last row in a group, which has no hairline under it.
  final bool showDivider;

  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 69,
            child: Row(
              children: <Widget>[
                Text(label, style: AppTextStyles.fieldLabel),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: valueColor == null
                        ? AppTextStyles.fieldValue
                        : AppTextStyles.fieldValue.copyWith(color: valueColor),
                  ),
                ),
                if (showChevron) ...<Widget>[
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

/// An [InfoRow] whose value the user types instead of picking.
class InfoFieldRow extends StatelessWidget {
  const InfoFieldRow({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType,
    this.obscure = false,
    this.showDivider = true,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool showDivider;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 69,
          child: Row(
            children: <Widget>[
              Text(label, style: AppTextStyles.fieldLabel),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscure,
                  onChanged: onChanged,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.fieldValue,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTextStyles.fieldValue
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
