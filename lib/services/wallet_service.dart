import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage.dart';

class WalletService {
  static const baseUrl = 'https://justbus-backend-production.up.railway.app';

  static Future<double> getBalance() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/wallet'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    return double.parse(data['balance'].toString());
  }

  static Future<void> topUp(double amount) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/topup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"amount": amount}),
    );

    if (response.statusCode != 200) {
      throw Exception("Top up failed");
    }
  }
}