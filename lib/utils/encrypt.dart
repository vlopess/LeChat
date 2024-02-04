import 'package:encrypt/encrypt.dart';

/// {@category Controllers}
class Encrypt {

  static String encrypt(text) {
    final key = Key.fromUtf8('put32charactershereeeeeeeeeeeee!');
    final iv = IV.fromUtf8('put16characters!'); 
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = e.encrypt(text, iv: iv);
    return encrypted.base16;
  }
  static String decrypt(text) {
    final key = Key.fromUtf8('put32charactershereeeeeeeeeeeee!');
    final iv = IV.fromUtf8('put16characters!'); 
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = e.decrypt(Encrypted.fromBase16(text), iv: iv);
    return decrypted;
  }
}
