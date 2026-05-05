import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class TripService {
  //static const String _baseUrl = 'https://justbus-backend.onrender.com';
  //static const String _baseUrl = 'http://10.0.2.2:3000';
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  // ================= SEARCH TRIPS =================
  static Future<List<Map<String, dynamic>>> searchTrips({
    required String from,
    required String to,
    required String date,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/trips').replace(
      queryParameters: {
        'from': from,
        'to': to,
        'date': date,
      },
    );

    final token = await SecureStorage.getToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );


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
      '$_baseUrl/api/trips/$tripId/seats',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return List<Map<String, dynamic>>.from(decoded['reservedSeats']);
    } else {
      throw Exception('Failed to load reserved seats');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyTrips() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/api/trips/my"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("MY TRIPS STATUS: ${response.statusCode}");
    print("MY TRIPS BODY: ${response.body}");

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(response.body);
    }
  }
}
