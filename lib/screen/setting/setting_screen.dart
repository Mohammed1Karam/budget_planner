import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/app_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/primary_button.dart';
import '../../widget/setting_tile.dart';

/// Settings, the "All Actions" frames on the right of the board: a General
/// group, an Account & data group, and the red confirmation the third frame
/// shows over the top of it.
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController app = Get.find<AppController>();

    return AppScaffold(
      title: 'settings'.tr,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: <Widget>[
          SettingSectionTitle(label: 'general'.tr),
          SettingTile(
            icon: Icons.info_outline,
            label: 'about_menu'.tr,
            onTap: () => Get.toNamed<void>(AppRoutes.about),
          ),
          Obx(
            () => SettingTile(
              icon: Icons.language,
              label: 'language'.tr,
              trailing: Text(
                app.localeCode.value.startsWith('ar') ? 'العربية' : 'English',
                style: AppTextStyles.fieldValue,
              ),
              onTap: () => _showLanguageSheet(context, app),
            ),
          ),
          SettingTile(
            icon: Icons.logout,
            label: 'logout'.tr,
            showChevron: false,
            onTap: () async {
              await app.logout();
              await Get.offAllNamed<void>(AppRoutes.login);
            },
          ),
          const SizedBox(height: 18),
          SettingSectionTitle(label: 'account_and_data'.tr),
          SettingTile(
            icon: Icons.delete_forever_outlined,
            label: 'data'.tr,
            onTap: () => _confirmDestructive(
              context,
              title: 'data'.tr,
              body: 'delete_account_body'.tr,
              onConfirm: app.deleteAccount,
            ),
          ),
          SettingTile(
            icon: Icons.person_remove_outlined,
            label: 'remove_account'.tr,
            foreground: AppColors.danger,
            background: AppColors.dangerSurface,
            showChevron: false,
            onTap: () => _confirmDestructive(
              context,
              title: 'delete_account_title'.tr,
              body: 'delete_account_body'.tr,
              onConfirm: () async {
                await app.deleteAccount();
                await Get.offAllNamed<void>(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// The language picker.
  ///
  /// Anchored to this screen's context rather than pushed onto Get's global
  /// navigator: the sheet belongs to the screen, and going through the app-wide
  /// navigator for it means a locale change rebuilds the tree from under a
  /// route that is still animating.
  void _showLanguageSheet(BuildContext context, AppController app) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),
            for (final MapEntry<String, String> entry
                in const <String, String>{
              'en_US': 'English',
              'ar_JO': 'العربية',
            }.entries)
              ListTile(
                title: Text(entry.value),
                trailing: app.localeCode.value == entry.key
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  app.changeLocale(entry.key);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// The red card on the third "All Actions" frame: a title, a line of copy,
  /// and a Yes / No pair.
  void _confirmDestructive(
    BuildContext context, {
    required String title,
    required String body,
    required Future<void> Function() onConfirm,
  }) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(title, style: AppTextStyles.sectionTitle),
        content: Text(body, style: AppTextStyles.body),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              'no'.tr,
              style: AppTextStyles.fieldLabel
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 110,
            child: PrimaryButton(
              label: 'yes'.tr,
              onPressed: () async {
                Get.back<void>();
                await onConfirm();
              },
            ),
          ),
        ],
      ),
    );
  }
}
