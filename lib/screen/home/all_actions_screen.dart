import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/home_controller.dart';
import '../../models/operation_model.dart';
import '../../utils/app_dimens.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_text_styles.dart';
import '../../widget/app_scaffold.dart';
import '../../widget/article_card.dart';
import '../../widget/operation_tile.dart';

/// All Actions: a search field over the full operation history, grouped under
/// a date divider per day exactly as the "Today" / "19 May" labels on the
/// frame.
class AllActionsScreen extends StatefulWidget {
  const AllActionsScreen({super.key});

  @override
  State<AllActionsScreen> createState() => _AllActionsScreenState();
}

class _AllActionsScreenState extends State<AllActionsScreen> {
  final TextEditingController _search = TextEditingController();

  String _query = '';

  HomeController get _controller => Get.find<HomeController>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Matches a row on its category or its description, which is what the two
  /// lines of a row show.
  bool _matches(OperationModel operation) {
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    return operation.category.name.toLowerCase().contains(q) ||
        operation.title.toLowerCase().contains(q);
  }

  Map<DateTime, List<OperationModel>> get _grouped {
    final Map<DateTime, List<OperationModel>> grouped =
        <DateTime, List<OperationModel>>{};
    for (final OperationModel o in _controller.operations.where(_matches)) {
      final DateTime day = DateTime(o.date.year, o.date.month, o.date.day);
      grouped.putIfAbsent(day, () => <OperationModel>[]).add(o);
    }
    final List<DateTime> days = grouped.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));
    return <DateTime, List<OperationModel>>{
      for (final DateTime day in days) day: grouped[day]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'actions'.tr,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          SearchField(
            controller: _search,
            onChanged: (String value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final Map<DateTime, List<OperationModel>> grouped = _grouped;

              if (grouped.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No operations yet.'
                        : 'Nothing matches that search.',
                    style: AppTextStyles.body,
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.only(
                  bottom: AppDimens.screenPadding,
                ),
                children: <Widget>[
                  for (final MapEntry<DateTime, List<OperationModel>> entry
                      in grouped.entries) ...<Widget>[
                    OperationDateDivider(date: entry.key),
                    ...entry.value.map(
                      (OperationModel operation) => OperationTile(
                        operation: operation,
                        currencySymbol: _controller.currencySymbol,
                        onTap: () => Get.toNamed<void>(
                          AppRoutes.expenseDetails,
                          arguments: operation,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
