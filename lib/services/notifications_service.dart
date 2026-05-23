import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';

class NotificationsService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception('No token');
    }

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  static Future<List<dynamic>> getNotifications() async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/api/notifications'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<void> markAsRead(int id) async {
    final response = await http
        .patch(
          Uri.parse('$_baseUrl/api/notifications/$id/read'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  static Future<void> hideNotification(int id) async {
    final response = await http
        .delete(
          Uri.parse('$_baseUrl/api/notifications/$id'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
