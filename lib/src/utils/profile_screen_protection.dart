import 'package:flutter/services.dart';

class ProfileScreenProtection {
  static const MethodChannel _channel =
      MethodChannel('instiapp/profile_screen_protection');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod<void>('enable');
    } on MissingPluginException {
      // The native implementation is only available on mobile platforms.
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disable');
    } on MissingPluginException {
      // The native implementation is only available on mobile platforms.
    }
  }
}
