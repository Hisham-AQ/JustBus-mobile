import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';
import 'package:geolocator/geolocator.dart';

class PanicService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<void> sendPanicAlert({
    required int tripId,
    required String issueType,
    required String note,
  }) async {
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    double lat = 32.4953;
    double lng = 35.9900;

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition();

        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      print('GPS FALLBACK => $e');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/panic'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'trip_id': tripId,
        'issue_type': issueType,
        'note': note,
        'lat': lat,
        'lng': lng,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);

      throw Exception(
        data['message'] ?? 'Failed to send alert',
      );
    }
  }
}
