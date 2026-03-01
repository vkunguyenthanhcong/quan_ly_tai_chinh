import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import 'category_grid_screen.dart';

class ManageCategoryScreen extends StatelessWidget {
  const ManageCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(
            color: AppColors.textPrimary,
          ),
          title: const Text(
            'Chọn nhóm giao dịch',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CategoryGridScreen(type: 'expense'),
            CategoryGridScreen(type: 'income'),
          ],
        ),
      ),
    );
  }
}