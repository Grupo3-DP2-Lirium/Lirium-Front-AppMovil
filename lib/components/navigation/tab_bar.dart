import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/components.dart';

class Tab_Bar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Tab> tabs;

  const Tab_Bar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: false,
      labelColor: AppColors.inactive,
      unselectedLabelColor: AppColors.textPrimary,
      indicator: BoxDecoration(
        color: AppColors.primary,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
