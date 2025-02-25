import 'package:flutter/material.dart';

enum SnackbarMessageType { info, warn, error, success }

extension MySnackbar on BuildContext {
  void showSnackbar({
    required String message,
    SnackbarMessageType type = SnackbarMessageType.info,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        // padding: const EdgeInsets.all(8),
        backgroundColor: {
          SnackbarMessageType.info: Colors.grey.shade600,
          SnackbarMessageType.warn: Colors.orange.shade600,
          SnackbarMessageType.error: Colors.red.shade600,
          SnackbarMessageType.success: Colors.green.shade600,
        }[type],
        duration: {
              SnackbarMessageType.success: const Duration(milliseconds: 500)
            }[type] ??
            const Duration(milliseconds: 1500),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
