import 'package:flutter/material.dart';
import 'category_grid_screen.dart';

class ManageCategoryScreen extends StatelessWidget {
  const ManageCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121826),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121826),
          elevation: 0,
          leading: BackButton(color: Colors.white),
          title: const Text('Chọn nhóm giao dịch'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
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
