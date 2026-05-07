import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';

class DriverService {
  static const _baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> getCurrentTrip() async {
    final token = await SecureStorage.getToken();

    print(token);

    final res = await http.get(
      Uri.parse('$_baseUrl/api/driver/current-trip'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print(res.statusCode);
    print(res.body);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("No trip");
    }
  }

  static Future<void> startTrip(int tripId) async {
    final token = await SecureStorage.getToken();

    final res = await http.patch(
      Uri.parse('$_baseUrl/api/driver/start-trip'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tripId": tripId,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }

  static Future<void> endTrip(int tripId) async {
    final token = await SecureStorage.getToken();

    final res = await http.patch(
      Uri.parse('$_baseUrl/api/driver/end-trip'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tripId": tripId,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }

  static Future<Map<String, dynamic>> scanTicket(String qrToken) async {
    final token = await SecureStorage.getToken();

    final res = await http.post(
      Uri.parse('$_baseUrl/api/driver/scan-ticket'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "qrToken": qrToken,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getPassengers() async {
    final token = await SecureStorage.getToken();

    final res = await http.get(
      Uri.parse('$_baseUrl/api/driver/passengers'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }

  static Future<void> dropOffPassenger(int seatId) async {
    final token = await SecureStorage.getToken();

    final res = await http.patch(
      Uri.parse('$_baseUrl/api/driver/dropoff'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "seatId": seatId,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }

  static Future<void> reportMisconduct({
    required String seatNumber,
    String? passengerName,
    required String category,
    required String severity,
    required String description,
  }) async {
    final token = await SecureStorage.getToken();

    final res = await http.post(
      Uri.parse(
        '$_baseUrl/api/driver/report-misconduct',
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "seat_number": seatNumber,
        "passenger_name": passengerName,
        "category": category,
        "severity": severity,
        "description": description,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }

  static Future<void> updateLocation({
    required int tripId,
    required double lat,
    required double lng,
  }) async {
    final token = await SecureStorage.getToken();

    final res = await http.patch(
      Uri.parse('$_baseUrl/api/driver/update-location'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tripId": tripId,
        "lat": lat,
        "lng": lng,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load passengers");
    }
  }
}
