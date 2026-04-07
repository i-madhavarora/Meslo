import 'dart:convert';

class Encryption {
  static String encrypt(String text, String key) {
    final textBytes = utf8.encode(text);
    final keyBytes = utf8.encode(key);

    final encrypted = List.generate(textBytes.length, (i) {
      return textBytes[i] ^ keyBytes[i % keyBytes.length];
    });

    return base64Encode(encrypted);
  }

  static String decrypt(String encryptedText, String key) {
    final encryptedBytes = base64Decode(encryptedText);
    final keyBytes = utf8.encode(key);

    final decrypted = List.generate(encryptedBytes.length, (i) {
      return encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
    });

    return utf8.decode(decrypted);
  }
}