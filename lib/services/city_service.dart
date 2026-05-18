import 'dart:convert';
import 'package:http/http.dart' as http;

class CityService {
  static Future<List<String>> getCities() async {
    final response = await http.get(
      //Uri.parse('https://justbus-backend.onrender.com/api/cities'),
      //Uri.parse('http://10.0.2.2:3000/api/cities'),
      Uri.parse('https://justbus-backend-production.up.railway.app/api/trips/cities'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data
          .map<String>((e) => e['from_city'].toString())
          .toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }
}
