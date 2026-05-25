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

  static Future<void> requestBookingCancellation({
    required int bookingId,
    required String reason,
  }) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse(
        "$_baseUrl/api/activity/request-cancellation",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "booking_id": bookingId,
        "reason": reason,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Failed to send request',
      );
    }
  }
}
