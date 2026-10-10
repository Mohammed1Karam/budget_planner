import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'primary_button.dart';

/// The "New Operation - Date" overlay: a 375pt sheet holding a 217pt wheel of
/// date, hour and minute, with the primary button under it.
///
/// Returns the chosen moment, or null if the sheet is dismissed. The wheel
/// itself is Cupertino's — the design draws the same three-column iOS picker,
/// with the selected row darker than the ones either side.
class DatePickerSheet extends StatefulWidget {
  const DatePickerSheet({super.key, required this.initial});

  final DateTime initial;

  /// Presents the sheet over [context] and resolves to the picked moment.
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initial,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusKey),
        ),
      ),
      builder: (BuildContext context) => DatePickerSheet(initial: initial),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppDimens.pickerSheetHeight,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 18),
            Text('pick_time'.tr, style: AppTextStyles.headline),
            const SizedBox(height: 12),
            SizedBox(
              height: AppDimens.pickerWheelHeight,
              child: CupertinoTheme(
                // The wheel draws its rows in the Cupertino text theme, so the
                // family and the two greys are set here rather than per row.
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontFamily: AppTextStyles.family,
                      fontSize: 23,
                      fontWeight: FontWeight.w400,
                      color: AppColors.wheelSelected,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: widget.initial,
                  itemExtent: AppDimens.pickerRowHeight,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime value) => _selected = value,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
              ),
              child: PrimaryButton(
                label: 'add'.tr,
                onPressed: () => Navigator.of(context).pop(_selected),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
