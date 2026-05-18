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

  static Future<double> topUp(double amount) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/topup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"amount": amount}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? "Top up failed");
    }

    return double.parse(data['balance'].toString());
  }

  static Future<double> pay(double amount) async {
    final token = await SecureStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/wallet/pay'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"amount": amount}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? "Payment failed");
    }

    return double.parse(data['balance'].toString());
  }

  static Future<List<dynamic>> getTransactions() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/wallet/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load transactions");
    }

    return jsonDecode(response.body);
  }
}
