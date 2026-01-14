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
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Registration failed');
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

  //================== password change ============
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception("No token found");
    }

    final response = await http.put(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to send reset code');
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']);
    }
  }
}
