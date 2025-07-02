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