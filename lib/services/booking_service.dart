import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class BookingService {
  //static const String _baseUrl = 'https://justbus-backend.onrender.com';
  //static const String _baseUrl = 'http://10.0.2.2:3000';

  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  // ================= HOLD =================
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

    print('HOLD STATUS: ${response.statusCode}');
    print('HOLD BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Hold failed (${response.statusCode})');
  }

  // ================= CONFIRM =================
static Future<void> confirmBooking({
  required int bookingId,
}) async {
  final token = await SecureStorage.getToken();

  final response = await http.post(
    Uri.parse('$_baseUrl/api/bookings/confirm'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'bookingId': bookingId,
    }),
  );

  print('CONFIRM STATUS: ${response.statusCode}');
  print('CONFIRM BODY: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Confirm failed');
  }
}
}
