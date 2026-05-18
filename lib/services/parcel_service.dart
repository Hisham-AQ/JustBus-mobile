import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class ParcelService {
  static const String _baseUrl =
      'https://justbus-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> submitParcel({
    required String pickup,
    required String dropoff,
    required String type,
    required double weight,
    required String deliveryType,
    required String notes,
    required String receiverName,
    String? rewardCode,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('No token');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/parcels'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "pickup_location": pickup,
        "dropoff_location": dropoff,
        "parcel_type": type,
        "weight": weight,
        "delivery_type": deliveryType,
        "notes": notes,
        "receiver_name": receiverName,
        if (rewardCode != null && rewardCode.isNotEmpty)
          "rewardCode": rewardCode,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>> validateReward({
    required String code,
    required String pickup,
    required String dropoff,
    required double weight,
    required String type,
  }) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/rewards/validate-reward'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "code": code,
        "pickup": pickup,
        "dropoff": dropoff,
        "weight": weight,
        "type": type,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Invalid reward (${response.statusCode}): ${response.body}',
      );
    }
  }
}
