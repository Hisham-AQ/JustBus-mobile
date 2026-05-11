import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class ActivityService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> getMyActivity() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/api/activity"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
