import 'dart:convert';
import 'package:http/http.dart' as http;

class SpecialTripService {
  static const String baseUrl = 'https://justbus-backend.onrender.com';

  static Future<List<dynamic>> fetchTrips() async {
    final response = await http.get(Uri.parse('$baseUrl/special-trips'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load trips');
    }
  }
}
