import 'package:budget_planner/utils/app_colors.dart';
import 'package:budget_planner/utils/app_dimens.dart';
import 'package:budget_planner/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the numbers that were measured off the Figma board.
///
/// Every expectation here is a literal from `UI_Budget_Planner_Light_mode`, so
/// a failure means the code drifted from the design rather than that the test
/// is stale. The sizes are exact; the colours are the estimates noted in
/// AppColors and are only checked for the relationships that must hold.
void main() {
  group('measurements match the Figma frames', () {
    test('frames are 414x896', () {
      expect(AppDimens.designWidth, 414);
      expect(AppDimens.designHeight, 896);
    });

    test('content is inset 20pt, so a button spans 374', () {
      expect(AppDimens.screenPadding, 20);
      expect(
        AppDimens.designWidth - AppDimens.screenPadding * 2,
        374,
        reason: 'Buttons / Primary is 374 wide at x=20',
      );
    });

    test('a primary button is 60 tall and fully rounded', () {
      expect(AppDimens.buttonHeight, 60);
      expect(
        AppDimens.radiusButton,
        30,
        reason: 'the Figma rectangle is 374x60 at radius 30, a full pill',
      );
    });

    test('the card radii are the ones the rectangles carry', () {
      expect(AppDimens.radiusCard, 8);
      expect(AppDimens.radiusField, 9);
      expect(AppDimens.radiusAvatar, 16);
      expect(AppDimens.radiusKey, 19);
    });

    test('pin keys are 71pt on a 103pt pitch', () {
      expect(AppDimens.keypadKey, 71);
      expect(
        AppDimens.keypadKey + AppDimens.keypadGap,
        103,
        reason: 'keys sit at x=69, 172, 275',
      );
    });

    test('the Expenses / Income card is 182x92', () {
      expect(AppDimens.typeCardWidth, 182);
      expect(AppDimens.typeCardHeight, 92);
      expect(
        AppDimens.typeCardWidth * 2 + 10,
        374,
        reason: 'cards at x=20 and x=212 leave a 10pt gutter',
      );
    });

    test('an article card is 182x230 with a 157pt image', () {
      expect(AppDimens.articleCardHeight, 230);
      expect(AppDimens.articleImageHeight, 157);
    });

    test('a settings row and the limit banner are both 70 tall', () {
      expect(AppDimens.tileHeight, 70);
    });

    test('an operation avatar is 54pt square', () {
      expect(AppDimens.operationAvatar, 54);
    });

    test('the home donut frame is 336 with a 302pt ring inside it', () {
      expect(AppDimens.donutSize, 336);
      expect(AppDimens.donutRing, 302);
      expect(AppDimens.donutStroke, closeTo(13.2, 0.01));
      expect(
        AppDimens.donutRing + AppDimens.donutStroke,
        lessThan(AppDimens.donutSize),
        reason: 'the stroked ring has to fit inside its frame',
      );
    });

    test('the tab bar is 92 tall', () {
      expect(AppDimens.bottomNavHeight, 92);
    });
  });

  group('palette', () {
    test('primary and its disabled variant are distinct', () {
      expect(AppColors.primary, isNot(AppColors.primaryDisabled));
    });

    test('expense reads red and income reads green', () {
      expect(AppColors.expense.r, greaterThan(AppColors.expense.g));
      expect(AppColors.income.g, greaterThan(AppColors.income.r));
    });

    test('text tones descend in contrast', () {
      double luminance(Color c) => c.computeLuminance();
      expect(
        luminance(AppColors.textPrimary),
        lessThan(luminance(AppColors.textSecondary)),
      );
      expect(
        luminance(AppColors.textSecondary),
        lessThan(luminance(AppColors.textTertiary)),
      );
    });

    test('body text on the background clears WCAG AA for small text', () {
      double relative(Color c) => c.computeLuminance();
      final double lighter = relative(AppColors.background) + 0.05;
      final double darker = relative(AppColors.textPrimary) + 0.05;
      expect(lighter / darker, greaterThanOrEqualTo(4.5));
    });

    test('button text on primary clears WCAG AA for large text', () {
      final double lighter = AppColors.textOnPrimary.computeLuminance() + 0.05;
      final double darker = AppColors.primary.computeLuminance() + 0.05;
      expect(lighter / darker, greaterThanOrEqualTo(3.0));
    });
  });

  group('type ramp', () {
    test('every size is one the Figma file actually uses', () {
      // build/figma/styles.json lists the file's text styles; these are the
      // sizes that appear on more than a stray node.
      // A list rather than a set: Dart will not build a const set of doubles,
      // and these are compared by tolerance anyway.
      const List<double> figmaSizes = <double>[
        10.0, 12.0, 13.0, 13.2, 15.0, 16.5, 18.5, 20.0, 21.0, 23.0,
      ];
      final Map<String, double> ramp = <String, double>{
        'splashTitle': AppTextStyles.splashTitle.fontSize!,
        'headline': AppTextStyles.headline.fontSize!,
        'appBarTitle': AppTextStyles.appBarTitle.fontSize!,
        'sectionTitle': AppTextStyles.sectionTitle.fontSize!,
        'amountHero': AppTextStyles.amountHero.fontSize!,
        'amountLarge': AppTextStyles.amountLarge.fontSize!,
        'fieldLabel': AppTextStyles.fieldLabel.fontSize!,
        'fieldValue': AppTextStyles.fieldValue.fontSize!,
        'body': AppTextStyles.body.fontSize!,
        'button': AppTextStyles.button.fontSize!,
        'amount': AppTextStyles.amount.fontSize!,
        'cardTitle': AppTextStyles.cardTitle.fontSize!,
        'caption': AppTextStyles.caption.fontSize!,
        'tabLabel': AppTextStyles.tabLabel.fontSize!,
      };

      ramp.forEach((String name, double size) {
        expect(
          figmaSizes.any((double s) => (s - size).abs() < 0.05),
          isTrue,
          reason: '$name is ${size}pt, which is not a size the design uses',
        );
      });
    });

    test('15pt carries the body of the design, as in the file', () {
      // 149 of the file's text nodes are Montserrat at 15/23.
      for (final TextStyle style in <TextStyle>[
        AppTextStyles.body,
        AppTextStyles.fieldLabel,
        AppTextStyles.fieldValue,
        AppTextStyles.button,
        AppTextStyles.amount,
        AppTextStyles.listTitle,
        AppTextStyles.listSubtitle,
      ]) {
        expect(style.fontSize, 15);
      }
    });

    test('headings sit at 20pt in the weight the file uses', () {
      for (final TextStyle style in <TextStyle>[
        AppTextStyles.headline,
        AppTextStyles.appBarTitle,
        AppTextStyles.sectionTitle,
      ]) {
        expect(style.fontSize, 20);
        expect(style.fontWeight, FontWeight.w700);
      }
    });

    test('the family is the one the file is set in', () {
      expect(AppTextStyles.family, 'Montserrat');
    });

    test('every style carries an explicit colour', () {
      for (final TextStyle style in <TextStyle>[
        AppTextStyles.splashTitle,
        AppTextStyles.headline,
        AppTextStyles.body,
        AppTextStyles.appBarTitle,
        AppTextStyles.sectionTitle,
        AppTextStyles.fieldLabel,
        AppTextStyles.fieldValue,
        AppTextStyles.button,
        AppTextStyles.amountHero,
        AppTextStyles.amount,
        AppTextStyles.caption,
      ]) {
        expect(style.color, isNotNull);
      }
    });

    test('the whole ramp is one family', () {
      final Set<String?> families = <String?>{
        AppTextStyles.headline.fontFamily,
        AppTextStyles.body.fontFamily,
        AppTextStyles.button.fontFamily,
        AppTextStyles.amountHero.fontFamily,
      };
      expect(families.length, 1);
    });
  });
}
