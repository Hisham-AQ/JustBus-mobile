import 'dart:convert';
import 'package:http/http.dart' as http;

class SpecialTripService {
  //static const String baseUrl = 'https://justbus-backend.onrender.com';
  //static const String baseUrl = 'http://10.0.2.2:3000';

  static const baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<List<dynamic>> fetchTrips() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/special-trips'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load trips');
    }
  }

  static Future<Map<String, dynamic>> getTrip(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/special-trips/$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load trip');
    }
  }

  static Future<Map<String, dynamic>> bookTrip(
    int tripId,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/special-trips/book'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "tripId": tripId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }

    return data;
  }
}
