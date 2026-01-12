import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'token', value: token);

  static Future<String?> getToken() => _storage.read(key: 'token');

  static Future<void> saveRole(String role) =>
      _storage.write(key: 'role', value: role);

  static Future<String?> getRole() => _storage.read(key: 'role');

  static Future<void> saveEmail(String email) =>
      _storage.write(key: 'email', value: email);

  static Future<String?> getEmail() => _storage.read(key: 'email');

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
