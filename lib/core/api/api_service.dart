import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  // DEVICE
  static Future<List<dynamic>> getDevices() async {
    final res = await http.get(Uri.parse("$baseUrl/devices"));
    return jsonDecode(res.body);
  }

  static Future<void> toggleDevice(String id, bool status) async {
    await http.patch(
      Uri.parse("$baseUrl/devices/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"online": status}),
    );
  }

  // HISTORY
  static Future<List<dynamic>> getHistory() async {
    final res = await http.get(Uri.parse("$baseUrl/history"));
    return jsonDecode(res.body);
  }

  // USER
  static Future<Map<String, dynamic>> getUser(String id) async {
    final res = await http.get(Uri.parse("$baseUrl/users/$id"));
    return jsonDecode(res.body);
  }
}