import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class ProfileService {
  //static const String _baseUrl = 'https://justbus-backend.onrender.com';
  //static const String _baseUrl = 'http://10.0.2.2:3000';
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile (${response.statusCode})');
    }
  }

  static Future<void> updateProfile({
    String? name,
    String? phone,
    DateTime? birthDate,
    String? avatar,
  }) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (birthDate != null) {
      body['birth_date'] = birthDate.toIso8601String().split('T')[0];
    }
    body['avatar'] = avatar;
    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
}
