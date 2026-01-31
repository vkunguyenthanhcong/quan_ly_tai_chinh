import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final String amount;
  final String? icon;


  const TransactionItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.icon,
  });

  Widget _icon() {
  if (icon == null || icon!.isEmpty) {
    return const Icon(Icons.category, color: Colors.white);
  }
  print(icon);
  return Image.asset(
    icon!,
    width: 50,
    height: 50,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.category, color: Colors.white),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2538),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: _icon(),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(category, style: const TextStyle(color: Colors.white38)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amount.startsWith("-") ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
