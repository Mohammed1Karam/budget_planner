import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'app_back_button.dart';

/// The frame every screen in the design shares: white background, a centred
/// title, an optional leading chevron and a single trailing action.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBack = true,
    this.showClose = false,
    this.action,
    this.bottomNavigationBar,
    this.padded = true,
    this.onBack,
  });

  final Widget body;
  final String? title;
  final bool showBack;

  /// Swaps the chevron for an X, as on the add-operation screens.
  final bool showClose;

  final Widget? action;
  final Widget? bottomNavigationBar;

  /// Applies the design's 20pt side inset. Off for screens that bleed to the
  /// edge, such as the tip article's hero image.
  final bool padded;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bool hasBar = title != null || showBack || showClose || action != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: hasBar
          ? AppBar(
              leading: showClose
                  ? AppCloseButton(onTap: onBack)
                  : showBack
                      ? AppBackButton(onTap: onBack)
                      : const SizedBox.shrink(),
              leadingWidth: 56,
              title: title == null
                  ? null
                  : Text(title!, style: AppTextStyles.appBarTitle),
              actions: <Widget>[
                ?action,
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: SafeArea(
        top: !hasBar,
        child: padded
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: body,
              )
            : body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
