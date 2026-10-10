import 'package:get/get.dart';

import '../api/budget_api.dart';
import '../models/tip_model.dart';

/// The Tips grid and its search field.
class TipsController extends GetxController {
  TipsController({BudgetApi? api}) : _api = api ?? BudgetApi();

  final BudgetApi _api;

  final RxList<TipModel> tips = <TipModel>[].obs;
  final RxString query = ''.obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final List<TipModel> fetched = await _api.fetchTips();
      // The design shows six cards; the seed holds three, so it is doubled to
      // fill the grid the way the board does.
      tips.value = <TipModel>[...fetched, ...fetched];
    } finally {
      loading.value = false;
    }
  }

  List<TipModel> get visible {
    final String q = query.value.trim().toLowerCase();
    if (q.isEmpty) return tips;
    return tips.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  void search(String value) => query.value = value;
}
