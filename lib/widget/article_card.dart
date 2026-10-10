import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/tip_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_text_styles.dart';
import 'app_svg.dart';

/// One 182x230 card in the Tips grid: illustration, title, and how long ago
/// the article was published.
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.tip, this.onTap});

  final TipModel tip;
  final VoidCallback? onTap;

  String get _age {
    final int days = DateTime.now().difference(tip.publishedAt).inDays;
    if (days < 30) return DateFormat('d MMM').format(tip.publishedAt);
    final int months = days ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppDimens.raisedShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: AppDimens.articleImageHeight,
                child: ColoredBox(
                  color: AppColors.surfaceTinted,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: AppSvg(tip.image, fit: BoxFit.contain),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          tip.title,
                          style: AppTextStyles.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Center(child: Text(_age, style: AppTextStyles.caption)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 374x44 rounded search field above the Tips grid.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged, this.controller});

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, size: 22, color: AppColors.textTertiary),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.fieldLabel,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'search'.tr,
                hintStyle: AppTextStyles.fieldValue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
