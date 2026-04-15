import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CryptoService {
  static Key? _key;

  static Key _getKey() {
    if (_key != null) return _key!;
    final raw = dotenv.env['CHALLENGE_KEY'] ?? 'TwinAmDefaultKey_000000000000000';
    final padded = raw.length >= 32
        ? raw.substring(0, 32)
        : raw.padRight(32, '0');
    _key = Key.fromUtf8(padded);
    return _key!;
  }

  static const _prefix = 'ENC.';

  /// Encrypt a plain-text string. Returns 'ENC.ivBase64.cipherBase64'.
  static String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_getKey(), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '$_prefix${iv.base64}.${encrypted.base64}';
  }

  /// Decrypt a value produced by encrypt(). Returns original text if not
  /// encrypted (backward-compatible with old plain-text rows).
  static String decrypt(String value) {
    if (!value.startsWith(_prefix)) return value;
    final body = value.substring(_prefix.length);
    final dot = body.indexOf('.');
    if (dot == -1) return value;
    try {
      final iv = IV.fromBase64(body.substring(0, dot));
      final encrypter = Encrypter(AES(_getKey(), mode: AESMode.cbc));
      return encrypter.decrypt64(body.substring(dot + 1), iv: iv);
    } catch (_) {
      return value;
    }
  }

  /// Encrypt only if the value is non-null and not already encrypted.
  static String? encryptNullable(String? value) {
    if (value == null || value.isEmpty) return value;
    if (value.startsWith(_prefix)) return value;
    return encrypt(value);
  }

  /// Decrypt only if non-null.
  static String? decryptNullable(String? value) {
    if (value == null) return null;
    return decrypt(value);
  }
}
