import 'dart:convert';
import 'package:http/http.dart' as http;

class TripService {
  //static const String _baseUrl = 'https://justbus-backend.onrender.com';
  static const String _baseUrl = 'http://10.0.2.2:3000';

  // ================= SEARCH TRIPS =================
  static Future<List<Map<String, dynamic>>> searchTrips({
    required String from,
    required String to,
    required String date,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/trips'
      '?from=$from&to=$to&date=$date',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load trips');
    }
  }

  // ================= RESERVED SEATS =================
  static Future<List<Map<String, dynamic>>> getReservedSeats(int tripId) async {
    final uri = Uri.parse(
      'https://justbus-backend.onrender.com/api/trips/$tripId/seats',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return List<Map<String, dynamic>>.from(decoded['reservedSeats']);
    } else {
      throw Exception('Failed to load reserved seats');
    }
  }
}
