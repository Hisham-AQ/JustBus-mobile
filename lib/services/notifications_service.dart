import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';

class NotificationsService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<List<dynamic>> getNotifications() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/notifications'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<void> markAsRead(int id) async {
    final token = await SecureStorage.getToken();

    final response = await http.patch(
      Uri.parse('$_baseUrl/api/notifications/$id/read'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read');
    }
  }

  static Future<void> deleteNotification(int id) async {
    final token = await SecureStorage.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/notifications/$id'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}
