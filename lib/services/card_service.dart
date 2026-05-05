import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class CardService {
  static const baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<List<dynamic>> getCards() async {
    final token = await SecureStorage.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/api/cards'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return jsonDecode(res.body);
  }

  static Future<void> addCard({
    required String cardNumber,
    required String holder,
    required String expiry,
    required String brand,
  }) async {
    final token = await SecureStorage.getToken();

    await http.post(
      Uri.parse('$baseUrl/api/cards'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        "cardNumber": cardNumber,
        "holder": holder,
        "expiry": expiry,
        "brand": brand
      }),
    );
  }

  static Future<void> deleteCard(int id) async {
    final token = await SecureStorage.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/cards/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
}
