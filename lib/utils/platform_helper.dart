import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformHelper {
  /// Check if the current platform is mobile (Android or iOS)
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Check if the current platform is desktop (Windows, macOS, or Linux)
  static bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                                          defaultTargetPlatform == TargetPlatform.macOS || 
                                          defaultTargetPlatform == TargetPlatform.linux);

  /// Check if the current platform is web
  static bool get isWeb => kIsWeb;

  /// Show a platform-aware dialog for errors
  static Future<void> showErrorDialog(BuildContext context, String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show a platform-aware snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Get platform-specific padding
  static EdgeInsets getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}
