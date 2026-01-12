import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class AuthService {

static const String baseUrl = 'https://justbus-backend.onrender.com';

  // ================= LOGIN =================
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final data = jsonDecode(response.body);

    await SecureStorage.saveToken(data['token']);
    await SecureStorage.saveRole(data['role']);
    await SecureStorage.saveEmail(email);

    return data['role'];
  }

  // ================= REGISTER =================
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String gender,
    required DateTime birthDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'gender': gender,
        'birth_date': birthDate.toIso8601String().split('T')[0],
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
  }

// ================= LOGOUT =================
  static Future<void> logout() async {
    await SecureStorage.clear();
  }

  // ================= STORAGE =================
  static Future<String?> getToken() => SecureStorage.getToken();
  static Future<String?> getRole() => SecureStorage.getRole();
  static Future<String?> getEmail() => SecureStorage.getEmail();
}
