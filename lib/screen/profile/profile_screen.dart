import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../models/currency_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_svg.dart';
import '../../widget/info_row.dart';
import '../../widget/primary_button.dart';

/// Profile: the avatar and name at the top, the same five rows as the sign-up
/// form but pre-filled, and a Save button at y=645.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _limit = TextEditingController();

  late CurrencyModel _currency;
  late String _pin;

  AppController get _app => Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    final UserModel user = _app.user.value;
    _name.text = user.name;
    _email.text = user.email;
    _limit.text = user.dailyLimit > 0 ? user.dailyLimit.toStringAsFixed(0) : '';
    _currency = CurrencyModel.byCode(user.currencyCode);
    _pin = user.pin;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _app.saveUser(
      _app.user.value.copyWith(
        name: _name.text.trim(),
        email: _email.text.trim(),
        currencyCode: _currency.code,
        dailyLimit: double.tryParse(_limit.text.replaceAll(',', '')) ?? 0,
        pin: _pin,
      ),
    );
    Get.snackbar('profile'.tr, 'Saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('profile'.tr, style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
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
                        AppAssets.icUsers,
                        width: 120,
                        height: 115,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Obx(
                      () => Text(
                        _app.user.value.name.isEmpty
                            ? 'profile'.tr
                            : _app.user.value.name,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline,
                      ),
                    ),
                    const SizedBox(height: 34),
                    InfoFieldRow(
                      label: 'name'.tr,
                      controller: _name,
                      hint: 'none'.tr,
                    ),
                    InfoFieldRow(
                      label: 'email_address'.tr,
                      controller: _email,
                      hint: 'none'.tr,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    InfoRow(
                      label: 'currency'.tr,
                      value: _currency.name,
                      showChevron: true,
                      onTap: () async {
                        final Object? picked = await Get.toNamed<Object?>(
                          AppRoutes.operationCurrency,
                        );
                        if (picked is CurrencyModel) {
                          setState(() => _currency = picked);
                        }
                      },
                    ),
                    InfoFieldRow(
                      label: 'daily_limit'.tr,
                      controller: _limit,
                      hint: r'$ 5000',
                      keyboardType: TextInputType.number,
                    ),
                    InfoRow(
                      label: 'change_your_pin'.tr,
                      value: _pin.isEmpty ? 'none'.tr : '•' * _pin.length,
                      showChevron: true,
                      showDivider: false,
                      onTap: () async {
                        final Object? pin =
                            await Get.toNamed<Object?>(AppRoutes.pinCode);
                        if (pin is String) setState(() => _pin = pin);
                      },
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
                16,
              ),
              child: PrimaryButton(label: 'save'.tr, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}
