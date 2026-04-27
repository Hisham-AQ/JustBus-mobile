import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class ParcelService {
  static const String _baseUrl = 'https://justbus-backend.onrender.com';

 static Future<Map<String, dynamic>> submitParcel({
  required String pickup,
  required String dropoff,
  required String type,
  required double weight,
  required String deliveryType,
  required String notes,
  required double price,
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
      "price": price
    }),
  );

  print("PARCEL STATUS: ${response.statusCode}");
  print("PARCEL BODY: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed (${response.statusCode})');
  }
}
}