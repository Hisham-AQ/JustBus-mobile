import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/ai"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "AI request failed",
      );
    }

    return jsonDecode(response.body);
  }
}

