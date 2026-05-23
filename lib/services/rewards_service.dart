import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class RewardsService {
  static const baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<int> getPoints() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/rewards'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    return data['points'] ?? 0;
  }

  static Future<Map<String, dynamic>> redeem(String type) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/rewards/redeem'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"type": type}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Redeem failed');
    }

    return data;
  }
}
