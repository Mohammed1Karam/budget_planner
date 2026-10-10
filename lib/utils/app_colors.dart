import 'package:flutter/material.dart';

/// The Budget Planner palette, read out of the Figma file itself.
///
/// `tool/figma_pull.py` writes every colour in `UI_Budget_Planner_Light_mode`
/// to `build/figma/styles.json`; the values here were then matched to the
/// nodes that actually use them, so each name reflects the role the colour
/// plays in the design rather than how often it appears.
class AppColors {
  const AppColors._();

  /// The indigo on "Buttons / Primary / Blu / Normal".
  static const Color primary = Color(0xFF472FC8);

  /// The deeper indigo the "Disactive" button variant is filled with.
  static const Color primaryDark = Color(0xFF351DB6);

  /// The washed-out indigo behind a button that is not yet actionable.
  static const Color primaryDisabled = Color(0xFFD3CFEA);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  /// The very light blue behind cards, the money field and the note box.
  static const Color surfaceMuted = Color(0xFFF3F6FF);

  /// The tinted square behind an operation's emoji, and the unselected
  /// Expenses / Income card.
  static const Color surfaceTinted = Color(0xFFF1F4FF);

  /// The near-black navy every heading and amount is set in.
  static const Color textPrimary = Color(0xFF0D0E56);

  /// Body copy, form values and placeholder text.
  static const Color textSecondary = Color(0xFF7B7C98);

  /// Date dividers and other de-emphasised captions.
  static const Color textTertiary = Color(0xFFB9BACE);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color divider = Color(0xFFE8EAF5);
  static const Color border = Color(0xFFBABAD7);

  /// Money out, on the amount at the right of an operation row.
  static const Color expense = Color(0xFFF33720);

  /// Money in, and the balance figure on the Home pill.
  static const Color income = Color(0xFF00BEA1);

  /// The destructive rows on Settings and their confirmation.
  static const Color danger = Color(0xFFD50000);
  static const Color dangerSurface = Color(0xFFFFEBEE);

  /// The banner shown once the daily limit is reached.
  static const Color warning = Color(0xFFFF9800);
  static const Color warningSurface = Color(0xFFFFF6E6);

  /// The unfilled remainder of the donut chart on Home.
  static const Color track = Color(0xFFD3CFEA);

  /// The 50%-opacity #191919 the design lays over the form behind a sheet.
  static const Color scrim = Color(0x80191919);

  /// The selected row in the time wheel, and the dimmer rows either side.
  static const Color wheelSelected = Color(0xFF333333);
  static const Color wheelUnselected = Color(0xFF999999);

  /// The lilac-grey every card in the design casts. Figma stores it opaque and
  /// relies on the blur to soften it, so it is used here at full alpha too.
  static const Color shadow = Color(0xFFE9E7F1);

  /// The softer, neutral shadow under a settings row.
  static const Color shadowSoft = Color(0x668F8F8F);

  /// The barely-there shadow that separates a login field from the page.
  static const Color shadowHairline = Color(0x36000000);
}
