import 'package:flutter/material.dart';

/// Describes the contrast needs of a color.
class AppBrightness {
  final index;
  const AppBrightness._internal(this.index);
  toString() => 'AppBrightness.$index';

  /// The color is dark and will require a light text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be dark grey, requiring white text.

  static const dark = const AppBrightness._internal(0);

  /// The color is light and will require a dark text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be bright white, requiring black text.

  static const light = const AppBrightness._internal(1);

  /// The color is black and will require a light text color to achieve readable
  /// contrast.
  ///
  /// For example, the color might be black, requiring white text.
  static const black = const AppBrightness._internal(2);

  static const brightnessToCanvasColor = {
    light: Colors.white,
    dark: Color(0xff303030),
    black: Colors.black,
  };

  static const values = [dark, light, black];

  Brightness toBrightness() {
    return index == 2 ? Brightness.dark : Brightness.values[index];
  }

  Color toColor() {
    return brightnessToCanvasColor[this];
  }
}
