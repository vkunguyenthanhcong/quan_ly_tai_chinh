import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ConfirmType { danger, warning, normal }

class BeautifulConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = "Huỷ",
    String confirmText = "Xác nhận",
    ConfirmType type = ConfirmType.danger,
  }) async {
    if (Platform.isIOS) {
      return await _ios(context, title, message, cancelText, confirmText, type);
    } else {
      return await _android(
          context, title, message, cancelText, confirmText, type);
    }
  }

  // ================= ANDROID =================

  static Future<bool> _android(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String confirmText,
    ConfirmType type,
  ) async {
    final config = _config(type);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            backgroundColor: const Color(0xFF1E2538),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.icon,
                      size: 36,
                      color: config.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: config.color,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: Text(confirmText, style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  // ================= IOS =================

  static Future<bool> _ios(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String confirmText,
    ConfirmType type,
  ) async {
    final config = _config(type);

    return await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Column(
              children: [
                Icon(config.icon, color: config.color, size: 32),
                const SizedBox(height: 8),
                Text(title),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              CupertinoDialogAction(
                isDestructiveAction: type == ConfirmType.danger,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ) ??
        false;
  }

  static _DialogConfig _config(ConfirmType type) {
    switch (type) {
      case ConfirmType.warning:
        return _DialogConfig(Icons.warning_amber_rounded, Colors.orange);
      case ConfirmType.normal:
        return _DialogConfig(Icons.help_outline, Colors.blueAccent);
      case ConfirmType.danger:
      default:
        return _DialogConfig(Icons.delete_forever, Colors.redAccent);
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color color;

  _DialogConfig(this.icon, this.color);
}
