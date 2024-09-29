import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class Utils {

  static void showSnackbar(BuildContext context, String text, {int duration = 3}) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<String> convertImageToBase64(File imageFile) async {
    Uint8List imagebytes = await imageFile.readAsBytes(); //convert to bytes
    String base64string =
    base64.encode(imagebytes); //convert bytes to base64 string
    // print(base64string);
    return base64string;
  }

  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

}