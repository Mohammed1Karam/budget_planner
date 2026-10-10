/// Every asset path the app asks for, named after its Figma layer.
///
/// `tool/figma_assets.py` slugs Figma layer names the same way, so
/// "ic / arrow / left / dark" lands at `assets/icons/ic_arrow_left_dark.svg`
/// and lines up with [icArrowLeftDark] below. Until that export has run the
/// files are absent; [AppSvg] renders a neutral placeholder rather than
/// throwing, so the layout is still reviewable.
class AppAssets {
  const AppAssets._();

  static const String _icons = 'assets/icons';
  static const String _images = 'assets/images';

  // Brand
  static const String logo = '$_icons/logo.svg';
  static const String icBudget = '$_icons/ic_budget.svg';
  static const String icDone = '$_icons/ic_done.svg';
  static const String icUsers = '$_icons/ic_users.svg';

  // Navigation
  static const String icArrowLeftDark = '$_icons/ic_arrow_left_dark.svg';
  static const String icArrowLittle = '$_icons/ic_arrow_litle.svg';
  static const String icClose = '$_icons/ic_close.svg';
  static const String icShareDark = '$_icons/ic_share_dark.svg';
  static const String icOther = '$_icons/ic_other.svg';

  // Settings rows, named after the Material icons the designer dropped in.
  static const String icInfo = '$_icons/info_black_24dp_1.svg';
  static const String icLanguage = '$_icons/language_black_24dp_1.svg';
  static const String icLogout = '$_icons/logout_black_24dp_1.svg';
  static const String icDeleteForever =
      '$_icons/delete_forever_black_24dp_1.svg';
  static const String icPersonRemove = '$_icons/person_remove_black_24dp_1.svg';
  static const String icSettings = '$_icons/settings_black_24dp_1.svg';
  static const String icAddCircle = '$_icons/add_circle_black_24dp_1.svg';
  static const String icSearch = '$_icons/search.svg';

  // Onboarding illustrations, in the order the three screens show them.
  static const String onboarding0 = '$_images/yana_ui_kit_illustration_01.svg';
  static const String onboarding1 = '$_images/yana_ui_kit_illustration_02.svg';
  static const String onboarding2 = '$_images/yana_ui_kit_illustration_03.svg';

  /// The hero at the top of a tip article, and the thumbnails in the grid.
  static const String articleHero = '$_images/tip_article_hero.svg';

  static const List<String> articleThumbnails = <String>[
    onboarding0,
    onboarding1,
    onboarding2,
  ];
}
