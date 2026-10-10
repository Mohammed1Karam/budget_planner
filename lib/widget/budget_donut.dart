import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';

/// The ring at the top of Home.
///
/// It shows what has been spent today against the daily limit: the indigo arc
/// is the spent portion, the pale track is what is left. The amount spent sits
/// in the middle with the remaining balance on a pill below it.
class BudgetDonut extends StatelessWidget {
  const BudgetDonut({
    super.key,
    required this.spent,
    required this.limit,
    required this.currencySymbol,
    this.size = AppDimens.donutSize,
  });

  final double spent;
  final double limit;
  final String currencySymbol;
  final double size;

  /// Clamped so an overspend fills the ring rather than wrapping past it.
  double get progress =>
      limit <= 0 ? 0 : (spent / limit).clamp(0.0, 1.0).toDouble();

  bool get isOverLimit => limit > 0 && spent >= limit;

  double get remaining => math.max(limit - spent, 0);

  @override
  Widget build(BuildContext context) {
    final NumberFormat format = NumberFormat.decimalPattern();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              progress: progress,
              color: isOverLimit ? AppColors.expense : AppColors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$currencySymbol ${format.format(spent)}',
                style: AppTextStyles.amountHero,
              ),
              const SizedBox(height: 2),
              Text('spent_today'.tr, style: AppTextStyles.body),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'balance_for_today'.tr,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      '$currencySymbol ${format.format(remaining)}',
                      style: AppTextStyles.amountLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  /// Start at twelve o'clock rather than three, as the design draws it.
  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = AppDimens.donutStroke;
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final double radius = AppDimens.donutRing / 2;
    final Rect rect = Rect.fromCircle(center: centre, radius: radius);

    final Paint track = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _start, 2 * math.pi, false, track);

    if (progress <= 0) return;

    final double sweep = 2 * math.pi * progress;

    canvas.drawArc(
      rect,
      _start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    // The design marks the head of the arc with a dot, which also gives a
    // just-started value something visible to show.
    final double angle = _start + sweep;
    canvas.drawCircle(
      centre + Offset(math.cos(angle), math.sin(angle)) * radius,
      AppDimens.donutDot / 2,
      Paint()..color = AppColors.surface,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.color != color;
}
