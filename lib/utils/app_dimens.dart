import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing, radii, sizes and elevation taken from the Figma board.
///
/// Every screen there is 414x896, so a value such as [screenPadding] is the
/// literal Figma inset rather than a rounded guess. The radii in particular
/// were read off the rectangles themselves: buttons are fully rounded at 30,
/// cards sit at 8, and the pin keys at 19.
class AppDimens {
  const AppDimens._();

  /// Frames are 414 wide and content starts at x=20.
  static const double designWidth = 414;
  static const double designHeight = 896;

  static const double screenPadding = 20;

  /// Cards, fields, tiles and the money box.
  static const double radiusCard = 8;

  /// The login email and pin fields.
  static const double radiusField = 9;

  /// The emoji square in front of an operation row.
  static const double radiusAvatar = 16;

  /// A key on the pin pad.
  static const double radiusKey = 19;

  /// A primary button, which the design draws as a full pill.
  static const double radiusButton = 30;

  static const double radiusPill = 100;

  /// A primary button is 374x60 with 20pt of side padding.
  static const double buttonHeight = 60;

  /// The pin keypad's key, 71x71 on a 103pt pitch.
  static const double keypadKey = 71;
  static const double keypadGap = 32;

  /// The emoji tile in front of an operation row.
  static const double operationAvatar = 54;

  /// The "Diagram" frame on Home.
  static const double donutSize = 336;

  /// The arc inside it is a 302pt circle stroked at 13.2 — the frame is larger
  /// than the ring, which is why the two differ.
  static const double donutRing = 302;
  static const double donutStroke = 13.2;

  /// The 10pt dot Figma places at the head of the arc.
  static const double donutDot = 10;

  /// The Expenses / Income pair on the add-operation form.
  static const double typeCardWidth = 182;
  static const double typeCardHeight = 92;

  /// One card in the Tips grid.
  static const double articleCardHeight = 230;
  static const double articleImageHeight = 157;

  /// A settings row, and the daily-limit banner that shares its shape.
  static const double tileHeight = 70;

  static const double bottomNavHeight = 92;

  /// The "Pick time" sheet, and the wheel inside it.
  static const double pickerSheetHeight = 375;
  static const double pickerWheelHeight = 217;

  /// One row of the wheel; the selected one is highlighted across 208pt.
  static const double pickerRowHeight = 35;

  /// The lifted card shadow: white surfaces in this design separate from the
  /// page by shadow rather than by a grey fill.
  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, offset: Offset(0, 3), blurRadius: 14),
  ];

  /// The deeper version, under a pin key and a tip card.
  static const List<BoxShadow> raisedShadow = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, offset: Offset(0, 10), blurRadius: 18),
  ];

  /// The neutral one under a settings row.
  static const List<BoxShadow> tileShadow = <BoxShadow>[
    BoxShadow(color: AppColors.shadowSoft, offset: Offset(0, 3), blurRadius: 7),
  ];

  /// The faint one around a login field.
  static const List<BoxShadow> fieldShadow = <BoxShadow>[
    BoxShadow(color: AppColors.shadowHairline, blurRadius: 6),
  ];
}
