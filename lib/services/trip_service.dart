import 'dart:convert';
import 'package:http/http.dart' as http;

class TripService {
  static Future<List<Map<String, dynamic>>> searchTrips({
    required String from,
    required String to,
    required String date,
  }) async {
    final uri = Uri.parse(
      'https://justbus-backend.onrender.com/api/trips'
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
}
