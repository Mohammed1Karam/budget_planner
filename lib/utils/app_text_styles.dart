import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The type ramp, taken from the Figma file.
///
/// `build/figma/styles.json` lists every text style in the design with its
/// family, weight, size and line height. The design leans almost entirely on
/// Montserrat at 15pt — 149 of its text nodes — with 20pt for headings and a
/// handful of sizes above that, and those are the steps reproduced here.
class AppTextStyles {
  const AppTextStyles._();

  /// The family the whole file is set in. Bundled under `assets/fonts/`, so
  /// nothing is fetched at runtime.
  static const String family = 'Montserrat';

  static TextStyle _base(double size, FontWeight weight, Color color,
      {double? height, double? letterSpacing}) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// "Budget Planner" under the splash logo.
  static TextStyle get splashTitle =>
      _base(23, FontWeight.w700, AppColors.textPrimary, height: 28 / 23);

  /// Onboarding headline, and the "Get Started" / "Enter Passcode" titles.
  static TextStyle get headline =>
      _base(20, FontWeight.w700, AppColors.textPrimary, height: 24.4 / 20);

  /// Body copy under a headline, and the note field's placeholder.
  static TextStyle get body =>
      _base(15, FontWeight.w400, AppColors.textSecondary, height: 23 / 15);

  /// The centred title in a screen's app bar.
  static TextStyle get appBarTitle =>
      _base(20, FontWeight.w700, AppColors.textPrimary, height: 24.4 / 20);

  /// Section heading such as "Last actions" or "General".
  static TextStyle get sectionTitle =>
      _base(20, FontWeight.w700, AppColors.textPrimary, height: 24.4 / 20);

  /// The label on the left of a form row.
  static TextStyle get fieldLabel =>
      _base(15, FontWeight.w500, AppColors.textPrimary, height: 23 / 15);

  /// The value on the right of a form row.
  static TextStyle get fieldValue =>
      _base(15, FontWeight.w400, AppColors.textSecondary, height: 23 / 15);

  /// Text inside a primary button.
  static TextStyle get button =>
      _base(15, FontWeight.w600, AppColors.textOnPrimary, height: 18.3 / 15);

  /// "$ 765" in the middle of the donut.
  static TextStyle get amountHero =>
      _base(18.5, FontWeight.w600, AppColors.textPrimary, height: 22.5 / 18.5);

  /// The balance figure on the pill below it, which the design sets in the
  /// income colour.
  static TextStyle get amountLarge =>
      _base(13.2, FontWeight.w600, AppColors.income, height: 16.1 / 13.2);

  /// The signed amount at the right of an operation row.
  static TextStyle get amount =>
      _base(15, FontWeight.w600, AppColors.expense, height: 18.3 / 15);

  /// An operation's category, above its description.
  static TextStyle get listTitle =>
      _base(15, FontWeight.w600, AppColors.textPrimary, height: 23 / 15);

  /// An operation's description.
  static TextStyle get listSubtitle =>
      _base(15, FontWeight.w400, AppColors.textSecondary, height: 23 / 15);

  /// A date divider in the actions list, and an article's age.
  static TextStyle get caption =>
      _base(12, FontWeight.w600, AppColors.textTertiary, height: 14.6 / 12);

  /// A digit in the pin keypad.
  static TextStyle get keypadDigit =>
      _base(20, FontWeight.w600, AppColors.textPrimary, height: 24.4 / 20);

  /// The title on a tip card in the Tips grid.
  static TextStyle get cardTitle =>
      _base(15, FontWeight.w600, AppColors.textPrimary, height: 18.3 / 15);

  /// A tab label under the bottom bar's icon.
  static TextStyle get tabLabel =>
      _base(10, FontWeight.w700, AppColors.textTertiary, height: 12.2 / 10);
}
