import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/category_model.dart';
import '../models/operation_model.dart';
import '../models/user_model.dart';
import 'app_controller.dart';

/// Everything Home reads: today's spend against the daily limit, and the
/// recent operations under it.
class HomeController extends GetxController {
  HomeController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final RxList<OperationModel> operations = <OperationModel>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      operations.value = await _api.fetchOperations();
    } finally {
      loading.value = false;
    }
  }

  UserModel get _user => Get.find<AppController>().user.value;

  double get dailyLimit => _user.dailyLimit;

  String get currencySymbol => Get.find<AppController>().currencySymbol;

  /// Only expenses count towards the daily limit; income is not subtracted
  /// from it, matching how the design reads "spent today".
  double get spentToday {
    final DateTime now = DateTime.now();
    return operations
        .where((o) =>
            !o.isIncome &&
            o.date.year == now.year &&
            o.date.month == now.month &&
            o.date.day == now.day)
        .fold<double>(0, (sum, o) => sum + o.amount);
  }

  double get remainingToday =>
      dailyLimit <= 0 ? 0 : (dailyLimit - spentToday).clamp(0, dailyLimit);

  /// Switches Home to its "Reach Limit" variant, which adds the amber banner.
  bool get hasReachedLimit => dailyLimit > 0 && spentToday >= dailyLimit;

  /// The four most recent operations, as Home previews them.
  List<OperationModel> get recent => operations.take(4).toList();

  double totalOf(OperationType type) => operations
      .where((o) => o.category.type == type)
      .fold<double>(0, (sum, o) => sum + o.amount);

  /// Groups the full list by calendar day for the All Actions screen, newest
  /// day first, so each group can sit under its own date divider.
  Map<DateTime, List<OperationModel>> get groupedByDay {
    final Map<DateTime, List<OperationModel>> grouped =
        <DateTime, List<OperationModel>>{};
    for (final OperationModel o in operations) {
      final DateTime day = DateTime(o.date.year, o.date.month, o.date.day);
      grouped.putIfAbsent(day, () => <OperationModel>[]).add(o);
    }
    final List<DateTime> days = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return <DateTime, List<OperationModel>>{
      for (final DateTime day in days) day: grouped[day]!,
    };
  }

  Future<void> delete(String id) async {
    await _api.deleteOperation(id);
    await load();
  }
}
