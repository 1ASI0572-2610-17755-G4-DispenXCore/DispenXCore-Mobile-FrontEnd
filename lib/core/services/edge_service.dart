import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EdgeService {
  Future<String> getEdgeIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('edge_ip');
    if (ip == null || ip.trim().isEmpty) {
      throw Exception('La dirección IP del Edge no está configurada. Por favor configúrela en Ajustes.');
    }
    return ip.trim();
  }

  Future<void> activateDispense({
    required String deviceId,
    required String supplyType,
  }) async {
    final ip = await getEdgeIp();
    final url = Uri.parse('http://$ip:5000/api/v1/dispenser/activate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'supply_type': supplyType,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
        Map<String, dynamic>? errorBody;
        try {
          errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {}
        final msg = errorBody?['message'] ?? 'Código de respuesta: ${response.statusCode}';
        throw Exception('Error del servidor Edge: $msg');
      }
    } on http.ClientException catch (e) {
      throw Exception('No se pudo conectar al Edge en $ip:5000. Verifique la conexión: $e');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al conectar con el Edge: $e');
    }
  }
}
