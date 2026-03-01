import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quan_ly_chi_tieu/screens/settings_page.dart';
import 'package:quan_ly_chi_tieu/screens/statistics_page.dart';
import 'package:quan_ly_chi_tieu/screens/scan_bill_page.dart';
import 'home_screen.dart';
import 'wallet_page.dart';
import '../widgets/bottom_nav.dart';
import 'add_transaction_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    WalletPage(),
    SizedBox(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context)?.settings.arguments as String?;

      if (route == '/add-transaction') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      }

      if (route == '/scan') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanBillPage()),
        );
      }
    });
  }

  Widget _miniAction({required IconData icon, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F7FA),
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      elevation: 0,
      backgroundColor: Colors.transparent,
      overlayColor: Colors.black,
      overlayOpacity: 0.2,
      spacing: 14,
      spaceBetweenChildren: 14,

      /// FAB chính
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      children: [
        _dialItem(
          icon: Icons.edit,
          color: const Color(0xFF16A34A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          },
        ),
        _dialItem(
          icon: Icons.qr_code_scanner,
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanBillPage()),
            );
          },
        ),
      ],
    );
  }
  SpeedDialChild _dialItem({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return SpeedDialChild(
    elevation: 0,
    backgroundColor: Colors.transparent,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
    ),
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: color),
    ),
    onTap: onTap,
  );
}
}
