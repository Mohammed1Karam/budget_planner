import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// A row in the category list: emoji, name, and a hairline underneath.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
    this.selected = false,
    this.trailing,
  });

  final CategoryModel category;
  final VoidCallback? onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 77,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 28,
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (selected)
                  const Icon(Icons.check, size: 20, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
