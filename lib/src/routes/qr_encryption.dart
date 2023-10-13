import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/model/user.dart';

class QREncryption {
  String? number;
  QREncryption(User user) {
    number = user.userRollNumber;
  }
  String Encrypt() {
    final time = DateTime.now().toString();
    final message = number! + ',' + time;

    String? encryption_key = dotenv.env['KEY'];
    final key = Key.fromBase64(encryption_key!);
    final b64key = Key.fromBase64(base64Url.encode(key.bytes));
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);
    final encrypted = encrypter.encrypt(message);

    return encrypted.base64;
  }
}
