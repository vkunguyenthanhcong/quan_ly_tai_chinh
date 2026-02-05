import 'package:flutter/material.dart';

class AppGradients {
  static const walletDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF020617),
    ],
  );

  static const walletLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEFF6FF),
      Color(0xFFF8FAFC),
    ],
  );
}
