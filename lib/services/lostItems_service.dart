import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';

class LostItemsService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<void> submitReport({
    required String category,
    required String itemName,
    String? rideId,
    required String date,
    required String description,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lost-items'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "category": category,
        "item_name": itemName,
        if (rideId != null && rideId.isNotEmpty) "ride_id": rideId,
        "lost_date": date,
        "description": description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed");
    }
  }

  static Future<List<dynamic>> getMyReports() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token');

    final res = await http.get(
      Uri.parse('$_baseUrl/api/lost-items/my'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load reports");
    }
  }
}
