import 'package:flutter/material.dart';

class AppSnackbars {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.blue,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.green);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.red);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.blue);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, backgroundColor: Colors.orange);
  }
}