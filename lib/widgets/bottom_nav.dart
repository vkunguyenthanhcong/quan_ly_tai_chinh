import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1E2538),
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(Icons.list, 0),
            _item(Icons.account_balance_wallet, 1),
            const SizedBox(width: 40),
            _item(Icons.pie_chart, 3),
            _item(Icons.settings, 4),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, int index) {
    final isActive = currentIndex == index;

    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        color: isActive ? Colors.blueAccent : Colors.white54,
      ),
    );
  }
}
