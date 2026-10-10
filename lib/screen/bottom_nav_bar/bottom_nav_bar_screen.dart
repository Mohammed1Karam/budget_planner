import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/bottom_nav_controller.dart';
import '../../getx_controller/category_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../getx_controller/tips_controller.dart';
import '../../utils/app_routes.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../category/category_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../tips/tips_screen.dart';

/// The shell the four main frames live in: Home, Category, Tips and Profile,
/// with the raised add button between them.
class BottomNavBarScreen extends StatelessWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController nav = Get.put(BottomNavController());
    Get.put(HomeController());
    Get.put(CategoryController());
    Get.put(TipsController());

    const List<Widget> tabs = <Widget>[
      HomeScreen(),
      CategoryScreen(),
      ProfileScreen(),
      TipsScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: nav.index.value, children: tabs),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: nav.index.value,
          onSelected: nav.select,
          onAdd: () => Get.toNamed<void>(AppRoutes.addOperation),
        ),
      ),
    );
  }
}
