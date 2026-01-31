import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

bool isValidPassword(String password) {
  return RegExp(r'^\d{6}$').hasMatch(password);
}

bool isValidGmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
      .hasMatch(email);
}
