import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/category_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_back_button.dart';
import '../../widget/app_svg.dart';
import '../../widget/primary_button.dart';
import '../../widget/type_card.dart';

/// "Add New Category": the mark, the Expenses / Income pair, one text row and
/// the Add button. The emoji picker is an addition -- the frame leaves the
/// icon implicit, but a category without one would not render in the lists.
class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _name = TextEditingController();

  OperationType _type = OperationType.expense;
  String _emoji = '📦';

  /// A small palette, enough to tell one custom category from another.
  static const List<String> _emojis = <String>[
    '📦', '👚', '🚘', '🍕', '💊', '💵', '🏓', '📚', '🏠',
    '🎁', '💰', '🎖️', '☕', '🎬', '🏥', '✈️',
  ];

  bool get _canAdd => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await Get.find<CategoryController>()
        .add(name: _name.text, type: _type, emoji: _emoji);
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: AppCloseButton(onTap: () => Get.back<void>()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(
                      child: AppSvg(
                        AppAssets.icBudget,
                        width: 120,
                        height: 115,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'add_category'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 29),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TypeCard(
                            type: OperationType.expense,
                            selected: _type == OperationType.expense,
                            onTap: () => setState(
                              () => _type = OperationType.expense,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TypeCard(
                            type: OperationType.income,
                            selected: _type == OperationType.income,
                            onTap: () => setState(
                              () => _type = OperationType.income,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 33),
                    TextField(
                      controller: _name,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.fieldLabel,
                      decoration: InputDecoration(
                        hintText: 'category_name'.tr,
                        hintStyle: AppTextStyles.fieldValue,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _emojis.map((String emoji) {
                        final bool selected = emoji == _emoji;
                        return GestureDetector(
                          onTap: () => setState(() => _emoji = emoji),
                          child: Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.surfaceTinted
                                  : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusCard,
                              ),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                0,
                AppDimens.screenPadding,
                24,
              ),
              child: PrimaryButton(
                label: 'add'.tr,
                onPressed: _canAdd ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
