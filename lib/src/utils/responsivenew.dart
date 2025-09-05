import 'package:flutter/material.dart';

class Responsive {
  static double baseWidth = 412.0;
  static double baseHeight = 917.0;

  static double width(double size, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return size * (screenWidth / baseWidth);
  }

  static double height(double size, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return size * (screenHeight / baseHeight);
  }
  static double text(double size, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return size * (screenWidth / baseWidth);
  }
}
