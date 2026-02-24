// import 'package:flutter/material.dart';
// import 'package:quan_ly_chi_tieu/screens/settings_page.dart';
// import 'package:quan_ly_chi_tieu/screens/statistics_page.dart';
// import 'home_screen.dart';
// import 'wallet_page.dart';
// import '../widgets/bottom_nav.dart';
// import 'add_transaction_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = const [
//     HomeScreen(),
//     WalletPage(),
//     SizedBox(),
//     StatisticsPage(),
//     SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121826),
//       body: _pages[_currentIndex],

//       bottomNavigationBar: BottomNav(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blueAccent,
//         shape: const CircleBorder(),
//         elevation: 6,
//         child: const Icon(Icons.add),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
//           );
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }


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
    final route =
        ModalRoute.of(context)?.settings.arguments as String?;

    if (route == '/add-transaction') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const AddTransactionScreen()),
      );
    }

    if (route == '/scan') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const ScanBillPage()),
      );
    }
  });
}
Widget _miniAction({
  required IconData icon,
  required Color color,
}) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: SpeedDial(
  icon: Icons.add,
  activeIcon: Icons.close,
  backgroundColor: Colors.blueAccent,
  foregroundColor: Colors.white,
  overlayColor: Colors.black,
  overlayOpacity: 0.4,
  spacing: 12,
  spaceBetweenChildren: 12,

  children: [
    SpeedDialChild(
      child: _miniAction(
        icon: Icons.edit,
        color: Colors.green,
      ),
      backgroundColor: Colors.transparent, // 👈 QUAN TRỌNG
      elevation: 0,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(),
          ),
        );
      },
    ),
    SpeedDialChild(
      child: _miniAction(
        icon: Icons.qr_code_scanner,
        color: Colors.orange,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ScanBillPage(),
          ),
        );
      },
    ),
    
  ],
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
