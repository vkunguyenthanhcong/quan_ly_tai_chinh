import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/screens/manage_category_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        
        title: const Text(
          "Cài đặt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingItem(
            icon: Icons.translate,
            iconColor: Colors.blue,
            title: "Ngôn ngữ",
            onTap: () {},
          ),
          _settingItem(
            icon: Icons.category,
            iconColor: Colors.purple,
            title: "Quản lý thể loại",
            onTap: () {
              Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManageCategoryScreen(),
      ),
    );
            },
          ),
          _settingItem(
            icon: Icons.color_lens,
            iconColor: Colors.orange,
            title: "Giao diện hệ thống",
            onTap: () {},
          ),
          _settingItem(
            icon: Icons.people,
            iconColor: Colors.green,
            title: "Bạn bè",
            onTap: () {},
          ),
          _settingItem(
            icon: Icons.person,
            iconColor: Colors.teal,
            title: "Tài khoản",
            onTap: () {},
          ),
          _settingItem(
            icon: Icons.notifications,
            iconColor: Colors.amber,
            title: "Thông báo",
            badge: "1",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// ================= SETTING ITEM =================

  Widget _settingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black
          ),
        ),
        trailing: badge != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
