import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// The 3x4 keypad on the pin screen: nine digits on 71pt rounded keys, then a
/// zero with a backspace beside it.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const List<List<String>> _rows = <List<String>>[
    <String>['1', '2', '3'],
    <String>['4', '5', '6'],
    <String>['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final List<String> row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.keypadGap),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final String digit in row) _DigitKey(digit, onDigit),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: AppDimens.keypadKey + AppDimens.keypadGap),
            _DigitKey('0', onDigit),
            SizedBox(
              width: AppDimens.keypadKey + AppDimens.keypadGap,
              child: Center(
                child: IconButton(
                  onPressed: onBackspace,
                  splashRadius: 26,
                  icon: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey(this.digit, this.onTap);

  final String digit;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.keypadGap / 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusKey),
          boxShadow: AppDimens.raisedShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusKey),
          child: InkWell(
            onTap: () => onTap(digit),
            borderRadius: BorderRadius.circular(AppDimens.radiusKey),
            child: SizedBox(
              width: AppDimens.keypadKey,
              height: AppDimens.keypadKey,
              child: Center(
                child: Text(digit, style: AppTextStyles.keypadDigit),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The row of boxes above the keypad showing how many digits are entered.
class PinDisplay extends StatelessWidget {
  const PinDisplay({
    super.key,
    required this.length,
    required this.filled,
  });

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (int index) {
        final bool isFilled = index < filled;
        return Container(
          width: 46,
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFilled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: isFilled
                ? null
                : Border.all(color: AppColors.divider),
            boxShadow: isFilled ? null : AppDimens.fieldShadow,
          ),
          child: isFilled
              ? Text(
                  '•',
                  style: AppTextStyles.keypadDigit
                      .copyWith(color: AppColors.textOnPrimary),
                )
              : null,
        );
      }),
    );
  }
}
