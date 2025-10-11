import 'package:flutter/material.dart';

// Responsive.height(10,context) means saying 10% of the height of the screen

class Responsive {
  static width(double size, BuildContext context) {
    return MediaQuery.of(context).size.width * (size / 100);
  }

  static height(double size, BuildContext context) {
    return MediaQuery.of(context).size.height * (size / 100);
  }
}

// ================================================
// Enhanced scaling helpers for 412 x 912 reference
// ================================================
// Keep existing percentage API intact, and add pixel-scale based on a design
// size so you can write: RS.sw(context, 16), RS.sh(context, 24),
// RS.s(context, 12) for uniform scaling (icon sizes, radii, font sizes).

class RS {
  static const double baseW = 412.0; // reference width
  static const double baseH = 912.0; // reference height

  static Size _size(BuildContext context) => MediaQuery.of(context).size;

  /// Scale width-based pixel (designed for 412)
  static double sw(BuildContext context, double px) {
    final s = _size(context);
    return s.width / baseW * px;
  }

  /// Scale height-based pixel (designed for 912)
  static double sh(BuildContext context, double px) {
    final s = _size(context);
    return s.height / baseH * px;
  }

  /// Uniform scale: good for fontSize, icon, radius, gaps.
  /// Uses the smaller of width/height scale to maintain aspect feel.
  static double s(BuildContext context, double px) {
    final s = _size(context);
    final scaleW = s.width / baseW;
    final scaleH = s.height / baseH;
    final scale = scaleW < scaleH ? scaleW : scaleH;
    return px * scale;
  }

  /// Text scaling that also respects the user's accessibility textScaleFactor
  static double sp(BuildContext context, double px) {
    final scaled = s(context, px);
    final tsf = MediaQuery.of(context).textScaleFactor;
    return scaled * tsf.clamp(1.0, 1.3); // optional clamp to avoid huge blow-ups
  }
}

// ------- Orientation helpers -------
extension RSX on BuildContext {
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait  => MediaQuery.of(this).orientation == Orientation.portrait;
  Size get screenSize  => MediaQuery.of(this).size;
  double get shortest  => screenSize.shortestSide;
  bool get isTablet    => shortest >= 600;
}

class RSGrid {
  /// Adaptive column count based on a target tile width in your 412px design.
  static int columns(BuildContext context, {double targetTileW = 180, int min = 1, int max = 6}) {
    final w = MediaQuery.of(context).size.width;
    final cols = (w / RS.sw(context, targetTileW)).floor();
    if (cols < min) return min;
    if (cols > max) return max;
    return cols;
  }
}