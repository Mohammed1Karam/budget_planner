import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// The 414x92 tab bar.
///
/// The design lays it out as Home, Categories, the raised add button, Profile,
/// then Tips — the add button sits in the middle of five slots rather than
/// beside the tabs.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.bar_chart_rounded, 'home'),
    _NavItem(Icons.grid_view_rounded, 'category'),
    _NavItem(Icons.person_outline_rounded, 'profile'),
    _NavItem(Icons.lightbulb_outline_rounded, 'tips'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowSoft,
            offset: Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            _tab(0),
            _tab(1),
            Expanded(child: Center(child: _addButton())),
            _tab(2),
            _tab(3),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final _NavItem item = _items[index];
    final bool selected = index == currentIndex;
    final Color color = selected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              item.labelKey.tr,
              style: AppTextStyles.tabLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// The indigo disc that opens the add-operation form, lifted above the bar.
  Widget _addButton() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.textOnPrimary, size: 26),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.labelKey);

  final IconData icon;
  final String labelKey;
}
