import 'package:flutter/material.dart';

class ScreenUtils {
  static BuildContext? _context;

  /// Set the context for ScreenUtils to use
  static void setContext(BuildContext context) {
    _context = context;
  }

  /// Get the current context safely
  static BuildContext get _safeContext {
    if (_context == null) {
      throw Exception(
        'ScreenUtils context not set. Call ScreenUtils.setContext() first.',
      );
    }
    return _context!;
  }

  /// Screen width and height
  static double get width => MediaQuery.of(_safeContext).size.width;
  static double get height => MediaQuery.of(_safeContext).size.height;

  /// Multiplies the value by 4 (custom scaling, adjust as needed)
  static double x(double value) => value * 4.0;
}
