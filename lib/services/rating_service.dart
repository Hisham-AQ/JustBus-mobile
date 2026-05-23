import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class RatingService {
  static const String _baseUrl =
      'https://justbus-backend-production.up.railway.app';

  static Future<void> submitRating({
    required int tripId,
    required int driverRating,
    required int tripRating,
    required int serviceRating,
    required String comment,
  }) async {
    final token = await SecureStorage.getToken();

    final res = await http.post(
      Uri.parse('$_baseUrl/api/ratings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tripId': tripId,
        'driverRating': driverRating,
        'tripRating': tripRating,
        'serviceRating': serviceRating,
        'comment': comment,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to submit rating');
    }
  }
}
