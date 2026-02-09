import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        title: const Text(
          "Thông tin ứng dụng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _header(),

            const SizedBox(height: 24),

            _infoCard(),

            const SizedBox(height: 16),

            _optionItem(
              icon: Icons.privacy_tip_outlined,
              title: "Chính sách & quyền riêng tư",
              onTap: () {},
            ),

            _optionItem(
              icon: Icons.mail_outline,
              title: "Liên hệ hỗ trợ",
              subtitle: "support@email.com",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFF232A44),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 42,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Chi Tiêu Thông Minh",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Phiên bản 1.0.0",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================= INFO CARD =================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        "Ứng dụng giúp bạn quản lý chi tiêu cá nhân, "
        "quét hóa đơn tự động bằng OCR và phân loại giao dịch thông minh. "
        "Thiết kế tối giản, dễ dùng và tối ưu cho nhu cầu hàng ngày.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  // ================= OPTION ITEM =================

  Widget _optionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey.withOpacity(0.15),
          child: Icon(icon, color: Colors.blueGrey),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 13),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
