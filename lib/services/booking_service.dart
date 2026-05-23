import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class BookingService {
  //static const String _baseUrl = 'https://justbus-backend.onrender.com';
  //static const String _baseUrl = 'http://10.0.2.2:3000';

  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> holdSeats({
    required int tripId,
    required String pickup,
    required String dropoff,
    required List<int> seats,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/bookings/hold'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tripId': tripId,
        'pickup': pickup,
        'dropoff': dropoff,
        'seats': seats,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        'bookingId': data['bookingId'],
        'holdExpiresAt': data['holdExpiresAt'],
        'totalPrice': double.parse(data['totalPrice'].toString()),
      };
    }

    final body = jsonDecode(response.body);

    throw Exception(
      body['message'] ?? 'Hold failed (${response.statusCode})',
    );
  }

  static Future<void> confirmBooking({
    required int bookingId,
    String? rewardCode,
  }) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/bookings/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "bookingId": bookingId,
        if (rewardCode != null && rewardCode.isNotEmpty)
          "rewardCode": rewardCode,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);

      throw Exception(data['message'] ?? 'Confirm failed');
    }
  }

  static Future<Map<String, dynamic>> validateReward({
    required String code,
    required int tripId,
  }) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/rewards/validate-reward'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "code": code,
        "tripId": tripId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message']);
    }
  }
}
