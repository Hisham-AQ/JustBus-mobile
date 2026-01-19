import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // ===== KEYS =====
  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyEmail = 'email';
  static const _keyUserName = 'user_name';

  // ===== TOKEN =====
  static Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _keyToken);

  // ===== ROLE =====
  static Future<void> saveRole(String role) =>
      _storage.write(key: _keyRole, value: role);

  static Future<String?> getRole() => _storage.read(key: _keyRole);

  // ===== EMAIL =====
  static Future<void> saveEmail(String email) =>
      _storage.write(key: _keyEmail, value: email);

  static Future<String?> getEmail() => _storage.read(key: _keyEmail);

  // ===== USER NAME ✅ =====
  static Future<void> saveUserName(String name) =>
      _storage.write(key: _keyUserName, value: name);

  static Future<String?> getUserName() => _storage.read(key: _keyUserName);

  // ===== CLEAR =====
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
